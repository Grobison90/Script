//Terminal Management
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

print("Booting...").//Load dependencies.
RunOncePath("0:/CONSOLE.ks").
RunOncePath("0:/DISPLAY.ks").
RunOncePath("0:/FILE.ks").
RunOncePath("0:/LANDING.ks").
RunOncePath("0:/LAUNCH.ks").
RunOncePath("0:/MANEUVER.ks").
RunOncePath("0:/MATH.ks").
RunOncePath("0:/SHIP.ks").
RunOncePath("0:/VECTOR.ks").
print("Boot Complete.").
wait 1.
CLEARSCREEN.

GLOBAL _FLIGHT_STATUS is "Prelaunch".
GLOBAL _OPERATION_STATUS is "Nominal".
GLOBAL _DISPLAY is true.
GLOBAL _ERROR_QUEUE is queue().

configureDisplay(_DEFAULT_HEADERS, _DEFAULT_LAUNCH_TABLE).

when true then {
    updateDisplay().
    PRESERVE.
}
//run my particular launch plan:
RunPath("0:/_charlie1_plan.ks").
