
"""
Generates a randomized peloton.

Characteristics: A random mix of riders. Parameters are widely 
distributed, combining frantic, calm, fit, and weak cyclists in one group.
"""

function profil_random(n)
    return [
        [
            0.05 + rand()*0.8,   # α: Reaction behavior
            2.0  + rand()*13.0,  # β: Gap-closing aggressiveness (hectic/calm range)
            0.5  + rand()*5.5,   # d_safe: Safety distance
            10.0 + rand()*5.0,   # v_max: Max sprint speed
            5.0  + rand()*15.0,  # s_dur: Sprint duration (stamina)
            6.5  + rand()*1.5    # v_limit: Speed limit when exhausted
        ] for i in 1:(n-1)
    ]
end

"""
Generates a professional peloton.

Characteristics: High α for immediate reactions, low/calm β, and a very tight 
safety distance (d_safe). They have immense stamina (s_dur) and high speed limits.
"""

function profil_professionals(n)
    return [
        [
            1.8  * (0.9 + 0.2*rand()),   # α: Reaction behavior
            1.5  * (0.9 + 0.2*rand()),   # β: Gap-closing aggressiveness (calm/smooth)
            0.5  * (0.9 + 0.2*rand()),   # d_safe: Tight safety distance
            14.0 * (0.9 + 0.2*rand()),   # v_max: Max sprint speed
            120.0* (0.9 + 0.2*rand()),   # s_dur: Sprint duration (exceptional stamina)
            9.0  * (0.9 + 0.2*rand())    # v_limit: Speed limit when exhausted
        ] for i in 1:(n-1)
    ]
end

"""
Generates a novice peloton.

Characteristics: Small β because beginners don't know how to close gaps actively,
and a slightly larger safety distance (d_safe).
"""

function profil_novices(n)
    return [
        [
            0.05 * (0.9 + 0.2*rand()),   # α: Reaction behavior
            2.0  * (0.9 + 0.2*rand()),   # β: Gap-closing aggressiveness (low for novices)
            1.2  * (0.9 + 0.2*rand()),   # d_safe: Safety distance
            10.0 * (0.9 + 0.2*rand()),   # v_max: Max sprint speed
            20.0 * (0.9 + 0.2*rand()),   # s_dur: Sprint duration (stamina)
            8.0  * (0.9 + 0.2*rand())    # v_limit: Speed limit when exhausted
        ] for i in 1:(n-1)
    ]
end
"""
Generates an anxious peloton.

Characteristics: Large β because they react very nervously and hectically, 
and a high safety distance (d_safe) which often causes the group to rip apart ("Gap-Creators").
"""

function profil_anxious(n)
    return [
        [
            0.2  * (0.9 + 0.2*rand()),   # α: Reaction behavior
            10.0 * (0.9 + 0.2*rand()),   # β: Hectic gap-closing (very high/nervous)
            4.0  * (0.9 + 0.2*rand()),   # d_safe: Large safety distance (3-5m)
            11.5 * (0.9 + 0.2*rand()),   # v_max: Max sprint speed
            40.0 * (0.9 + 0.2*rand()),   # s_dur: Sprint duration (stamina)
            8.5  * (0.9 + 0.2*rand())    # v_limit: Speed limit when exhausted
        ] for i in 1:(n-1)
    ]
end  