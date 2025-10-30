//Terminal Management
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

print("Booting.").
runOncePath("0:/MISSION.ks").
RunOncePath("0:/CONSOLE.ks").
RunOncePath("0:/DISPLAY.ks").
RunOncePath("0:/FILE.ks").
RunOncePath("0:/LANDING.ks").
RunOncePath("0:/LAUNCH.ks").
RunOncePath("0:/MANEUVER.ks").
RunOncePath("0:/MATH.ks").
RunOncePath("0:/ORBITS.ks").
RunOncePath("0:/SHIP.ks").
RunOncePath("0:/VECTOR.ks").
print("Boot Complete.").
wait 1.
CLEARSCREEN.

configureDisplay(_DEFAULT_HEADERS, _DEFAULT_LAUNCH_TABLE).

doToOrbitLaunch(90,80000,0.35).
wait 60.//wait in orbit just a minute.
doDeorbit().
doReentry().
