module AtmosphericModels

using KiteUtils, Parameters

export AtmosphericModel, ProfileLaw, EXP, LOG, EXPLOG, FAST_EXP, FAST_LOG, FAST_EXPLOG
export calc_rho, calc_wind_factor

# # ALPHA      = 1.0/7.0
# ALPHA = 0.234
# REF_HEIGHT =  6.0
# HUB_HEIGHT= 200.0    # average height during reel-out phase
# TEST = 2
# V_WIND_GNDS = [3.483, 5.324, 8.163]
# REL_TURB = [0.342, 0.465, 0.583]
# # V_WIND_GND = 5.2  # at ref_height in m/s
# # V_WIND_GND = 3.483 # converted from 4.26 m/s at 10 m using alpha=0.234
# V_WIND_GND = V_WIND_GNDS[TEST]
# REL_SIGMA  =  1.0    # turbulence relative to the IEC model
# I_REF = 0.14         # is the expected value of the turbulence intensity at 15 m/s.
# V_REF = 42.5         # five times the average wind speed in m/s at hub height over the full year
#                      # cabau: 8.5863 m/s * 5.0 = 42.7 m/s
# HEIGHT_STEP  = 2.0   # use a grid with 2m resolution in z direction
# GRID_STEP    = 2.0   # grid resolution in x and y direction
# np.random.seed(1234) # do this only if you want to have reproducable wind fields

"""
    mutable struct AtmosphericModel

Stuct that is storing the settings and the state of the atmosphere. 
"""
@with_kw mutable struct AtmosphericModel
    set::Settings = se()
    turbulence::Float64 = 0.0
end

const AM = AtmosphericModel

@inline function fastexp(x)
  y = 1 + x / 1024
  y *= y; y *= y; y *= y; y *= y; y *= y  
  y *= y; y *= y; y *= y; y *= y; y *= y 
  y
end

# Calculate the air densisity as function of height
calc_rho(s::AM, height) = s.set.rho_0 * fastexp(-(height+s.set.height_gnd) / 8550.0)

"""
    @enum ProfileLaw EXP=1 LOG=2 EXPLOG=3

Enumeration to describe the wind profile low that is used.
"""
@enum ProfileLaw EXP=1 LOG=2 EXPLOG=3 FAST_EXP=4 FAST_LOG=5 FAST_EXPLOG=6

# Calculate the wind speed at a given height and reference height.
function calc_wind_factor(s::AM, height, ::Type{Val{1}})
    exp(s.set.alpha * log(height/s.set.h_ref))
end 

function calc_wind_factor(s::AM, height, ::Type{Val{2}})
    log(height / s.set.z0) / log(s.set.h_ref / s.set.z0)
end

function calc_wind_factor(s::AM, height, ::Type{Val{3}})
    K = 1.0
    log1 = log(height / s.set.z0) / log(s.set.h_ref / s.set.z0)
    exp1 = exp(s.set.alpha * log(height/s.set.h_ref))
    log1 +  K * (log1 - exp1)
end

function calc_wind_factor(s::AM, height, ::Type{Val{4}})
    if height < 6.0 return 1.0 end
    evalpoly(1/height, (1.8427619589823305, 3617.0786194064476, 590119.886685333, -2.53435240735932e6, 5.4120682033388115e7, -9.636216067310344e8, 1.2056636533430845e10, -9.962127083327875e10, 5.1324465874649536e11, -1.4865348277628154e12, 1.8431054022301477e12))/
        evalpoly(1/height, (1.0, 2487.0429567107535, 495940.74312868936))
end

function calc_wind_factor(s::AM, height, ::Type{Val{5}})
    if height < 6.0 return 1.0 end
    evalpoly(1/height, (1.7254692847178346, 3180.6368701426595, 489764.5131517146, -2.1080713892318057e6, 4.227143439940046e7, -7.322154139158928e8, 9.013764300164715e9, -7.36716754548423e10, 3.7658022380555835e11, -1.0842283673197954e12, 1.338030926540245e12))/
        evalpoly(1/height, (1.0, 2200.4764287411545, 404389.8285052791))
end

function calc_wind_factor(s::AM, height, ::Type{Val{6}})
    if height < 6.0 return 1.0 end
    evalpoly(1/height, (1.6133163094857612, 2488.963179734051, 343230.7633444393, -1.450703528831999e6, 2.6919154959563803e7, -4.4848947369166476e8, 5.387689053876384e9, -4.329358467994954e10, 2.1854676308520227e11, -6.232058566966395e11, 7.632537480818357e11))/
        evalpoly(1/height, (1.0, 1735.2333827029918, 279373.0012683715))
end


end
