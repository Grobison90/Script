runOncePath("0:/LAUNCH.ks").
runOncePath("0:/SHIP.ks").
runOncePath("0:/CONSOLE.ks").
runOncePath("0:/MANEUVER.ks").
CLEARSCREEN.

set n to createOrbitalInsertionManeuver().
add n.
set t to calculateBurnStartTime(n, true).
set dt to t - TIME:SECONDS.
until (dt <=0){
    print("Burn in t+ " + round(dt,2))at(0,10).
    set dt to t - TIME:SECONDS.
}