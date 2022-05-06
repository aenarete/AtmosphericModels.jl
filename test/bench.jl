using AtmosphericModels, BenchmarkTools

am = AtmosphericModel()

const profile_law=3
# @benchmark calc_wind_factor(am, height, Val{profile_law}) setup=(height=Float64((6.0+rand()*500.0)))
@benchmark calc_rho(am, height) setup=(height=Float64((6.0+rand()*500.0)))

