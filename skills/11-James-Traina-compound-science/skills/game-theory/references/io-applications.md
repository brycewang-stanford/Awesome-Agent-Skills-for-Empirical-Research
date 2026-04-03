# Structural IO Applications — Implementation Reference

## Entry Models

Entry models are the canonical empirical application of game theory in IO. The key challenge: observed market structure (number of entrants) must be consistent with Nash equilibrium, but multiple equilibria may exist.

### Bresnahan-Reiss (1991): Ordered Probit Approach

Bresnahan and Reiss estimate how competitive conduct changes with market structure by exploiting variation in market size. The key insight: if entry is free, the N-th firm enters only if the market is large enough to sustain N firms profitably.

**Model:**
```
π_N = (per-firm variable profit when N firms operate) × (market size S) - entry cost F_N
```

Firms enter until the marginal entrant earns zero profit. The threshold market size to support N firms is:
```
S_N* = F_N / V_N(N)
```

where V_N(N) is per-firm variable profit with N competitors.

**Ordered probit estimation:**

```python
import numpy as np
from scipy.stats import norm
from scipy.optimize import minimize

def bresnahan_reiss_loglik(params, N_obs, S_obs, X_obs):
    """
    Ordered probit log-likelihood for Bresnahan-Reiss entry model.

    params: [alpha_0, alpha_1, ..., alpha_k, beta_0, beta_1, ..., beta_m]
        alpha: coefficients for threshold equation (market size, demographics)
        beta: entry cost shifters
    N_obs: observed number of firms in each market
    S_obs: market size (population, income, etc.)
    X_obs: market characteristics
    """
    n_markets = len(N_obs)
    n_alpha = X_obs.shape[1]

    alpha = params[:n_alpha]
    sigma = np.exp(params[n_alpha])  # log-parameterize for positivity

    # Thresholds: ln(S_N*) = alpha @ X + error
    # Firm N enters iff ln(S) >= ln(S_N*), i.e., standardized: (ln(S) - alpha@X)/sigma >= 0
    thresholds = X_obs @ alpha   # log-threshold for each market

    ll = 0.0
    max_N = int(N_obs.max())

    for i in range(n_markets):
        n_i = int(N_obs[i])
        z_i = (np.log(S_obs[i]) - thresholds[i]) / sigma

        if n_i == 0:
            # No entry: P(N=0) = Phi(-z_1)
            prob = norm.cdf(-z_i)
        elif n_i == max_N:
            # Maximum observed: P(N >= max) = Phi(z_{max})
            prob = norm.cdf(z_i)
        else:
            # Interior: P(N=n) = Phi(z_n) - Phi(z_{n+1})
            # Requires separate threshold per N — simplified here as linear shift
            prob = norm.cdf(z_i) - norm.cdf(z_i - 1.0 / sigma)

        ll += np.log(max(prob, 1e-15))

    return -ll

# Estimation
result = minimize(bresnahan_reiss_loglik,
                  x0=np.zeros(X_obs.shape[1] + 1),
                  args=(N_obs, S_obs, X_obs),
                  method='Nelder-Mead',
                  options={'xatol': 1e-8, 'fatol': 1e-10})
```

**Key results to report:** Threshold ratios S_N*/S_{N-1}*. Under perfect competition these ratios should equal 1. Ratios > 1 indicate market power — the per-firm profit needed to sustain an additional entrant exceeds the competitive level.

**Reference:** Bresnahan, T., and P. Reiss. 1991. "Entry and Competition in Concentrated Markets." *Journal of Political Economy* 99(5): 977-1009.

### Berry (1992): Complete Information Entry

Berry extends Bresnahan-Reiss to allow firms to be asymmetric. The key equilibrium condition: firm i enters market m if and only if its equilibrium profit is non-negative.

**Model:**
```
π_im = X_m β + Z_im γ - δ * N_m^* + ε_im  >= 0  ↔  firm i enters
```

where N_m^* is the equilibrium number of entrants (endogenous).

**Ordered equilibrium:** Berry imposes an ordering restriction — firms enter in order of their profitability (highest first). This selects a unique equilibrium from the multiple equilibria that generally exist, making the model point-identified.

```python
def berry_entry_loglik(params, entry_data):
    """
    Berry (1992) entry model with ordered equilibrium selection.

    params: [beta, gamma, delta, sigma_eps]
    entry_data: DataFrame with market characteristics, firm dummies, entry outcomes
    """
    beta = params[0]
    delta = params[1]
    sigma = np.exp(params[2])

    ll = 0.0
    for market_id, market in entry_data.groupby('market_id'):
        n_firms = len(market)
        n_entered = market['entered'].sum()

        # Ordered equilibrium: top n_entered firms (by observed rank) entered
        # Equilibrium profit of marginal entrant must be >= 0
        # Profit of first non-entrant must be < 0

        X_m = market['X'].iloc[0]   # market-level variable

        for firm_idx, row in market.iterrows():
            z_profit = (X_m * beta - delta * n_entered + row['Z'] * 0.1) / sigma

            if row['entered']:
                ll += np.log(max(norm.cdf(z_profit), 1e-15))
            else:
                ll += np.log(max(1 - norm.cdf(z_profit), 1e-15))

    return -ll
```

**Reference:** Berry, S. 1992. "Estimation of a Model of Entry in the Airline Industry." *Econometrica* 60(4): 889-917.

### Ciliberto-Tamer (2009): Partial Identification with Multiple Equilibria

Ciliberto and Tamer drop the equilibrium selection assumption entirely. The model only requires that observed outcomes are consistent with *some* Nash equilibrium — it does not specify which one. This yields a partially identified model: the sharp identified set rather than a point.

**Model setup:**
```
Firm i enters market m if and only if:
    X_m β_i + Z_im γ_i + Σ_{j≠i} α_ij * 1[j enters] + ε_im >= 0

where α_ij < 0 captures competitive effects (entry of j reduces i's profit)
```

**Sharp identified set:** The set of parameter values θ such that there exist selection probabilities that rationalize the data:

```python
def ciliberto_tamer_bounds(params, market_data, n_draws=500, seed=42):
    """
    Ciliberto-Tamer (2009) moment inequality estimator.

    For each parameter value θ, compute:
        H_upper(θ) = P(outcome) under best-case equilibrium selection
        H_lower(θ) = P(outcome) under worst-case equilibrium selection

    θ is in the identified set iff H_lower(θ) <= P_data(outcome) <= H_upper(θ)
    """
    rng = np.random.default_rng(seed)
    beta = params[:2]
    alpha = params[2]   # competitive effect (should be negative)

    n_markets = market_data['market_id'].nunique()
    moment_violations = 0

    for market_id, market in market_data.groupby('market_id'):
        X_m = market['X'].iloc[0]
        n_firms = len(market)
        observed_entry = market['entered'].values

        # Enumerate all Nash equilibria for this market and parameter value
        # For 2-firm case: 4 possible outcomes {(0,0), (0,1), (1,0), (1,1)}
        nash_equilibria = []
        for outcome in [(0, 0), (0, 1), (1, 0), (1, 1)]:
            is_nash = True
            for i in range(n_firms):
                n_others = sum(outcome[j] for j in range(n_firms) if j != i)
                profit_if_enter = X_m * beta[i] + alpha * n_others
                profit_if_stay_out = 0

                if outcome[i] == 1 and profit_if_enter < 0:
                    is_nash = False
                    break
                if outcome[i] == 0 and profit_if_enter > 0:
                    is_nash = False
                    break

            if is_nash:
                nash_equilibria.append(outcome)

        # Check if observed outcome is a Nash equilibrium
        if tuple(observed_entry) not in nash_equilibria:
            moment_violations += 1

    # Return proportion of markets where observed outcome is not a NE
    # In the identified set: this should be 0 (or within sampling error)
    return moment_violations / n_markets

# Outer criterion function for set estimation
def ct_criterion(params, market_data, confidence_level=0.95):
    """
    Chernozhukov-Hong-Tamer (2007) criterion for confidence region.
    Returns the test statistic for whether params is in the confidence set.
    """
    violation_rate = ciliberto_tamer_bounds(params, market_data)
    # Compare to critical value from subsampling or bootstrap
    return violation_rate
```

**Estimation procedure:**
1. Grid search over parameter space (or Markov Chain Monte Carlo)
2. At each θ, check whether observed data is consistent with some Nash equilibrium
3. Report the identified set: all θ consistent with the data
4. Confidence region via Chernozhukov-Hong-Tamer (2007) or Romano-Shaikh subsampling

**Reference:** Ciliberto, F., and E. Tamer. 2009. "Market Structure and Multiple Equilibria in Airline Markets." *Econometrica* 77(6): 1791-1828.

---

## Conduct Testing

Conduct testing asks: what game are firms actually playing? The standard approach estimates a conduct parameter θ ∈ [0,1] that nests Bertrand (θ=0), Cournot (θ=1/N), and joint monopoly (θ=1).

### Markup Tests (Rotemberg-Saloner, BLP Supply Side)

The workhorse markup equation from oligopoly theory:

```
p_j - mc_j = -θ * (∂Q_j/∂p_j)^{-1} * Q_j
```

where θ is the conduct parameter. Under Bertrand pricing θ = 1 (own elasticity only), under Cournot θ = market share, under collusion θ = industry-level term.

In the BLP framework with a supply side:

```python
import pyblp

# After solving demand, add supply side
problem = pyblp.Problem(
    product_formulations=(
        pyblp.Formulation('1 + prices + x1 + x2'),    # demand linear
        pyblp.Formulation('1 + prices'),               # demand nonlinear
    ),
    product_data=product_data,
    # Supply formulation: marginal cost = gamma @ w + omega
    cost_formulation=pyblp.Formulation('1 + w1 + w2'),
)

# Estimate under Bertrand conduct
results_bertrand = problem.solve(
    sigma=sigma_init,
    pi=pi_init,
    beta=beta_init,
    method='2s',
)

# Retrieve implied marginal costs and markups
costs = results_bertrand.compute_costs()
markups = results_bertrand.compute_markups()
prices_implied = costs + markups

# Conduct test: compare Bertrand vs Cournot vs collusion via
# - J-test on overidentifying restrictions
# - Rivers-Vuong non-nested test
```

### Rivers-Vuong Non-Nested Conduct Test

Rivers and Vuong (2002) provide a non-nested hypothesis test between conduct specifications:

```python
from scipy.stats import norm as scipy_norm
import numpy as np

def rivers_vuong_test(ll_model1, ll_model2, n_obs):
    """
    Rivers-Vuong (2002) non-nested test between two conduct models.

    H0: models are asymptotically equivalent (neither fits better)
    H1: Model 1 fits better (T > 1.96) or Model 2 fits better (T < -1.96)

    ll_model1, ll_model2: arrays of per-observation log-likelihoods
    """
    d = ll_model1 - ll_model2
    d_bar = d.mean()
    sigma_d = d.std(ddof=1)

    T = np.sqrt(n_obs) * d_bar / sigma_d

    p_value = 2 * (1 - scipy_norm.cdf(abs(T)))

    print(f"Rivers-Vuong T-statistic: {T:.4f}")
    print(f"p-value: {p_value:.4f}")

    if T > 1.96:
        print("Reject H0 in favor of Model 1")
    elif T < -1.96:
        print("Reject H0 in favor of Model 2")
    else:
        print("Fail to reject H0 — models are observationally equivalent")

    return T, p_value
```

**References:**
- Rotemberg, J., and G. Saloner. 1986. "A Supergame-Theoretic Model of Price Wars during Booms." *American Economic Review* 76(3): 390-407.
- Rivers, D., and Q. Vuong. 2002. "Model Selection Tests for Nonlinear Dynamic Models." *Econometrics Journal* 5(1): 1-39.

---

## Bargaining Models

### Nash Bargaining (Axiomatic)

The Nash bargaining solution maximizes the Nash product subject to individual rationality:

```
max_{x ∈ F} (u_1(x) - d_1)^β * (u_2(x) - d_2)^{1-β}
```

where d_i are disagreement payoffs (outside options) and β ∈ (0,1) is the bargaining weight.

**Generalized Nash Bargaining (Horn-Wolinsky 1988):** The standard model for vertical bargaining in IO (used in Grennan 2013 for medical device markets, Crawford-Yurukoglu 2012 for cable TV):

```python
import numpy as np
from scipy.optimize import brentq

def nash_bargaining_surplus(prices, costs, outside_options, beta, demand_fn):
    """
    Generalized Nash Bargaining: seller sets price maximizing Nash product.

    Firm's Nash bargaining solution price: implicit equation from FOC of Nash product.
    """
    def nash_product_foc(p, buyer_id):
        """FOC of Nash product w.r.t. price — find root."""
        q = demand_fn(p)
        profit_seller = (p - costs[buyer_id]) * q
        surplus_buyer = outside_options[buyer_id] - p * q   # simplified

        # FOC: beta * d(profit)/dp / profit + (1-beta) * d(surplus)/dp / surplus = 0
        dprofit_dp = q + (p - costs[buyer_id]) * 0   # ignoring demand slope for illustration
        dsurplus_dp = -q

        if profit_seller <= 0 or surplus_buyer <= 0:
            return np.inf
        return beta * dprofit_dp / profit_seller + (1 - beta) * dsurplus_dp / surplus_buyer

    equilibrium_prices = {}
    for buyer_id in range(len(outside_options)):
        try:
            p_star = brentq(nash_product_foc, costs[buyer_id] + 0.01, 100.0,
                           args=(buyer_id,), xtol=1e-10)
            equilibrium_prices[buyer_id] = p_star
        except ValueError:
            equilibrium_prices[buyer_id] = np.nan

    return equilibrium_prices
```

**Structural estimation of bargaining weight β:**

```python
def estimate_bargaining_weight(data, cost_fn, demand_fn, outside_option_fn):
    """
    Identify β from variation in outside options (Horn-Wolinsky).

    Key moment: prices should respond to changes in outside options
    in proportion to (1-β). More variation in outside options → better identification.
    """
    from scipy.optimize import minimize_scalar

    def gmm_objective(beta):
        predicted_prices = []
        observed_prices = data['price'].values

        for i, row in data.iterrows():
            c_i = cost_fn(row)
            d_i = outside_option_fn(row)

            # Nash bargaining price (analytical solution for linear demand)
            # p* = (c + d/q) * beta + (p_monopoly) * (1 - beta)
            # Simplified: illustrative functional form
            p_star = beta * c_i + (1 - beta) * row['reservation_price']
            predicted_prices.append(p_star)

        residuals = observed_prices - np.array(predicted_prices)
        return (residuals ** 2).mean()

    result = minimize_scalar(gmm_objective, bounds=(0.01, 0.99), method='bounded')
    return result.x

# In practice: use GMM with outside option instruments (Crawford-Yurukoglu 2012)
```

### Alternating Offers (Rubinstein 1982)

The unique SPE of the Rubinstein alternating-offers game is:

```
Proposer gets:   s_1* = 1 / (1 + δ_2)
Responder gets:  s_2* = δ_2 / (1 + δ_2)
```

As δ_1 = δ_2 = δ → 1: s_1* → 1/2 (equal split). This converges to Nash bargaining with equal weights as bargaining frictions vanish.

**For structural estimation:** The alternating-offers model provides micro-foundations for the generalized Nash bargaining solution. With δ_1 ≠ δ_2, the equilibrium shares are:

```
s_1* = (1 - δ_2) / (1 - δ_1 * δ_2)
s_2* = δ_2 * (1 - δ_1) / (1 - δ_1 * δ_2)
```

Estimating δ_1 and δ_2 separately requires variation in outside options and costs that affects each party asymmetrically.

---

## Auction Models: Game-Theoretic Foundations

Auction estimation is covered in detail in the `structural-modeling` skill. Here we focus on the game-theoretic foundations and the connection to the BNE framework.

**First-price sealed-bid auctions (FPSB):** A Bayesian game where each bidder i has private value v_i ~ F independently. The unique symmetric BNE bid function is:

```
b*(v) = E[v_{(N-1)} | v_{(N-1)} < v] = v - ∫_v_low^v G(t)^{N-1} dt / G(v)^{N-1}
```

where G(·) is the CDF of the value distribution. GPV (Guerre, Perrigne, Vuong 2000) inverts this to recover F from observed bids — a key application of BNE inversion.

**Second-price / ascending auctions (SPSB):** Dominant strategy for each bidder is to bid their true value. Observed transaction prices equal the second-highest value, making identification straightforward under IPV.

**Common value auctions:** Bidders share a common unknown value; their signals are correlated. The winner's curse — the winner draws an upward-biased signal — must be accounted for. Identification requires separating the signal distribution from the common value distribution (Hendricks-Porter 1988, Li-Perrigne-Vuong 2002).

**Affiliated values (Milgrom-Weber 1982):** Values and signals are affiliated (positive dependence). Predicts: ascending auction revenue > second-price > first-price. Revenue equivalence breaks down. Structural estimation with affiliation is substantially harder.
