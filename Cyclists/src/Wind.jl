function get_wind_speed_sine(t; v_basis, amplitude, period)
    omega = 2 * pi / period
    return v_basis + amplitude * sin(omega * t)
end