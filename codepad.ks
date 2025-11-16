runOncePath("0:/LAUNCH.ks").
runOncepath("0:/ORBITS.ks").
runOncePath("0:/MANEUVER.ks").
runOncePath("0:/CONSOLE.ks").
runOncePath("0:/RENDEZVOUS.ks").
runOncePath("0:/MATH.ks").
CLEARSCREEN.

local targetObj is MUN.
local phaseMargin is 5.
//Initial Conditions.
local t is TIME:SECONDS.
local Vlong is trueLongitude(trueAnomaly(ship:ORBIT), ship:ORBIT).
local Tlong is trueLongitude(trueAnomaly(targetObj:ORBIT), targetObj:ORBIT).
local r_tgt is radiusAtTrueAnomaly(mod(Vv + 180, 360), targetObj:ORBIT). ///SHIT, need to be working in True Longitude.
local r_shp is radiusAtTrueAnomaly(Vv, ship:ORBIT).


local hohmannTransferTime is 
local currentPhaseANgle is phaseAngle(ta0rgetObj:ORBIT, ship:ORBIT).
local targetPhaseAngle is 180 * (1 - hohmannTransferTime.

if abs(currentPhaseAngle - targetPhaseAngle) > Phasemargin{

}