# Game-Theoretic Estimation and Diagnostics — Implementation Reference

## Estimation

### Maximum Likelihood for Complete Information Games

For complete information games with a unique equilibrium (or a maintained selection rule), MLE is straightforward:

```python
from scipy.optimize import minimize
import numpy as np
from scipy.stats import norm

def complete_info_entry_mle(params, market_data):
    """
    MLE for Berry (1992) complete information entry model.

    Equilibrium selection: ordered by profitability index.
    """
    beta = params[:3]    # market characteristic coefficients
    gamma = params[3]    # competitive effect
    sigma = np.exp(params[4])   # error scale

    ll = 0.0
    for _, market in market_data.groupby('market_id'):
        n_entered = market['entered'].sum()
        n_firms = len(market)

        # Rank firms by profit index (excluding error)
        profit_indices = market[['X1', 'X2', 'X3']].values @ beta

        # Under ordered equilibrium: top n_entered firms enter
        # Marginal entrant condition: profit_n - gamma*(n-1) + eps > 0
        # First non-entrant condition: profit_{n+1} - gamma*n + eps < 0

        for rank, (_, row) in enumerate(market.sort_values('profit_index', ascending=False).iterrows()):
            z = (profit_indices[rank] - gamma * min(rank, n_entered - 1)) / sigma
            if rank < n_entered:
                ll += np.log(max(norm.cdf(z), 1e-15))
            else:
                ll += np.log(max(1 - norm.cdf(z - gamma / sigma), 1e-15))

    return -ll
```

### Two-Step Estimation

Two-step approaches avoid solving for the full equilibrium at each parameter guess:

**Step 1:** Estimate best-response probabilities (P(firm i enters | rivals' actions and market characteristics)) using flexible methods (logit, probit, local polynomial).

**Step 2:** Given Step 1 estimates, form pseudo-log-likelihood or moment conditions for structural parameters.

```python
from sklearn.linear_model import LogisticRegression
from scipy.optimize import minimize
import numpy as np

def two_step_entry_estimation(market_data, n_rivals_max=5):
    """
    Two-step estimation for entry game (Bajari-Hong-Ryan 2010 approach).

    Step 1: Estimate entry probabilities nonparametrically (logit).
    Step 2: Recover structural profit parameters from estimated probabilities.
    """
    # === STEP 1: Estimate entry probabilities ===
    X_step1 = market_data[['X_market', 'Z_firm', 'n_rivals']].values
    y_step1 = market_data['entered'].values

    logit = LogisticRegression(C=1e6, solver='lbfgs', max_iter=1000)
    logit.fit(X_step1, y_step1)

    # Predicted entry probabilities for each firm in each market
    market_data = market_data.copy()
    market_data['p_enter_hat'] = logit.predict_proba(X_step1)[:, 1]

    # === STEP 2: Recover structural parameters ===
    def step2_moments(params):
        """
        Moment conditions: E[Z_i * (entry_i - p_enter_hat_i)] = 0
        where p_enter_hat is constructed from Step 1 probabilities
        and the structural profit function.
        """
        beta_0, beta_1, gamma = params

        # Predicted entry under structural model
        profit_linear = (beta_0 + beta_1 * market_data['X_market']
                         + gamma * market_data['n_rivals'])
        p_structural = 1 / (1 + np.exp(-profit_linear))

        # Moment conditions: instrument * (structural - nonparam)
        Z = market_data['Z_firm'].values
        residuals = market_data['p_enter_hat'].values - p_structural.values
        moments = Z * residuals

        return moments

    def step2_objective(params):
        moments = step2_moments(params)
        return (moments ** 2).mean()

    result = minimize(step2_objective, x0=[0.0, 0.1, -0.5],
                      method='Nelder-Mead', options={'xatol': 1e-8})

    return result.x, market_data['p_enter_hat']
```

### MPEC Formulation for Games

For complete information games with a unique equilibrium, MPEC can be applied directly — treat the equilibrium strategy profile as a decision variable and impose equilibrium conditions as constraints.

```python
# MPEC for Bertrand pricing game
# Variables: [theta, p_1, ..., p_J] — structural parameters + equilibrium prices
# Constraints: FOC of each firm's pricing problem (Nash conditions)

def bertrand_nash_constraints(x, data, n_products):
    """
    Nash conditions for Bertrand pricing: each firm's price satisfies its FOC.
    Constraint: dπ_j/dp_j = 0 for all j.
    """
    theta = x[:n_params]
    prices = x[n_params:]

    constraints = []
    for j in range(n_products):
        q_j = demand_fn(prices, theta, j, data)
        dq_dpj = demand_derivative(prices, theta, j, data)
        mc_j = cost_fn(theta, j, data)

        # FOC: q_j + (p_j - mc_j) * dq/dp_j = 0
        foc_j = q_j + (prices[j] - mc_j) * dq_dpj
        constraints.append(foc_j)

    return np.array(constraints)
```

### Moment Inequality Estimation

For partially identified models (Ciliberto-Tamer), moment inequality estimators are required:

```python
from scipy.optimize import differential_evolution
import numpy as np

def moment_inequality_criterion(params, market_data, alpha=0.05):
    """
    Andrews-Guggenberger (2009) or Rosen (2008) moment inequality criterion.

    For each parameter value, test whether all moment inequalities hold.
    The identified set = {theta : all moment inequalities hold at level alpha}.
    """
    # Upper and lower bounds on moments
    moments_upper, moments_lower = compute_moment_bounds(params, market_data)

    # Test statistic: sum of violations
    violations_upper = np.maximum(moments_upper - 0, 0) ** 2
    violations_lower = np.maximum(0 - moments_lower, 0) ** 2

    T = violations_upper.sum() + violations_lower.sum()
    return T

def compute_moment_bounds(params, market_data):
    """
    For each observed outcome, compute best-case and worst-case
    predicted probabilities over all Nash equilibria.
    """
    beta, alpha_comp = params[0], params[1]
    moments_upper = []
    moments_lower = []

    for _, market in market_data.groupby('market_id'):
        observed = tuple(market['entered'].values)

        # Find all Nash equilibria
        all_ne = find_all_nash_equilibria(params, market)

        if len(all_ne) == 0:
            # Parameter value implies no equilibrium — outside identified set
            return np.array([1.0]), np.array([-1.0])

        # Best-case: equilibrium selection that maximizes predicted probability
        # Worst-case: equilibrium selection that minimizes it
        ne_matches = [int(ne == observed) for ne in all_ne]
        moments_upper.append(max(ne_matches))
        moments_lower.append(min(ne_matches))

    return np.array(moments_upper), np.array(moments_lower)
```

---

## Diagnostics and Validation

### Equilibrium Validity Checklist

- [ ] **Existence verified:** Does a Nash equilibrium exist for the estimated parameters and every market in the data? If not, the model is misspecified.
- [ ] **Uniqueness or selection rule stated:** If the game has multiple equilibria at the estimated parameters, state explicitly which selection rule is used — and justify it.
- [ ] **Best-response mapping verified:** For each player, check that the estimated strategy is actually a best response given opponents' strategies. Compute deviations and verify they are unprofitable.
- [ ] **Off-equilibrium behavior consistent:** If the model implies specific off-equilibrium beliefs (e.g., in signaling games), check that these beliefs satisfy the maintained refinement (sequential rationality, D1 criterion).
- [ ] **Conduct restrictions testable:** If imposing conduct restrictions (Bertrand, Cournot, collusion), carry out a formal test of the restriction — do not just assume the conduct assumption is correct.
- [ ] **Equilibrium stability:** In dynamic games, verify that the MPE is locally stable — small perturbations in the state converge back to the equilibrium path.

```python
def verify_nash_equilibrium(strategies, payoff_fns, tol=1e-6):
    """
    Verify that a strategy profile is a Nash equilibrium.
    Returns True if Nash, and a list of profitable deviations if not.
    """
    n_players = len(strategies)
    profitable_deviations = []

    for i in range(n_players):
        eq_payoff = payoff_fns[i](strategies)

        # Check all deviations for player i
        for dev_strategy in get_all_strategies(i):
            dev_profile = strategies.copy()
            dev_profile[i] = dev_strategy
            dev_payoff = payoff_fns[i](dev_profile)

            if dev_payoff > eq_payoff + tol:
                profitable_deviations.append({
                    'player': i,
                    'deviation': dev_strategy,
                    'gain': dev_payoff - eq_payoff
                })

    is_nash = len(profitable_deviations) == 0
    return is_nash, profitable_deviations
```

### Model Fit for Game-Theoretic Models

```python
def game_model_fit_stats(observed_outcomes, predicted_probs, model_name=""):
    """
    Goodness-of-fit statistics for discrete games.
    """
    import pandas as pd
    from scipy.stats import chi2

    n = len(observed_outcomes)
    unique_outcomes = np.unique(observed_outcomes, axis=0)

    # Predicted vs. observed frequency for each outcome
    rows = []
    for outcome in unique_outcomes:
        mask = np.all(observed_outcomes == outcome, axis=1)
        obs_freq = mask.mean()

        # Average predicted probability for this outcome
        pred_freq = predicted_probs[mask].mean() if mask.sum() > 0 else 0.0

        rows.append({
            'outcome': str(tuple(outcome)),
            'observed_freq': obs_freq,
            'predicted_freq': pred_freq,
            'n_obs': mask.sum()
        })

    fit_table = pd.DataFrame(rows)
    fit_table['residual'] = fit_table['observed_freq'] - fit_table['predicted_freq']

    # Pearson chi-squared test
    chi2_stat = n * ((fit_table['residual'] ** 2) / fit_table['predicted_freq'].clip(1e-10)).sum()
    df = len(unique_outcomes) - 1
    p_value = 1 - chi2.cdf(chi2_stat, df)

    print(f"\n{model_name} Model Fit:")
    print(fit_table.to_string(index=False))
    print(f"\nPearson chi-squared: {chi2_stat:.3f} (df={df}, p={p_value:.4f})")

    return fit_table, chi2_stat, p_value
```
