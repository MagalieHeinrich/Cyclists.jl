function get_wind_speed_sine(t; v_basis, amplitude, period)
    omega = 2 * pi / period
    return v_basis + amplitude * sin(omega * t)
end

# Wind generation uses EM to create the OU wind array
function generate_ou_wind(tspan, dt; v_basis=3.0, theta=0.3, sigma=1.5)
    t_steps = tspan[1]:dt:tspan[2]
    N = length(t_steps)
    wind_profile = zeros(N)
    
    v_wind = v_basis # Start at baseline
    wind_profile[1] = v_wind
    
    for i in 2:N
        # Euler-Maruyama Step:
        drift = theta * (v_basis - v_wind) * dt
        diffusion = sigma * sqrt(dt) * randn() # randn() provides the dW_t
        
        v_wind = v_wind + drift + diffusion
        wind_profile[i] = v_wind
    end
    return t_steps, wind_profile
end

# Reads the wind speed at any time 't' for the solver
function get_wind_speed_ou(t, t_steps, wind_profile)
    # Finds the closest index in pre-calculated grid
    idx = clamp(round(Int, (t - t_steps[1]) / (t_steps[2] - t_steps[1])) + 1, 1, length(wind_profile))
    return wind_profile[idx]
end