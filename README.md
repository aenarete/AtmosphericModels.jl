# AtmosphericModels

## Exported types
```julia
AtmosphericModel
@enum ProfileLaw EXP=1 LOG=2 EXPLOG=3 FAST_EXP=4 FAST_LOG=5 FAST_EXPLOG=6
```

## Exported functions
```julia
calc_rho(s::AM, height)
calc_wind_factor(s::AM, height, ::Type{Val{1}})
calc_wind_factor(s::AM, height, ::Type{Val{2}})
calc_wind_factor(s::AM, height, ::Type{Val{3}})
calc_wind_factor(s::AM, height, ::Type{Val{4}})
calc_wind_factor(s::AM, height, ::Type{Val{5}})
calc_wind_factor(s::AM, height, ::Type{Val{6}})
```

## Usage
```julia
using AtmosphericModels
am = AtmosphericModel()

const profile_law = Int(EXPLOG)
height = 100.0
wf = calc_wind_factor(am, height, Val{profile_law})
```
The result is the factor with which the ground wind speed needs to be mulitplied
to get the wind speed at the given height.

## See also
- [Research Fechner](https://research.tudelft.nl/en/publications/?search=Uwe+Fechner&pageSize=50&ordering=rating&descending=true)
- The application [KiteViewer](https://github.com/ufechner7/KiteViewer)
- the package [KiteUtils](https://github.com/ufechner7/KiteUtils.jl)
- the package [KitePodModels](https://github.com/aenarete/KitePodModels.jl)
- the package [KiteModels](https://github.com/ufechner7/KiteModels.jl)
- the package [KiteControllers](https://github.com/aenarete/KiteControllers.jl)
- the package [KiteViewers](https://github.com/aenarete/KiteViewers.jl)

