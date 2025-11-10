runOncePath("0:/LAUNCH.ks").
runOncepath("0:/ORBITS.ks").
runOncePath("0:/MANEUVER.ks").
runOncePath("0:/CONSOLE.KS").
CLEARSCREEN.

set t to mun.

until false {
    local trgtTA is trueLongitude(t:ORBIT:TRUEANOMALY, t:ORBIT).
    local vssTA is trueLongitude(SHIP:ORBIT:TRUEANOMALY, SHIP:ORBIT).
    local pa is trgtTA - vssTA.
    print("Mun True Anomaly: " + trgtTA + 
    "   Vessel True Anomaly: " + trueLongitude(SHIP:ORBIT:TRUEANOMALY, SHIP:ORBIT))at(0,2).
    print("Phase Angle: " + pa)at(0,3).
}

