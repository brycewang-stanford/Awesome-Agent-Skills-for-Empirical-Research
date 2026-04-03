# ============================================
# Comparative Statics in General Equilibrium
# How equilibrium changes with endowment shifts
# ============================================
# Author: Abhimanyu Nag
# Skill: general-equilibrium-model-builder v1.0.0
# ============================================

using LinearAlgebra
using NLsolve
using Plots
using Printf

# Include the core functions from pure_exchange_2x2.jl
# (In practice, you would use: include("pure_exchange_2x2.jl"))

# ============================================
# Replicate core structures (for standalone use)
# ============================================

struct PureExchangeEconomy
    n_goods::Int
    n_consumers::Int
    endowments::Matrix{Float64}
    utility_params::Vector{Vector{Float64}}
    utility_type::Symbol
end

function demand_cobb_douglas(p::Vector{Float64}, wealth::Float64, α::Vector{Float64})
    α_normalized = α / sum(α)
    return α_normalized .* wealth ./ p
end

function excess_demand(p::Vector{Float64}, economy::PureExchangeEconomy)
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

function solve_equilibrium(economy::PureExchangeEconomy; p0=nothing)
    if p0 === nothing
        p0 = ones(economy.n_goods - 1)
    end
    
    function excess_demand_reduced!(F, p_rest)
        p = vcat(1.0, p_rest)
        z = excess_demand(p, economy)
        F .= z[2:end]
    end
    
    result = nlsolve(excess_demand_reduced!, p0, autodiff=:forward)
    return converged(result) ? vcat(1.0, result.zero) : nothing
end

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

function utility_cobb_douglas(x::Vector{Float64}, α::Vector{Float64})
    return prod(x .^ α)
end

# ============================================
# Comparative Statics Functions
# ============================================

"""
    endowment_shock_analysis(base_economy, good, consumer, shock_range)

Analyze how equilibrium changes when one consumer's endowment of one good changes.

# Arguments
- `base_economy`: Baseline economy
- `good`: Which good's endowment to change (1 or 2)
- `consumer`: Which consumer receives the shock (1 or 2)
- `shock_range`: Vector of shock magnitudes (e.g., -2:0.5:2)

# Returns
- Dictionary with results for each shock value
"""
function endowment_shock_analysis(
    base_economy::PureExchangeEconomy,
    good::Int,
    consumer::Int,
    shock_range::AbstractVector
)
    results = Dict(
        :shock => Float64[],
        :price_ratio => Float64[],
        :allocation_1_good1 => Float64[],
        :allocation_1_good2 => Float64[],
        :allocation_2_good1 => Float64[],
        :allocation_2_good2 => Float64[],
        :utility_1 => Float64[],
        :utility_2 => Float64[]
    )
    
    for Δ in shock_range
        # Create shocked economy
        new_endowments = copy(base_economy.endowments)
        new_endowments[consumer, good] += Δ
        
        # Skip if endowment becomes non-positive
        if any(new_endowments .<= 0)
            continue
        end
        
        shocked_economy = PureExchangeEconomy(
            base_economy.n_goods,
            base_economy.n_consumers,
            new_endowments,
            base_economy.utility_params,
            base_economy.utility_type
        )
        
        # Solve equilibrium
        p_star = solve_equilibrium(shocked_economy)
        if p_star === nothing
            continue
        end
        
        x_star = equilibrium_allocations(p_star, shocked_economy)
        
        # Compute utilities
        u1 = utility_cobb_douglas(x_star[1, :], base_economy.utility_params[1])
        u2 = utility_cobb_douglas(x_star[2, :], base_economy.utility_params[2])
        
        # Store results
        push!(results[:shock], Δ)
        push!(results[:price_ratio], p_star[2] / p_star[1])
        push!(results[:allocation_1_good1], x_star[1, 1])
        push!(results[:allocation_1_good2], x_star[1, 2])
        push!(results[:allocation_2_good1], x_star[2, 1])
        push!(results[:allocation_2_good2], x_star[2, 2])
        push!(results[:utility_1], u1)
        push!(results[:utility_2], u2)
    end
    
    return results
end

"""
    plot_comparative_statics(results, title_suffix="")

Create plots showing how equilibrium variables respond to endowment shocks.
"""
function plot_comparative_statics(results::Dict, title_suffix::String="")
    shock = results[:shock]
    
    # Price response
    p1 = plot(
        shock, results[:price_ratio],
        xlabel="Endowment Shock (Δω)",
        ylabel="Price Ratio (p₂/p₁)",
        title="Price Response" * title_suffix,
        linewidth=2,
        color=:blue,
        legend=false,
        marker=:circle,
        markersize=4
    )
    idx = findfirst(shock .≈ 0)
    if idx !== nothing
        hline!([results[:price_ratio][idx]], 
               linestyle=:dash, color=:gray, alpha=0.5)
    end
    vline!([0], linestyle=:dash, color=:gray, alpha=0.5)
    
    # Allocation response - Consumer 1
    p2 = plot(
        shock, results[:allocation_1_good1],
        xlabel="Endowment Shock (Δω)",
        ylabel="Consumption",
        title="Consumer 1 Allocation" * title_suffix,
        label="Good 1",
        linewidth=2,
        color=:red,
        marker=:circle,
        markersize=4
    )
    plot!(shock, results[:allocation_1_good2],
          label="Good 2", linewidth=2, color=:orange, marker=:square, markersize=4)
    vline!([0], linestyle=:dash, color=:gray, alpha=0.5, label="")
    
    # Allocation response - Consumer 2
    p3 = plot(
        shock, results[:allocation_2_good1],
        xlabel="Endowment Shock (Δω)",
        ylabel="Consumption",
        title="Consumer 2 Allocation" * title_suffix,
        label="Good 1",
        linewidth=2,
        color=:red,
        marker=:circle,
        markersize=4
    )
    plot!(shock, results[:allocation_2_good2],
          label="Good 2", linewidth=2, color=:orange, marker=:square, markersize=4)
    vline!([0], linestyle=:dash, color=:gray, alpha=0.5, label="")
    
    # Utility response
    p4 = plot(
        shock, results[:utility_1],
        xlabel="Endowment Shock (Δω)",
        ylabel="Utility",
        title="Welfare Effects" * title_suffix,
        label="Consumer 1",
        linewidth=2,
        color=:green,
        marker=:circle,
        markersize=4
    )
    plot!(shock, results[:utility_2],
          label="Consumer 2", linewidth=2, color=:purple, marker=:square, markersize=4)
    vline!([0], linestyle=:dash, color=:gray, alpha=0.5, label="")
    
    # Combine into single figure
    combined = plot(p1, p2, p3, p4, layout=(2, 2), size=(900, 700))
    
    return combined
end

# ============================================
# MAIN: Run Comparative Statics Analysis
# ============================================

function main()
    println("=" ^ 60)
    println("COMPARATIVE STATICS IN GENERAL EQUILIBRIUM")
    println("=" ^ 60)
    println()
    
    # Define baseline economy (same as pure_exchange_2x2.jl)
    base_economy = PureExchangeEconomy(
        2, 2,
        [4.0 1.0; 1.0 4.0],
        [[0.6, 0.4], [0.3, 0.7]],
        :cobb_douglas
    )
    
    println("BASELINE ECONOMY")
    println("-" ^ 40)
    println("Consumer 1: u(x,y) = x^0.6 × y^0.4, ω = (4, 1)")
    println("Consumer 2: u(x,y) = x^0.3 × y^0.7, ω = (1, 4)")
    
    # Solve baseline
    p_base = solve_equilibrium(base_economy)
    if p_base === nothing
        error("Failed to solve baseline equilibrium. Check economy specification.")
    end
    x_base = equilibrium_allocations(p_base, base_economy)
    
    @printf("\nBaseline equilibrium: p* = (%.4f, %.4f)\n", p_base[1], p_base[2])
    @printf("Consumer 1: x* = (%.4f, %.4f)\n", x_base[1, 1], x_base[1, 2])
    @printf("Consumer 2: x* = (%.4f, %.4f)\n", x_base[2, 1], x_base[2, 2])
    
    # ============================================
    # Experiment 1: Increase Consumer 1's endowment of Good 1
    # ============================================
    println()
    println("EXPERIMENT 1: Shock to Consumer 1's Good 1 Endowment")
    println("-" ^ 40)
    
    shock_range = range(-3, 3, length=25)
    results1 = endowment_shock_analysis(base_economy, 1, 1, shock_range)
    
    println("Effect of increasing Consumer 1's Good 1 endowment:")
    println("  - More Good 1 in economy → Good 1 becomes relatively cheaper")
    println("  - Price ratio p₂/p₁ increases (Good 2 becomes relatively more expensive)")
    println("  - Both consumers substitute toward Good 1")
    
    # ============================================
    # Experiment 2: Increase Consumer 2's endowment of Good 2
    # ============================================
    println()
    println("EXPERIMENT 2: Shock to Consumer 2's Good 2 Endowment")
    println("-" ^ 40)
    
    results2 = endowment_shock_analysis(base_economy, 2, 2, shock_range)
    
    println("Effect of increasing Consumer 2's Good 2 endowment:")
    println("  - More Good 2 in economy → Good 2 becomes relatively cheaper")
    println("  - Price ratio p₂/p₁ decreases")
    println("  - Consumer 2's wealth increases")
    
    # ============================================
    # Generate Plots
    # ============================================
    println()
    println("GENERATING PLOTS...")
    println("-" ^ 40)
    
    plt1 = plot_comparative_statics(results1, "\n(Shock: ω₁¹)")
    savefig(plt1, "comparative_statics_consumer1_good1.png")
    println("Saved: comparative_statics_consumer1_good1.png")
    
    plt2 = plot_comparative_statics(results2, "\n(Shock: ω₂²)")
    savefig(plt2, "comparative_statics_consumer2_good2.png")
    println("Saved: comparative_statics_consumer2_good2.png")
    
    # ============================================
    # Transfer Analysis
    # ============================================
    println()
    println("EXPERIMENT 3: Lump-Sum Transfers")
    println("-" ^ 40)
    println("Redistributing endowments while keeping total constant")
    
    # Transfer Good 1 from Consumer 1 to Consumer 2
    transfer_range = range(-2, 2, length=21)
    transfer_results = Dict(
        :transfer => Float64[],
        :price_ratio => Float64[],
        :utility_1 => Float64[],
        :utility_2 => Float64[]
    )
    
    for τ in transfer_range
        new_endowments = [4.0 - τ  1.0; 1.0 + τ  4.0]
        
        if any(new_endowments .<= 0)
            continue
        end
        
        transfer_economy = PureExchangeEconomy(
            2, 2, new_endowments,
            base_economy.utility_params,
            :cobb_douglas
        )
        
        p_star = solve_equilibrium(transfer_economy)
        if p_star === nothing
            continue
        end
        
        x_star = equilibrium_allocations(p_star, transfer_economy)
        
        u1 = utility_cobb_douglas(x_star[1, :], base_economy.utility_params[1])
        u2 = utility_cobb_douglas(x_star[2, :], base_economy.utility_params[2])
        
        push!(transfer_results[:transfer], τ)
        push!(transfer_results[:price_ratio], p_star[2] / p_star[1])
        push!(transfer_results[:utility_1], u1)
        push!(transfer_results[:utility_2], u2)
    end
    
    # Plot transfer analysis
    plt3 = plot(
        layout=(1, 2),
        size=(800, 350)
    )
    
    plot!(plt3[1], 
          transfer_results[:transfer], transfer_results[:price_ratio],
          xlabel="Transfer τ (Good 1: 1→2)",
          ylabel="Price Ratio (p₂/p₁)",
          title="Price Effect of Redistribution",
          linewidth=2, color=:blue, legend=false,
          marker=:circle, markersize=4)
    vline!(plt3[1], [0], linestyle=:dash, color=:gray, alpha=0.5)
    
    plot!(plt3[2],
          transfer_results[:transfer], transfer_results[:utility_1],
          xlabel="Transfer τ (Good 1: 1→2)",
          ylabel="Utility",
          title="Welfare Effects of Redistribution",
          label="Consumer 1", linewidth=2, color=:green, marker=:circle, markersize=4)
    plot!(plt3[2],
          transfer_results[:transfer], transfer_results[:utility_2],
          label="Consumer 2", linewidth=2, color=:purple, marker=:square, markersize=4)
    vline!(plt3[2], [0], linestyle=:dash, color=:gray, alpha=0.5, label="")
    
    savefig(plt3, "transfer_analysis.png")
    println("Saved: transfer_analysis.png")
    
    println()
    println("KEY INSIGHTS:")
    println("-" ^ 40)
    println("1. Increasing supply of a good lowers its relative price")
    println("2. Endowment shocks affect both prices AND allocations")
    println("3. Transfers affect welfare distribution but all equilibria are Pareto efficient")
    println("4. GE effects capture spillovers missed in partial equilibrium")
    
    println()
    println("=" ^ 60)
    println("COMPARATIVE STATICS ANALYSIS COMPLETE")
    println("=" ^ 60)
    
    return results1, results2, transfer_results
end

# Run if executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
