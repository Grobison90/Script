//Terminal Management
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

print "Booting.".
runOncePath("0:/FLIGHT_MANAGER.ks").
runOncePath("0:/LAUNCH.ks").
runOncePath("0:/DISPLAY.ks").

wait 1.
CLEARSCREEN.

global _FLIGHT_MANAGER is true.
local FLIGHT_PLAN is list(
doToOrbitLaunch@:BIND(90,80000,0.35),
{wait 10.},//wait in orbit just a second.
doDeorbit@:BIND(35000),
doReentry@
).

manageFlight(FLIGHT_PLAN, true).