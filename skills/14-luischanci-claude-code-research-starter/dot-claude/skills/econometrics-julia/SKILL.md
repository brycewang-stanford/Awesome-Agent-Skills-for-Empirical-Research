---
name: econometrics-julia
description: Julia-based econometric and structural estimation for computationally intensive tasks. Use for structural models, maximum likelihood, GMM, numerical optimization, simulations, and high-performance computing. Covers DataFrames.jl, FixedEffectModels.jl, Optim.jl, and performance optimization.
---

# Julia Econometrics & Structural Estimation

## Core Packages
```julia
using DataFrames, CSV       # Data handling
using FixedEffectModels     # Panel regressions
using Optim                 # Optimization
using Distributions         # Probability distributions
using LinearAlgebra         # Matrix operations
using ForwardDiff           # Automatic differentiation
using Statistics, StatsBase
```

## Data Handling (DataFrames.jl)
```julia
# Read data
df = CSV.read("data/raw/file.csv", DataFrame)

# Basic operations
transform!(df, :x => (x -> x .* 100) => :x_scaled)
subset!(df, :year => y -> y .>= 2000)

# Groupby operations
gdf = groupby(df, :id)
combine(gdf, :y => mean => :mean_y, nrow => :n)

# Efficient joins
leftjoin!(df, other_df, on = [:id, :year])
```

## Panel Regressions (FixedEffectModels.jl)
```julia
# Two-way fixed effects
est = reg(df, @formula(y ~ treatment + fe(id) + fe(year)), 
          Vcov.cluster(:state))

# IV estimation
est_iv = reg(df, @formula(y ~ (endog ~ instrument) + fe(id) + fe(year)))

# Extract results
coef(est)        # Coefficients
vcov(est)        # Variance-covariance matrix
nobs(est)        # Observations
r2(est)          # R-squared
```

## Performance Optimization

### Memory Efficiency
```julia
# Use views instead of copies
@views y_subset = df.y[1:100]

# Preallocate arrays
result = zeros(n, m)
@inbounds for i in 1:n
    result[i, :] .= compute_row(i)
end

# Use StaticArrays for small fixed-size arrays
using StaticArrays
params = SVector{3, Float64}(1.0, 2.0, 3.0)
```

### Broadcasting and Vectorization
```julia
# Good: fused broadcasting
@. result = x^2 + y^2 + z  # Single pass

# Avoid: creates intermediates
result = x.^2 .+ y.^2 .+ z  # Multiple allocations
```

### Type Stability
```julia
# Always annotate function return types for critical code
function likelihood(θ::Vector{Float64}, data::Matrix{Float64})::Float64
    # Implementation
end

# Use concrete types in structs
struct ModelParams{T<:Real}
    α::T
    β::T
    σ::T
end
```

## Structural Estimation

### Maximum Likelihood
```julia
function log_likelihood(θ, data)
    α, β, σ = θ
    y, X = data[:, 1], data[:, 2:end]
    
    resid = y .- X * [α, β]
    ll = -0.5 * length(y) * log(2π * σ^2) - 
         sum(resid.^2) / (2σ^2)
    return -ll  # Minimize negative log-likelihood
end

# Optimize
θ0 = [0.0, 0.0, 1.0]
result = optimize(θ -> log_likelihood(θ, data), θ0, LBFGS(),
                  autodiff = :forward)

θ_hat = Optim.minimizer(result)
```

### Generalized Method of Moments (GMM)
```julia
function gmm_moments(θ, data, Z)
    α, β = θ
    y, X = data[:, 1], data[:, 2:end]
    resid = y .- X * [α, β]
    
    # Moment conditions: E[Z'ε] = 0
    moments = Z' * resid / size(Z, 1)
    return moments
end

function gmm_objective(θ, data, Z, W)
    g = gmm_moments(θ, data, Z)
    return g' * W * g
end

# Two-step GMM
W1 = I(size(Z, 2))  # First step: identity
θ1 = optimize(θ -> gmm_objective(θ, data, Z, W1), θ0).minimizer

# Optimal weighting matrix
Ω = cov(Z .* (data[:, 1] .- data[:, 2:end] * θ1))
W2 = inv(Ω)
θ2 = optimize(θ -> gmm_objective(θ, data, Z, W2), θ1).minimizer
```

### Simulation-Based Estimation (MSM/Indirect Inference)
```julia
function simulate_model(θ, N, S; seed=12345)
    Random.seed!(seed)
    α, β, σ = θ
    
    # Simulate S datasets of size N
    sims = Matrix{Float64}(undef, N, S)
    for s in 1:S
        X = randn(N)
        ε = σ * randn(N)
        sims[:, s] = α .+ β .* X .+ ε
    end
    return sims
end

function msm_objective(θ, data_moments, N, S)
    sims = simulate_model(θ, N, S)
    sim_moments = mean([compute_moments(sims[:, s]) for s in 1:S])
    diff = data_moments - sim_moments
    return diff' * diff
end
```

## Numerical Methods

### Root Finding (for equilibrium models)
```julia
using NLsolve

function excess_demand(p, params)
    # Market clearing conditions
    return demand(p, params) - supply(p, params)
end

result = nlsolve(p -> excess_demand(p, params), p0)
p_eq = result.zero
```

### Integration (for expected values)
```julia
using QuadGK

# One-dimensional
expected_value, err = quadgk(x -> x * pdf(Normal(μ, σ), x), -Inf, Inf)

# Multi-dimensional (Monte Carlo or sparse grids)
using HCubature
integral, err = hcubature(f, lower_bounds, upper_bounds)
```

## Parallel Computing
```julia
using Distributed
addprocs(4)

@everywhere using SharedArrays

# Parallel bootstrap
@distributed for b in 1:B
    bootstrap_sample = sample(1:N, N, replace=true)
    θ_boot[b] = estimate(data[bootstrap_sample, :])
end

# Or use Threads for shared memory
Threads.@threads for i in 1:N
    result[i] = compute(i)
end
```

## Standard Errors

### Bootstrap
```julia
function bootstrap_se(estimate_fn, data, B=1000)
    N = size(data, 1)
    θ_boot = [estimate_fn(data[sample(1:N, N, replace=true), :]) 
              for _ in 1:B]
    return std(θ_boot)
end
```

### Delta Method
```julia
using ForwardDiff

function delta_method_se(g, θ, Σ)
    # g: transformation function
    # θ: parameter estimates
    # Σ: variance-covariance of θ
    ∇g = ForwardDiff.gradient(g, θ)
    return sqrt(∇g' * Σ * ∇g)
end
```

## Best Practices
- Use `@time` and `@btime` (from BenchmarkTools) to profile
- Check type stability with `@code_warntype`
- Use `const` for global constants
- Prefer column-major iteration (Julia is column-major)
