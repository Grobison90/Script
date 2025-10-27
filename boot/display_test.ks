//Terminal Management
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
wait 1.

print "Loading Dependencies.".

runOncePath("0:/DISPLAY.ks").
runOncePath("0:/LAUNCH.ks").
runOncePath("0:/MATH.ks").
runOncePath("0:/SHIP.ks").





print "Loading Complete.".

wait 1.

CLEARSCREEN.


set h1 to list("Mission: ", {return "Display Testing".}).
set h2 to list("Flight Status: ", getFlightStatus@).
set h3 to list("Operating Status: ",  getOperationStatus@).
set headerList to list(h1, h2, h3).
set colLabels to list("Data", "Current", "Target").


set dataTable to list(
    colLabels,
    list("Alt (AGL)", {return round(ship:ALTITUDE).}, {return launchApoapsis.}),
    list("Velocity", {return round(ship:VELOCITY:SURFACE:MAG).}, {return "-".}),
    list("Roll", {return round(ship:FACING:VECTOR * v(0,0,0)).}, {return launchAzimuth.}),
    list("Roll Rate", getRollRate@, {return "-".})
    //list("Apoapsis", round(ship:APOAPSIS), launchApoapsis),
    //list("Periapsis", round(ship:PERIAPSIS), launchApoapsis)
    //list("","",""),
    //list("Heading", ship:FACING * V(0,1,0), launchAzimuth),
    //list("Pitch", ship:FACING * V(0,0,1), targetPitch)
).

configureDisplay(headerList, dataTable).
doToOrbitLaunch().

