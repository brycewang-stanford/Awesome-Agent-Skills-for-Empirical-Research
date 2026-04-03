---
name: general-equilibrium-model-builder
description: Build and solve Walrasian general equilibrium models with theory derivations and Julia computation
workflow_stage: theory
compatibility:
  - claude-code
  - cursor
  - codex
  - gemini-cli
author: Abhimanyu Nag <abhi.nag1601@gmail.com>
version: 1.0.0
tags:
  - general-equilibrium
  - walrasian
  - microeconomic-theory
  - julia
  - computational-economics
  - welfare-economics
  - pure-exchange
---

# General Equilibrium Model Builder

## Purpose

This skill helps economists build, analyze, and numerically solve **Walrasian General Equilibrium (GE)** models. It covers both the theoretical foundations (existence, uniqueness, welfare theorems) and computational implementation in Julia for finding equilibrium prices and allocations.

**Current Scope**: Pure exchange economies (no production). Future versions will extend to production economies, Arrow-Debreu with uncertainty, and dynamic models.

## When to Use

- **Theory Development**: Formalizing a pure exchange GE model for a paper
- **Teaching**: Creating examples for microeconomic theory courses
- **Computation**: Numerically solving for equilibrium prices and allocations
- **Welfare Analysis**: Evaluating Pareto efficiency and social welfare
- **Comparative Statics**: Analyzing how equilibrium changes with parameters

## Instructions

### Step 1: Understand the Economic Environment

Before generating any model, ask the user:

1. **Number of goods** ($L$): How many commodities in the economy?
2. **Number of consumers** ($I$): How many agents?
3. **Preferences**: What utility functions? (Cobb-Douglas, CES, Leontief, quasilinear)
4. **Endowments**: What is each agent's initial endowment vector?
5. **Output format**: Theory derivation, Julia code, or both?

### Step 2: Set Up the Theoretical Framework

A **pure exchange economy** $\mathcal{E}$ is characterized by:

$$\mathcal{E} = \left\{ (u^i, \omega^i)_{i=1}^{I} \right\}$$

where:
- $u^i: \mathbb{R}^L_+ \to \mathbb{R}$ is consumer $i$'s utility function
- $\omega^i \in \mathbb{R}^L_+$ is consumer $i$'s endowment vector
- $L$ is the number of goods
- $I$ is the number of consumers

**Consumer's Problem**: Given prices $p \in \mathbb{R}^L_{++}$, consumer $i$ solves:

$$\max_{x^i \in \mathbb{R}^L_+} u^i(x^i) \quad \text{s.t.} \quad p \cdot x^i \leq p \cdot \omega^i$$

The solution yields the **Marshallian demand** $x^i(p, p \cdot \omega^i)$.

### Step 3: Define Walrasian Equilibrium

**Definition (Walrasian Equilibrium)**: An allocation $(x^{*1}, \ldots, x^{*I})$ and price vector $p^* \in \mathbb{R}^L_{++}$ constitute a Walrasian equilibrium if:

1. **Utility Maximization**: For each $i$, $x^{*i}$ solves consumer $i$'s problem at prices $p^*$
2. **Market Clearing**: $\sum_{i=1}^{I} x^{*i} = \sum_{i=1}^{I} \omega^i$

Equivalently, the **excess demand function** $z(p) = \sum_{i=1}^{I} [x^i(p) - \omega^i]$ satisfies $z(p^*) = 0$.

### Step 4: State Key Theoretical Results

Include the following theorems as appropriate:

**Theorem (Walras' Law)**: For any price vector $p$:
$$p \cdot z(p) = 0$$

*Interpretation*: The value of excess demand is always zero (budget constraints bind).

**Theorem (First Welfare Theorem)**: Every Walrasian equilibrium allocation is Pareto efficient.

**Theorem (Second Welfare Theorem)**: Under convexity assumptions, any Pareto efficient allocation can be supported as a Walrasian equilibrium with appropriate lump-sum transfers.

**Theorem (Existence - Debreu, 1959)**: Under standard assumptions (continuity, strict convexity, strict monotonicity of preferences, strictly positive endowments), a Walrasian equilibrium exists.

### Step 5: Generate Julia Code for Computation

Use Julia with the following structure:

```julia
# ============================================
# General Equilibrium Solver in Julia
# Pure Exchange Economy
# ============================================

using LinearAlgebra
using NLsolve
using Plots

# Define the economy structure
struct PureExchangeEconomy
    n_goods::Int              # Number of goods (L)
    n_consumers::Int          # Number of consumers (I)
    endowments::Matrix{Float64}  # I × L matrix of endowments
    utility_params::Vector{Any}  # Parameters for utility functions
    utility_type::Symbol      # :cobb_douglas, :ces, :leontief
end

# Cobb-Douglas utility: u(x) = ∏ x_l^α_l
function utility_cobb_douglas(x, α)
    return prod(x .^ α)
end

# Marshallian demand for Cobb-Douglas preferences
function demand_cobb_douglas(p, wealth, α)
    # x_l = (α_l / sum(α)) * (wealth / p_l)
    α_normalized = α / sum(α)
    return α_normalized .* wealth ./ p
end

# Excess demand function
function excess_demand(p, economy::PureExchangeEconomy)
    z = zeros(economy.n_goods)
    
    for i in 1:economy.n_consumers
        ω_i = economy.endowments[i, :]
        wealth_i = dot(p, ω_i)
        
        if economy.utility_type == :cobb_douglas
            α_i = economy.utility_params[i]
            x_i = demand_cobb_douglas(p, wealth_i, α_i)
        else
            error("Unsupported utility_type: $(economy.utility_type). Only :cobb_douglas is currently implemented.")
        end
        
        z += x_i - ω_i
    end
    
    return z
end

# Solve for equilibrium prices (normalize p_1 = 1)
# Uses log-price parameterization to ensure prices remain strictly positive
function solve_equilibrium(economy::PureExchangeEconomy)
    # Initial guess in log-space (log of ones = zeros)
    p0 = zeros(economy.n_goods - 1)
    
    # Excess demand for goods 2 to L (Walras' Law implies good 1 clears)
    # Reparameterize using log-prices: y = log(p_rest), so p_rest = exp(y)
    function excess_demand_reduced!(F, y)
        p_rest = exp.(y)  # Exponentiate to get positive prices
        p = vcat(1.0, p_rest)  # Numeraire p_1 = 1
        z = excess_demand(p, economy)
        F .= z[2:end]
    end
    
    # Solve z(p) = 0 in log-space
    result = nlsolve(excess_demand_reduced!, p0, autodiff=:forward)
    
    if converged(result)
        p_rest_star = exp.(result.zero)  # Convert back from log-space
        p_star = vcat(1.0, p_rest_star)
        return p_star
    else
        error("Equilibrium solver did not converge")
    end
end

# Compute equilibrium allocations
function equilibrium_allocations(p_star, economy::PureExchangeEconomy)
    allocations = zeros(economy.n_consumers, economy.n_goods)
    
    for i in 1:economy.n_consumers
        ω_i = economy.endowments[i, :]
        wealth_i = dot(p_star, ω_i)
        
        if economy.utility_type == :cobb_douglas
            α_i = economy.utility_params[i]
            allocations[i, :] = demand_cobb_douglas(p_star, wealth_i, α_i)
        else
            throw(ArgumentError("Unsupported utility_type: $(economy.utility_type) in equilibrium_allocations. Only :cobb_douglas is currently implemented."))
        end
    end
    
    return allocations
end

# Check Pareto efficiency via MRS equality
function check_pareto_efficiency(allocations, economy::PureExchangeEconomy)
    # Currently only supports 2-good economies
    if economy.n_goods != 2
        throw(ArgumentError("check_pareto_efficiency currently only supports 2-good economies. Got economy.n_goods = $(economy.n_goods)."))
    end
    
    if economy.utility_type == :cobb_douglas
        # MRS_{12} = (α_1/α_2) * (x_2/x_1) should be equal for all consumers
        epsilon = 1e-12  # Small threshold for near-zero detection
        mrs_values = []
        
        for i in 1:economy.n_consumers
            α_i = economy.utility_params[i]
            x_i = allocations[i, :]
            
            # Guard against division by zero: check both x_i[1] and α_i[2]
            if abs(x_i[1]) < epsilon || abs(α_i[2]) < epsilon
                # Handle corner case: set sentinel value for zero/near-zero consumption
                push!(mrs_values, Inf)
            else
                mrs_i = (α_i[1] / α_i[2]) * (x_i[2] / x_i[1])
                push!(mrs_values, mrs_i)
            end
        end
        
        return mrs_values
    else
        throw(ArgumentError("Unsupported utility type: $(economy.utility_type) in check_pareto_efficiency. Only :cobb_douglas is currently implemented."))
    end
end
```

### Step 6: Provide Complete Example

```julia
# ============================================
# Example: 2×2 Pure Exchange Economy
# ============================================

# Two consumers, two goods
# Consumer 1: u(x,y) = x^0.6 * y^0.4, endowment (4, 1)
# Consumer 2: u(x,y) = x^0.3 * y^0.7, endowment (1, 4)

economy = PureExchangeEconomy(
    2,                           # 2 goods
    2,                           # 2 consumers
    [4.0 1.0; 1.0 4.0],         # Endowment matrix
    [[0.6, 0.4], [0.3, 0.7]],   # Cobb-Douglas parameters
    :cobb_douglas
)

# Solve for equilibrium
p_star = solve_equilibrium(economy)
println("Equilibrium prices: p = ", p_star)

# Compute allocations
x_star = equilibrium_allocations(p_star, economy)
println("Consumer 1 allocation: ", x_star[1, :])
println("Consumer 2 allocation: ", x_star[2, :])

# Verify market clearing
total_endowment = sum(economy.endowments, dims=1)
total_allocation = sum(x_star, dims=1)
println("Market clearing check: ", isapprox(total_endowment, total_allocation))

# Check Pareto efficiency (MRS equality)
mrs = check_pareto_efficiency(x_star, economy)
println("MRS values (should be equal): ", mrs)
```

### Step 7: Visualize with Edgeworth Box

```julia
# ============================================
# Edgeworth Box Visualization
# ============================================

function plot_edgeworth_box(economy::PureExchangeEconomy, p_star, x_star)
    # Total endowment defines box dimensions
    ω_total = vec(sum(economy.endowments, dims=1))
    
    # Create plot
    plt = plot(
        xlim=(0, ω_total[1]),
        ylim=(0, ω_total[2]),
        xlabel="Good 1",
        ylabel="Good 2",
        title="Edgeworth Box",
        legend=:topright,
        aspect_ratio=:equal
    )
    
    # Plot endowment point
    ω1 = economy.endowments[1, :]
    scatter!([ω1[1]], [ω1[2]], label="Endowment", markersize=8, color=:red)
    
    # Plot equilibrium allocation
    scatter!([x_star[1, 1]], [x_star[1, 2]], label="Equilibrium", markersize=8, color=:green)
    
    # Plot budget line through endowment
    # p_1 * x_1 + p_2 * x_2 = p_1 * ω_1 + p_2 * ω_2
    wealth1 = dot(p_star, ω1)
    x1_range = range(0, ω_total[1], length=100)
    x2_budget = (wealth1 .- p_star[1] .* x1_range) ./ p_star[2]
    plot!(x1_range, x2_budget, label="Budget line", color=:blue, linewidth=2)
    
    # Plot contract curve (locus of Pareto efficient allocations)
    # For Cobb-Douglas, contract curve: x_2^1 / x_1^1 = (α_2^1/α_1^1) / (α_2^2/α_1^2) * (ω_2 - x_2^1) / (ω_1 - x_1^1)
    
    return plt
end

# Generate the plot
plt = plot_edgeworth_box(economy, p_star, x_star)
savefig(plt, "edgeworth_box.png")
```

## Example Prompts

Users might invoke this skill with prompts like:

- "Set up a 2-good, 3-consumer pure exchange economy with CES preferences"
- "Derive the Walrasian equilibrium conditions for a Cobb-Douglas economy"
- "Write Julia code to solve for equilibrium prices in my exchange economy"
- "Prove the First Welfare Theorem for a pure exchange economy"
- "Plot an Edgeworth box showing the contract curve and equilibrium"
- "Compute comparative statics: how does equilibrium change if endowments shift?"

## Requirements

### Software

- Julia 1.9+

### Packages

```julia
using Pkg
Pkg.add(["NLsolve", "LinearAlgebra", "Plots", "ForwardDiff"])
```

| Package | Purpose |
|---------|---------|
| `NLsolve` | Nonlinear equation solver for excess demand = 0 |
| `LinearAlgebra` | Vector/matrix operations |
| `Plots` | Visualization (Edgeworth box, etc.) |
| `ForwardDiff` | Automatic differentiation for Jacobians |

## Mathematical Background

### Assumptions for Existence

Standard assumptions ensuring equilibrium existence:

1. **Continuity**: Each $u^i$ is continuous
2. **Strict Monotonicity**: $x \gg y \Rightarrow u^i(x) > u^i(y)$
3. **Strict Convexity**: $u^i$ is strictly quasiconcave
4. **Positive Endowments**: $\omega^i \gg 0$ for all $i$

### Properties of Excess Demand

Under standard assumptions, $z(p)$ satisfies:

1. **Continuity**: $z$ is continuous
2. **Homogeneity of degree 0**: $z(\lambda p) = z(p)$ for all $\lambda > 0$
3. **Walras' Law**: $p \cdot z(p) = 0$
4. **Boundary behavior**: If $p_l \to 0$, then $z_l(p) \to +\infty$

### Numerical Solution Strategy

1. **Normalize prices**: Set $p_1 = 1$ (numeraire)
2. **Reduce dimension**: Solve $z_2(p) = \cdots = z_L(p) = 0$ (Walras' Law gives $z_1 = 0$)
3. **Use Newton's method**: `NLsolve.jl` with autodiff for Jacobian
4. **Handle boundaries**: Ensure $p_l > 0$ during iteration

## Best Practices

1. **Always verify market clearing** after solving
2. **Check Walras' Law** holds numerically ($p \cdot z \approx 0$)
3. **Verify Pareto efficiency** by checking MRS equality across consumers
4. **Use multiple initial guesses** if solver doesn't converge
5. **Normalize prices** to avoid indeterminacy (homogeneity of degree 0)

## Common Pitfalls

- ❌ Forgetting that prices are only determined up to a scalar (must normalize)
- ❌ Not checking for corner solutions (zero consumption of some good)
- ❌ Ignoring numerical precision issues near boundaries
- ❌ Assuming uniqueness without verifying (multiple equilibria are possible)
- ❌ Confusing Marshallian (uncompensated) and Hicksian (compensated) demands

## Extensions (Future Versions)

- **Production economies**: Firms with profit maximization
- **Arrow-Debreu securities**: Contingent claims and uncertainty
- **Overlapping generations (OLG)**: Dynamic GE with generational overlap
- **Computable GE (CGE)**: Calibrated models for policy analysis
- **Incomplete markets**: When not all contingencies can be traded

## References

### Textbooks

- Mas-Colell, Whinston, and Green (1995). *Microeconomic Theory*. Oxford University Press. Chapters 15-17.
- Debreu, G. (1959). *Theory of Value*. Yale University Press.
- Varian, H. (1992). *Microeconomic Analysis*. 3rd Edition. Chapters 17-18.

### Computational Resources

- QuantEcon Julia lectures: [https://julia.quantecon.org/](https://julia.quantecon.org/)
- Judd, K. (1998). *Numerical Methods in Economics*. MIT Press.

### Key Papers

- Arrow, K. J., & Debreu, G. (1954). Existence of an equilibrium for a competitive economy. *Econometrica*, 22(3), 265-290.
- Scarf, H. (1967). The approximation of fixed points of a continuous mapping. *SIAM Journal on Applied Mathematics*, 15(5), 1328-1343.

## Changelog

### v1.0.0

- Initial release: Pure exchange economies with Cobb-Douglas preferences
- Julia implementation with NLsolve
- Edgeworth box visualization
- Theoretical framework and welfare theorems
