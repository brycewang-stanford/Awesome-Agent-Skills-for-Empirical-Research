# ============================================
# General Equilibrium Solver in Julia
# Pure Exchange Economy - 2 Goods, 2 Consumers
# ============================================
# Author: Abhimanyu Nag
# Skill: general-equilibrium-model-builder v1.0.0
# 
# This example demonstrates solving a Walrasian equilibrium
# for a 2×2 pure exchange economy with Cobb-Douglas preferences.
# ============================================

using LinearAlgebra
using NLsolve
using Plots
using Printf

# ============================================
# Economy Structure
# ============================================

"""
    PureExchangeEconomy

A pure exchange economy with I consumers and L goods.

# Fields
- `n_goods::Int`: Number of goods (L)
- `n_consumers::Int`: Number of consumers (I)  
- `endowments::Matrix{Float64}`: I × L matrix of initial endowments
- `utility_params::Vector{Vector{Float64}}`: Utility function parameters for each consumer
- `utility_type::Symbol`: Type of utility function (:cobb_douglas, :ces, :leontief)
"""
struct PureExchangeEconomy
    n_goods::Int
    n_consumers::Int
    endowments::Matrix{Float64}
    utility_params::Vector{Vector{Float64}}
    utility_type::Symbol
end

# ============================================
# Utility Functions
# ============================================

"""
    utility_cobb_douglas(x, α)

Compute Cobb-Douglas utility: u(x) = ∏ᵢ xᵢ^αᵢ

# Arguments
- `x`: Consumption bundle (vector of length L)
- `α`: Preference parameters (vector of length L, αᵢ > 0)

# Returns
- Utility value (scalar)
"""
function utility_cobb_douglas(x::Vector{Float64}, α::Vector{Float64})
    return prod(x .^ α)
end

"""
    marginal_utility_cobb_douglas(x, α)

Compute marginal utilities for Cobb-Douglas preferences.

# Returns
- Vector of marginal utilities ∂u/∂xₗ
"""
function marginal_utility_cobb_douglas(x::Vector{Float64}, α::Vector{Float64})
    u = utility_cobb_douglas(x, α)
    return α .* u ./ x
end

# ============================================
# Demand Functions
# ============================================

"""
    demand_cobb_douglas(p, wealth, α)

Compute Marshallian demand for Cobb-Douglas preferences.

For u(x) = ∏ xₗ^αₗ, the optimal demand is:
    xₗ = (αₗ / Σα) × (wealth / pₗ)

# Arguments
- `p`: Price vector
- `wealth`: Consumer's wealth (p · ω)
- `α`: Preference parameters

# Returns
- Optimal consumption bundle
"""
function demand_cobb_douglas(p::Vector{Float64}, wealth::Float64, α::Vector{Float64})
    α_normalized = α / sum(α)
    return α_normalized .* wealth ./ p
end

# ============================================
# Excess Demand
# ============================================

"""
    excess_demand(p, economy)

Compute aggregate excess demand z(p) = Σᵢ [xᵢ(p) - ωᵢ]

# Arguments
- `p`: Price vector
- `economy`: PureExchangeEconomy struct

# Returns
- Excess demand vector (length L)
"""
function excess_demand(p::Vector{Float64}, economy::PureExchangeEconomy)
    z = zeros(economy.n_goods)
    
    for i in 1:economy.n_consumers
        ω_i = economy.endowments[i, :]
        wealth_i = dot(p, ω_i)
        
        if economy.utility_type == :cobb_douglas
            α_i = economy.utility_params[i]
            x_i = demand_cobb_douglas(p, wealth_i, α_i)
        else
            error("Utility type $(economy.utility_type) not implemented")
        end
        
        z += x_i - ω_i
    end
    
    return z
end

"""
    verify_walras_law(p, economy)

Verify that Walras' Law holds: p · z(p) = 0
"""
function verify_walras_law(p::Vector{Float64}, economy::PureExchangeEconomy)
    z = excess_demand(p, economy)
    return dot(p, z)
end

# ============================================
# Equilibrium Solver
# ============================================

"""
    solve_equilibrium(economy; p0=nothing, tol=1e-10)

Solve for Walrasian equilibrium prices.

We normalize p₁ = 1 (numeraire) and solve z₂(p) = ⋯ = zₗ(p) = 0.
By Walras' Law, z₁(p) = 0 automatically.

# Arguments
- `economy`: PureExchangeEconomy struct
- `p0`: Initial price guess (optional)
- `tol`: Convergence tolerance

# Returns
- `p_star`: Equilibrium price vector
"""
function solve_equilibrium(economy::PureExchangeEconomy; p0=nothing, tol=1e-10)
    if p0 === nothing
        p0 = ones(economy.n_goods - 1)
    end
    
    function excess_demand_reduced!(F, p_rest)
        p = vcat(1.0, p_rest)  # Numeraire p₁ = 1
        z = excess_demand(p, economy)
        F .= z[2:end]
    end
    
    result = nlsolve(excess_demand_reduced!, p0, autodiff=:forward, ftol=tol)
    
    if converged(result)
        p_star = vcat(1.0, result.zero)
        return p_star
    else
        error("Equilibrium solver did not converge. Try different initial guess.")
    end
end

# ============================================
# Equilibrium Analysis
# ============================================

"""
    equilibrium_allocations(p_star, economy)

Compute equilibrium consumption allocations for all consumers.

# Returns
- I × L matrix of allocations
"""
function equilibrium_allocations(p_star::Vector{Float64}, economy::PureExchangeEconomy)
    allocations = zeros(economy.n_consumers, economy.n_goods)
    
    for i in 1:economy.n_consumers
        ω_i = economy.endowments[i, :]
        wealth_i = dot(p_star, ω_i)
        
        if economy.utility_type == :cobb_douglas
            α_i = economy.utility_params[i]
            allocations[i, :] = demand_cobb_douglas(p_star, wealth_i, α_i)
        else
            error("Unsupported utility_type: $(economy.utility_type). Only :cobb_douglas is currently implemented.")
        end
    end
    
    return allocations
end

"""
    compute_utilities(allocations, economy)

Compute utility levels at given allocations.
"""
function compute_utilities(allocations::Matrix{Float64}, economy::PureExchangeEconomy)
    utilities = zeros(economy.n_consumers)
    
    for i in 1:economy.n_consumers
        x_i = allocations[i, :]
        if economy.utility_type == :cobb_douglas
            α_i = economy.utility_params[i]
            utilities[i] = utility_cobb_douglas(x_i, α_i)
        else
            throw(ArgumentError("Unsupported utility_type: $(economy.utility_type). Only :cobb_douglas is currently implemented."))
        end
    end
    
    return utilities
end

"""
    check_pareto_efficiency(allocations, economy)

Verify Pareto efficiency by checking MRS equality across consumers.

For Cobb-Douglas: MRS₁₂ = (α₁/α₂) × (x₂/x₁)
At Pareto efficient allocations, MRS is equal for all consumers.

# Returns
- Vector of MRS values for each consumer (should all be equal)
"""
function check_pareto_efficiency(allocations::Matrix{Float64}, economy::PureExchangeEconomy)
    if economy.utility_type == :cobb_douglas && economy.n_goods >= 2
        mrs_values = Float64[]
        
        for i in 1:economy.n_consumers
            α_i = economy.utility_params[i]
            x_i = allocations[i, :]
            
            # MRS between goods 1 and 2
            mrs_i = (α_i[1] / α_i[2]) * (x_i[2] / x_i[1])
            push!(mrs_values, mrs_i)
        end
        
        return mrs_values
    else
        return nothing
    end
end

# ============================================
# Visualization: Edgeworth Box
# ============================================

"""
    plot_edgeworth_box(economy, p_star, x_star; show_indifference=true)

Create an Edgeworth box diagram showing:
- Initial endowment point
- Equilibrium allocation
- Budget line
- Indifference curves (optional)
- Contract curve

Only works for 2-good, 2-consumer economies.
"""
function plot_edgeworth_box(
    economy::PureExchangeEconomy, 
    p_star::Vector{Float64}, 
    x_star::Matrix{Float64};
    show_indifference::Bool = true
)
    if economy.n_goods != 2 || economy.n_consumers != 2
        error("Edgeworth box only works for 2×2 economies")
    end
    
    # Total endowment defines box dimensions
    ω_total = vec(sum(economy.endowments, dims=1))
    
    # Consumer 1's endowment and equilibrium allocation
    ω1 = economy.endowments[1, :]
    x1_star = x_star[1, :]
    
    # Create plot
    plt = plot(
        xlim=(0, ω_total[1] * 1.05),
        ylim=(0, ω_total[2] * 1.05),
        xlabel="Good 1 (Consumer 1 →)",
        ylabel="Good 2 (Consumer 1 →)",
        title="Edgeworth Box: Walrasian Equilibrium",
        legend=:topright,
        size=(700, 600),
        grid=true,
        gridalpha=0.3
    )
    
    # Draw box outline
    plot!([0, ω_total[1], ω_total[1], 0, 0], 
          [0, 0, ω_total[2], ω_total[2], 0], 
          color=:black, linewidth=2, label="")
    
    # Budget line through endowment
    wealth1 = dot(p_star, ω1)
    x1_range = range(0, ω_total[1], length=200)
    x2_budget = (wealth1 .- p_star[1] .* x1_range) ./ p_star[2]
    
    # Filter to box bounds
    valid = (x2_budget .>= 0) .& (x2_budget .<= ω_total[2])
    plot!(x1_range[valid], x2_budget[valid], 
          label="Budget Line", color=:blue, linewidth=2.5, linestyle=:dash)
    
    if show_indifference
        # Consumer 1's indifference curve through equilibrium
        α1 = economy.utility_params[1]
        u1_star = utility_cobb_douglas(x1_star, α1)
        
        x1_ic = range(0.01, ω_total[1], length=200)
        # u = x₁^α₁ × x₂^α₂ → x₂ = (u / x₁^α₁)^(1/α₂)
        x2_ic1 = (u1_star ./ (x1_ic .^ α1[1])) .^ (1/α1[2])
        valid1 = (x2_ic1 .>= 0) .& (x2_ic1 .<= ω_total[2])
        plot!(x1_ic[valid1], x2_ic1[valid1], 
              label="IC Consumer 1", color=:red, linewidth=1.5, alpha=0.7)
        
        # Consumer 2's indifference curve (from their origin at top-right)
        α2 = economy.utility_params[2]
        x2_star = x_star[2, :]
        u2_star = utility_cobb_douglas(x2_star, α2)
        
        # Consumer 2's coordinates: (ω_total - x1)
        x2_2_ic = range(0.01, ω_total[1], length=200)
        y2_ic = (u2_star ./ (x2_2_ic .^ α2[1])) .^ (1/α2[2])
        # Transform to Consumer 1's coordinates
        x1_from_2 = ω_total[1] .- x2_2_ic
        y1_from_2 = ω_total[2] .- y2_ic
        valid2 = (y1_from_2 .>= 0) .& (y1_from_2 .<= ω_total[2]) .& (x1_from_2 .>= 0)
        plot!(x1_from_2[valid2], y1_from_2[valid2], 
              label="IC Consumer 2", color=:orange, linewidth=1.5, alpha=0.7)
    end
    
    # Contract curve (locus of Pareto efficient allocations)
    # For Cobb-Douglas, derived from MRS equality
    α1, α2 = economy.utility_params[1], economy.utility_params[2]
    a = α1[1] / α1[2]  # Consumer 1's MRS coefficient
    b = α2[1] / α2[2]  # Consumer 2's MRS coefficient
    
    x1_cc = range(0.01, ω_total[1] - 0.01, length=200)
    # Contract curve: x₂¹/x₁¹ × a = (ω₂ - x₂¹)/(ω₁ - x₁¹) × b
    # Solving for x₂¹:
    x2_cc = (a .* ω_total[2] .* x1_cc) ./ (b .* (ω_total[1] .- x1_cc) .+ a .* x1_cc)
    
    valid_cc = (x2_cc .>= 0) .& (x2_cc .<= ω_total[2])
    plot!(x1_cc[valid_cc], x2_cc[valid_cc], 
          label="Contract Curve", color=:green, linewidth=2)
    
    # Plot points
    scatter!([ω1[1]], [ω1[2]], 
             label="Endowment (ω)", markersize=10, color=:red, markershape=:diamond)
    scatter!([x1_star[1]], [x1_star[2]], 
             label="Equilibrium (x*)", markersize=10, color=:green, markershape=:circle)
    
    # Add second axis labels at top-right
    annotate!(ω_total[1], ω_total[2] + 0.15, 
              text("← Consumer 2", 8, :right))
    
    return plt
end

# ============================================
# MAIN: Run Example Economy
# ============================================

function main()
    println("=" ^ 60)
    println("WALRASIAN GENERAL EQUILIBRIUM: 2×2 PURE EXCHANGE ECONOMY")
    println("=" ^ 60)
    println()
    
    # Define the economy
    # Consumer 1: u(x,y) = x^0.6 × y^0.4, endowment (4, 1)
    # Consumer 2: u(x,y) = x^0.3 × y^0.7, endowment (1, 4)
    
    economy = PureExchangeEconomy(
        2,                                    # 2 goods
        2,                                    # 2 consumers
        [4.0 1.0; 1.0 4.0],                  # Endowment matrix (I × L)
        [[0.6, 0.4], [0.3, 0.7]],            # Cobb-Douglas parameters
        :cobb_douglas
    )
    
    println("ECONOMY SPECIFICATION")
    println("-" ^ 40)
    println("Number of goods: ", economy.n_goods)
    println("Number of consumers: ", economy.n_consumers)
    println("Utility type: Cobb-Douglas")
    println()
    
    for i in 1:economy.n_consumers
        α = economy.utility_params[i]
        ω = economy.endowments[i, :]
        println("Consumer $i:")
        println("  Utility: u(x₁,x₂) = x₁^$(α[1]) × x₂^$(α[2])")
        println("  Endowment: ω = ($(ω[1]), $(ω[2]))")
    end
    
    println()
    println("TOTAL RESOURCES")
    println("-" ^ 40)
    total = vec(sum(economy.endowments, dims=1))
    println("Total endowment: ($(total[1]), $(total[2]))")
    
    # Solve for equilibrium
    println()
    println("SOLVING FOR WALRASIAN EQUILIBRIUM...")
    println("-" ^ 40)
    
    p_star = solve_equilibrium(economy)
    x_star = equilibrium_allocations(p_star, economy)
    
    @printf("Equilibrium prices: p* = (%.4f, %.4f)\n", p_star[1], p_star[2])
    @printf("Relative price p₂/p₁ = %.4f\n", p_star[2] / p_star[1])
    println()
    
    println("EQUILIBRIUM ALLOCATIONS")
    println("-" ^ 40)
    for i in 1:economy.n_consumers
        x_i = x_star[i, :]
        @printf("Consumer %d: x* = (%.4f, %.4f)\n", i, x_i[1], x_i[2])
    end
    
    # Verify market clearing
    println()
    println("VERIFICATION")
    println("-" ^ 40)
    
    total_alloc = vec(sum(x_star, dims=1))
    @printf("Total allocation: (%.4f, %.4f)\n", total_alloc[1], total_alloc[2])
    @printf("Total endowment:  (%.4f, %.4f)\n", total[1], total[2])
    
    market_clears = isapprox(total_alloc, total, atol=1e-8)
    println("Market clearing: ", market_clears ? "✓ YES" : "✗ NO")
    
    # Check Walras' Law
    walras_value = verify_walras_law(p_star, economy)
    @printf("Walras' Law (p·z should be 0): %.2e\n", walras_value)
    
    # Check Pareto efficiency
    mrs_values = check_pareto_efficiency(x_star, economy)
    println()
    println("PARETO EFFICIENCY CHECK")
    println("-" ^ 40)
    for i in 1:economy.n_consumers
        @printf("Consumer %d MRS₁₂ = %.4f\n", i, mrs_values[i])
    end
    
    mrs_equal = isapprox(mrs_values[1], mrs_values[2], atol=1e-8)
    println("MRS equality (Pareto efficient): ", mrs_equal ? "✓ YES" : "✗ NO")
    
    # Compute utility levels
    println()
    println("WELFARE ANALYSIS")
    println("-" ^ 40)
    
    # Utility at endowment
    u_endow = compute_utilities(economy.endowments, economy)
    # Utility at equilibrium
    u_equil = compute_utilities(x_star, economy)
    
    for i in 1:economy.n_consumers
        @printf("Consumer %d: u(ω)=%.4f → u(x*)=%.4f (gain: %.1f%%)\n", 
                i, u_endow[i], u_equil[i], 100*(u_equil[i]/u_endow[i] - 1))
    end
    
    # Create Edgeworth box
    println()
    println("GENERATING EDGEWORTH BOX DIAGRAM...")
    println("-" ^ 40)
    
    plt = plot_edgeworth_box(economy, p_star, x_star, show_indifference=true)
    
    savefig(plt, "edgeworth_box_equilibrium.png")
    println("Saved: edgeworth_box_equilibrium.png")
    
    display(plt)
    
    println()
    println("=" ^ 60)
    println("EQUILIBRIUM ANALYSIS COMPLETE")
    println("=" ^ 60)
    
    return economy, p_star, x_star
end

# Run if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
