module AtmosphericModels

using KiteUtils
using HypergeometricFunctions:_₂F₁

export AtmosphericModel, ProfileLaw, EXP, LOG, EXPLOG, FAST_EXP, FAST_LOG, FAST_EXPLOG
export clear, calc_rho, calc_wind_factor

const ABS_ZERO = -273.15
"""
    mutable struct AtmosphericModel

Stuct that is storing the settings and the state of the atmosphere. 
"""
Base.@kwdef mutable struct AtmosphericModel
    set::Settings = se()
    turbulence::Float64 = 0.0
    rho_zero_temp::Float64 = (15.0 - ABS_ZERO) / (se().temp_ref - ABS_ZERO) * se().rho_0
end

const AM = AtmosphericModel

function clear(s::AM)
     s.rho_zero_temp       = (15.0 - ABS_ZERO) / (s.set.temp_ref - ABS_ZERO) * s.set.rho_0
end

@inline function fastexp(x)
  y = 1 + x / 1024
  y *= y; y *= y; y *= y; y *= y; y *= y  
  y *= y; y *= y; y *= y; y *= y; y *= y 
  y
end

# Calculate the air densisity as function of height
calc_rho(s::AM, height) = s.rho_zero_temp * fastexp(-(height+s.set.height_gnd) / 8550.0)

"""
    @enum ProfileLaw EXP=1 LOG=2 EXPLOG=3

Enumeration to describe the wind profile low that is used.
""" ProfileLaw

@enum ProfileLaw begin 
    EXP=1 
    LOG=2 
    EXPLOG=3 
    FAST_EXP=4 
    FAST_LOG=5 
    FAST_EXPLOG=6
end

@doc """
    EXP::ProfileLaw

Exponential wind profile.

See also [`ProfileLaw`](@ref).
""" EXP
@doc """
    LOG::ProfileLaw

Logarithmic wind profile.

See also [`ProfileLaw`](@ref).
""" LOG
@doc """
    EXPLOG::ProfileLaw

A linear combination of exponential and logarithmic wind profile to match a specific site.

See also [`ProfileLaw`](@ref).
""" EXPLOG


# Calculate the wind speed at a given height and reference height.
@inline function calc_wind_factor1(s::AM, height);  exp(s.set.alpha * log(height/s.set.h_ref)); end
@inline function calc_wind_factor(s::AM, height, ::Type{Val{1}})
    calc_wind_factor1(s, height)
end 

@inline function calc_wind_factor2(s::AM, height);  log(height / s.set.z0) / log(s.set.h_ref / s.set.z0); end
@inline function calc_wind_factor(s::AM, height, ::Type{Val{2}})
    calc_wind_factor2(s, height)
end

@inline function calc_wind_factor(s::AM, height, ::Type{Val{3}}); calc_wind_factor3(s, height); end
@inline function calc_wind_factor3(s::AM, height)
    K = 1.0
    log1 = log(height / s.set.z0) / log(s.set.h_ref / s.set.z0)
    exp1 = exp(s.set.alpha * log(height/s.set.h_ref))
    log1 +  K * (log1 - exp1)
end

@inline function calc_wind_factor(s::AM, height, ::Type{Val{4}}); calc_wind_factor4(s, height); end
@inline function calc_wind_factor4(s::AM, height)
    if height < 6.0 return 1.0 end
    evalpoly(1/height, (1.8427619589823305, 3617.0786194064476, 590119.886685333, -2.53435240735932e6, 5.4120682033388115e7, -9.636216067310344e8, 1.2056636533430845e10, -9.962127083327875e10, 5.1324465874649536e11, -1.4865348277628154e12, 1.8431054022301477e12))/
        evalpoly(1/height, (1.0, 2487.0429567107535, 495940.74312868936))
end

@inline function calc_wind_factor(s::AM, height, ::Type{Val{5}}); calc_wind_factor5(s, height); end
@inline function calc_wind_factor5(s::AM, height)
    if height < 6.0 return 1.0 end
    evalpoly(1/height, (1.7254692847178346, 3180.6368701426595, 489764.5131517146, -2.1080713892318057e6, 4.227143439940046e7, -7.322154139158928e8, 9.013764300164715e9, -7.36716754548423e10, 3.7658022380555835e11, -1.0842283673197954e12, 1.338030926540245e12))/
        evalpoly(1/height, (1.0, 2200.4764287411545, 404389.8285052791))
end

@inline function calc_wind_factor(s::AM, height, ::Type{Val{6}}); calc_wind_factor6(s, height); end
function calc_wind_factor6(s::AM, height)
    if height < 6.0 return 1.0 end
    evalpoly(1/height, (1.6133163094857612, 2488.963179734051, 343230.7633444393, -1.450703528831999e6, 2.6919154959563803e7, -4.4848947369166476e8, 5.387689053876384e9, -4.329358467994954e10, 2.1854676308520227e11, -6.232058566966395e11, 7.632537480818357e11))/
        evalpoly(1/height, (1.0, 1735.2333827029918, 279373.0012683715))
end

@inline function calc_wind_factor(am::AM, height, profile_law::Int64=am.set.profile_law)
    if profile_law == 1
        calc_wind_factor1(am, height)
    elseif profile_law == 2
        calc_wind_factor2(am, height)
    elseif profile_law == 3
        calc_wind_factor3(am, height)
    elseif profile_law == 4
        calc_wind_factor4(am, height)
    elseif profile_law == 5
        calc_wind_factor5(am, height)
    elseif profile_law == 6
        calc_wind_factor6(am, height)    
    else
        throw(DomainError(profile_law, "invalid profile_law"))
    end
end

include("windfield.jl")

end