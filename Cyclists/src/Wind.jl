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


"""
    create_simulation_params(modus, n, tspan, v_target; kwargs...)

Generates the unified parameter NamedTuple for the ODE solvers.
Allows customization of wind attributes using keyword arguments.
"""

function create_simulation_params(
    modus::Symbol, 
    n::Int, 
    tspan::Tuple{Float64, Float64}, 
    v_target::Float64;
    riders_generator = profil_novices,
    # Default parameters if one doesnt provide them in main.jl:
    v_basis   = 3.0,
    amplitude = 10.0,
    period    = 20.0,
    wind_reversion     = 0.3,
    wind_turbulence     = 2.0
)
    # Automatically load the profile based on the group size
    riders_profile = riders_generator(n)
    if modus == :sine
        return (
            riders          = riders_profile, 
            v_basis         = v_basis,      
            amplitude       = amplitude,     
            period          = period,
            t_steps         = [0.0],    # Dummy values
            wind_profile    = [0.0], 
            v_leader_target = v_target 
        )
        
    elseif modus == :ou
        println("-> Pre-generating stochastic OU wind via Euler-Maruyama...")
        # Uses the fixed step size dt=0.1
        t_steps, wind_profile = generate_ou_wind(tspan, 0.1, v_basis=v_basis, theta = wind_reversion, sigma = wind_turbulence)
        # wind_reversion is theta and wind_turbulence is sigma
        return (
            riders          = riders_profile,
            t_steps         = t_steps,
            wind_profile    = wind_profile,
            v_basis         = v_basis,      
            amplitude       = 0.0,   # Triggers OU condition branch in cyclists! because of the if loop there. Its ugly but I dont care.
            period          = 1.0,   
            v_leader_target = v_target     
        )
    else
        error("Unknown WIND_MODUS: :$modus. Choose either :sine or :ou.")
    end
end