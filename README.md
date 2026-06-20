# Cyclists.jl
A Julia-based ODE simulation of cycling peloton dynamics: Modeling velocity synchronization ('wobbling') and platoon stability with custom driver profiles and trajectory plausibility testing.

## Features & Repository Architecture
* **`src/Physics.jl`**: Implements the primary dynamical equations defining safe distance control, drag coefficients, panic braking mechanisms, and biological limits.
* **`src/Profiles.jl`**: Generates customized cohorts of agents (`:profil_professionals`, `:profil_novices`, `:profil_anxious`, `:profil_random`).
* **`src/Wind.jl`**: Simulates deterministic perturbations (Sinusoidal waves) and stochastic weather models (Ornstein-Uhlenbeck processes evaluated via Euler-Maruyama approximations).
* **Reproducibility**: Environment tracking managed natively via tracked `Project.toml`.

## Getting Started
To initialize the environment and launch the package locally, open the Julia REPL within the project directory and run:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```
## Overview

The pluto notebook cyclists_pluto.jl presents the functionality of Cyclists.jl.
