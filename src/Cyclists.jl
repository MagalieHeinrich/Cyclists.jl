module Cyclists

using DifferentialEquations
using OrdinaryDiffEq
using OrdinaryDiffEqSSPRK
using Random


include("Profiles.jl")
include("Wind.jl")
include("Physics.jl") 


export cyclists!, create_simulation_params
export profil_professionals, profil_novices, profil_anxious, profil_random

end # module