#module Cyclists

    #using Random

    #export cyclists!, primitive_cyclists!
    #export profil_random, profil_professionals, profil_novices, profil_anxious


    #include(joinpath(@__DIR__, "wind.jl"))
    #include(joinpath(@__DIR__, "cyclists.jl"))


    function cyclists!(du, u, p_composite, t)
        p_list    = p_composite.riders
        v_basis   = p_composite.v_basis
        amplitude = p_composite.amplitude
        period    = p_composite.period
        t_steps   = p_composite.t_steps
        wind_profile = p_composite.wind_profile
        v_leader_target = p_composite.v_leader_target

        n = Int(length(u)/2)
        x = @view u[1:n]
        v = @view u[n+1:end]
        dx = @view du[1:n]
        dv = @view du[n+1:end]

        if amplitude == 0.0
            current_wind = get_wind_speed_ou(t, t_steps, wind_profile)
        else
            current_wind = get_wind_speed_sine(t, v_basis=v_basis, amplitude=amplitude, period=period)
        end
    

        # Fahrer 1: Leader
        v_target = v_leader_target
        dx[1] = v[1]
        v_leader_eff = max(6.0, v_target - (current_wind * 0.4))
        dv[1] = 0.5 * (v_leader_eff - v[1])

        for i in 2:n
            α, β, d_safe, v_max, s_dur, v_limit = p_list[i-1]
            dist = x[i-1] - x[i]
            
            angleichung = α * (v[i-1] - v[i]) 
            abstandskontrolle = β * (dist - d_safe) 
            
            panic_threshold = 1.0 
            safe_delta = clamp(panic_threshold - dist, 0.0, 0.25)
            #angst_bremse = dist < panic_threshold ? exp(5.0 * safe_delta) : 0.0 
            if dist < panic_threshold
            # As dist approaches 0 (or goes negative), this number blows up aggressively
                angst_bremse = exp(4.0 * (panic_threshold - dist)) 
            else
                angst_bremse = 0.0
            end
            angst_bremse = min(angst_bremse, 150.0)

            desired_dv = angleichung + abstandskontrolle - angst_bremse
            
            # If dist = 0, the effect is 0 (perfect draft/slipstream).
            # The larger dist becomes, the closer the factor gets to 1.0 (full wind exposure).
            # The '2.0' determines how quickly the draft drops off (approx. after 2-3 meters).
            wind_exposure = 1.0 - exp(-dist / 2.0)
                        
            # The wind reduces performance but does not subtract an infinite amount of velocity.
            # It scales the wind resistance proportionally to the wind speed.            
            v_eff_max = max(v_limit, v_max - (wind_exposure * current_wind * 0.5))

            # Once stamina is depleted (time is up), the rider drops to their limit.
            v_eff = (t > s_dur) ? v_limit : v_eff_max

            dv[i] = desired_dv

            if v[i] > v_eff
                # Strong restorative acceleration to pull them back to their biological limit
                dv[i] = min(desired_dv, 2.0 * (v_eff - v[i])) 
            elseif v[i] <= 0.0 && desired_dv < 0
                dv[i] = 0.0
            end

            # if v[i] >= v_eff && desired_dv > 0
            #     dv[i] = 0.0
            # elseif v[i] <= 0.0 && desired_dv < 0
            #     dv[i] = 0.0
            # else
            #     dv[i] = desired_dv
            # end
            dx[i] = max(0.0, v[i])

            if v[i] > 30.0 
                dv[i] = -10.0 
            end
        end
    end


    
    function primitive_cyclists!(du, u, p_composite, t)

        p_list = p_composite.riders
        
        n = Int(length(u)/2)
        x = @view u[1:n]
        v = @view u[n+1:end]
        dx = @view du[1:n]
        dv = @view du[n+1:end]
        
        v_leader = 30 / 3.6
        dx[1] = v[1]
        v[1] = v_leader
        dv[1] = 0.0

        for i in 2:n
            α, β, d_safe = p_list[i-1] 
            dist = x[i-1] - x[i]
            dv[i] = α * (v[i-1] - v[i]) + β * (dist - d_safe)
            
            dx[i] = v[i]
        end
    end

#end