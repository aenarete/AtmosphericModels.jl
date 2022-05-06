using AtmosphericModels, KiteUtils, BenchmarkTools
using Test

cd("..")
KiteUtils.set_data_path("") 
am = AtmosphericModel()

@test calc_wind_factor(am, 6.0) ≈ 1.0
