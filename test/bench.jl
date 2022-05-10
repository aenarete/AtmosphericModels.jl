using AtmosphericModels, BenchmarkTools

const am = AtmosphericModel()

am.set.profile_law=6
# @benchmark calc_wind_factor(am, height, Val{profile_law}) setup=(height=Float64((6.0+rand()*500.0)))
@benchmark calc_wind_factor(am, height) setup=(height=Float64((6.0+rand()*500.0)))
# @benchmark calc_rho(am, height) setup=(height=Float64((6.0+rand()*500.0)))

