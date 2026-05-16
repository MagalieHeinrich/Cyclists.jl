using DifferentialEquations
using OrdinaryDiffEq
using OrdinaryDiffEqSSPRK
using Plots
using Random

include(joinpath(@__DIR__, "profiles.jl"))
include(joinpath(@__DIR__, "wind.jl"))
include(joinpath(@__DIR__, "cyclists.jl"))

n = 5                     
mein_seed = 8516          
Random.seed!(mein_seed)

tspan = (0.0, 300.0)      
x0 = collect(n:-1:1) .* 1.5  
v0 = fill(30.0/3.6, n)       
u0 = vcat(x0, v0)        

#WIND_MODUS = :ou  # Choose :ou or :sine

#simulation_params = create_simulation_params(WIND_MODUS, n, tspan, v0[1])

simulation_params = create_simulation_params(
    :ou, 
    n, 
    tspan, 
    v0[1],
    riders_generator = profil_professionals,  # Swapping the rider types
    v_basis          = 8.0,          # Strong baseline wind
    wind_reversion   = 0.5,          # Wind snaps back to baseline faster
    wind_turbulence  = 4.0           # Extreme turbulence
)

prob = ODEProblem(cyclists!, u0, tspan, simulation_params)
sol = solve(prob, SSPRK43(), reltol=1e-5, abstol=1e-7)


t_vals = sol.t
dist_vals = [sol(t)[i-1] - sol(t)[i] for t in t_vals, i in 2:n]
cum_dist_vals = [sol(t)[1] - sol(t)[i] for t in t_vals, i in 1:n]
to_kmh = 3.6

v_labels = reshape(["Fahrer $i" for i in 1:n], 1, :)
dist_labels = reshape(["$i zu $(i-1)" for i in 2:n], 1, :)

p1 = plot(sol.t, Array(sol[n+1:2n, :])' .* to_kmh, 
          title="Geschwindigkeiten in km/h", label=v_labels, ylabel="v [km/h]", legend=:outerright, lw=1.0)

p2 = plot(t_vals, dist_vals, title="Einzel-Abstände", ylabel="Abstand [m]", label=dist_labels, legend=:outerright)

p3 = plot(t_vals, cum_dist_vals, title="Kumulativer Abstand zum Leader", xlabel="Zeit [s]", ylabel="Meter zurück", label=v_labels, legend=:outerright, lw=1.0)

picture = plot(p1, p2, p3, layout=(3,1), size=(1200, 800))
display(picture)

max_v_per_step = [maximum(u[n+1:end]) for u in sol.u]
v_max_global = maximum(max_v_per_step)
println("\n--- Simulation beendet ---")
println("Maximal erreichte Geschwindigkeit im Feld: $(round(v_max_global * to_kmh, digits=2)) km/h")
println("Maximal erreichte Position (Leader): $(round(sol.u[end][1], digits=2)) m")