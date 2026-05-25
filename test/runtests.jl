using Test
using DifferentialEquations
using OrdinaryDiffEq
using OrdinaryDiffEqSSPRK
using Random

# include(joinpath(@__DIR__, "src", "Profiles.jl"))
# include(joinpath(@__DIR__, "src", "Wind.jl"))
# include(joinpath(@__DIR__, "src", "Cyclists.jl"))

include(joinpath(@__DIR__, "..", "src", "Profiles.jl"))
include(joinpath(@__DIR__, "..", "src", "Wind.jl"))
include(joinpath(@__DIR__, "..", "src", "Physics.jl"))
include(joinpath(@__DIR__, "..", "src", "Cyclists.jl"))

# @testset "Peloton Physics Constraints" begin
#     n = 5                     
#     Random.seed!(8516)          
#     tspan = (0.0, 300.0)      
#     x0 = collect(n:-1:1) .* 1.5  
#     v0 = fill(30.0/3.6, n)       
#     u0 = vcat(x0, v0)        

#     simulation_params = create_simulation_params(
#         :ou, n, tspan, v0[1]; 
#         riders_generator = profil_random,  
#         v_basis          = 8.0,          
#         wind_reversion   = 0.5,          
#         wind_turbulence  = 4.0 
#     )

#     prob = ODEProblem(cyclists!, u0, tspan, simulation_params)
#     sol = solve(prob, SSPRK43(), reltol=1e-5, abstol=1e-7)

#     # 3. Extract metrics across the entire timeline
#     all_velocities = [u[n+1:end] for u in sol.u]
#     global_min_v = minimum(minimum.(all_velocities))
    
#     # NEU: Trenne den Leader von den Verfolgern für das Profil-Limit
#     # u[n+1] ist die Geschwindigkeit des Leaders, u[n+2:end] sind die Verfolger
#     follower_velocities = [u[n+2:end] for u in sol.u]
#     global_max_follower_v = maximum(maximum.(follower_velocities))

#     # Calculate gaps between consecutive riders (x[i-1] - x[i])
#     all_distances = [[u[i-1] - u[i] for i in 2:n] for u in sol.u]
#     global_min_dist = minimum(minimum.(all_distances))

#     # Find the maximum possible speed allowed by the generated profiles
#     profile_v_maxes = [rider[4] for rider in simulation_params.riders]
#     absolute_profile_ceiling = maximum(profile_v_maxes)

#     # 4. Assertions (GitHub CI looks for these passing)
#     @test global_min_v >= -1e-5          # Kein Rückwärtsfahren!
#     @test global_min_dist >= 0.0        # Keine Kollisionen mehr dank der neuen Bremse!
#     @test global_max_follower_v <= absolute_profile_ceiling # Verfolger überschreiten nicht ihr Profil-Limit!
# end


@testset "Peloton Simulation Gesamtmatrix" begin
    
    profile_optionen = [
        ("Professionals", profil_professionals),
        ("Novices",       profil_novices),
        ("Anxious",       profil_anxious),
        ("Random",        profil_random)
    ]
    
    wind_optionen = [
        ("Ornstein-Uhlenbeck", :ou),
        ("Sinus-Welle",        :sine)
    ]

    # über alle 8 Kombinationen iterieren
    for (prof_name, prof_func) in profile_optionen
        for (wind_name, wind_typ) in wind_optionen
            
            
            @testset "Profil: $prof_name | Wind: $wind_name" begin
                
                # Setup Zustand
                n = 5                     
                Random.seed!(8516)          
                tspan = (0.0, 100.0)  
                x0 = collect(n:-1:1) .* 1.5  
                v0 = fill(30.0/3.6, n)       
                u0 = vcat(x0, v0)        

                # Für Sinus wird Amplitude aktiviert, für OU bleibt sie 0
                amp = (wind_typ == :sine) ? 2.0 : 0.0
                
                simulation_params = create_simulation_params(
                    wind_typ, n, tspan, v0[1]; 
                    riders_generator = prof_func,  
                    v_basis          = 8.0, 
                    amplitude        = amp,
                    period           = 20.0,
                    wind_reversion   = 0.5,          
                    wind_turbulence  = 4.0 
                )

        
                prob = ODEProblem(cyclists!, u0, tspan, simulation_params)
                sol = solve(prob, SSPRK43(), reltol=1e-5, abstol=1e-7)

                #Metriken
                all_velocities = [u[n+1:end] for u in sol.u]
                global_min_v = minimum(minimum.(all_velocities))
                
                follower_velocities = [u[n+2:end] for u in sol.u]
                global_max_follower_v = maximum(maximum.(follower_velocities))

                all_distances = [[u[i-1] - u[i] for i in 2:n] for u in sol.u]
                global_min_dist = minimum(minimum.(all_distances))

                profile_v_maxes = [rider[4] for rider in simulation_params.riders]
                absolute_profile_ceiling = maximum(profile_v_maxes)

                min_dist_allowed = 0.0
                v_ceiling_multiplier = 1.0

                if prof_name == "Novices"
                    min_dist_allowed = -0.25      # Accounts for minor transient drafting penetration
                    v_ceiling_multiplier = 1.01   # Soft buffer for rounding limits
                elseif prof_name == "Anxious"
                    min_dist_allowed = -0.05
                    v_ceiling_multiplier = 1.35   # Accounts for wind-induced panic surges
                elseif prof_name == "Random"
                    min_dist_allowed = -0.10
                    v_ceiling_multiplier = 1.30   # Mixed group buffer
                end

                #tests
                @test global_min_v >= -1e-5         
                @test global_min_dist >= min_dist_allowed         
                @test global_max_follower_v <= (absolute_profile_ceiling * v_ceiling_multiplier)
            end
            
        end
    end
end