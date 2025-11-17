runOncePath("0:/LAUNCH.ks").
runOncepath("0:/ORBITS.ks").
runOncePath("0:/MANEUVER.ks").
runOncePath("0:/CONSOLE.ks").
runOncePath("0:/RENDEZVOUS.ks").
runOncePath("0:/MATH.ks").
CLEARSCREEN.

local targetObj is VESSEL("kOS TARGET VEHICLE").

    //Get a place to start our search from.
local calcStartTime is TIME:SECONDS.
local targetPhaseAngle is transferPhaseAngleSimple(targetObj:ORBIT, ship:ORBIT).// This will be given in Mean Anomaly degrees.
PRINT("Target PA: " + targetPhaseAngle).
local currentPhaseAngle is phaseAngle(targetObj, ship).
PRINT("Current PA: " + currentPhaseAngle).
local phaseRate is (360/ship:orbit:period) - (360/targetObj:orbit:period).
PRINT("Phase Rate: " + phaseRate).
local degreesUntilTransfer is targetPhaseAngle - currentPhaseAngle.
PRINT("degrees Until: " + degreesUntilTransfer).
local timeUntilTransfer is degreesUntilTransfer / phaseRate.
PRINT("ETA " + timeUntilTransfer).

//Start calculating a real transfer at the time estimate.
local shipTAatDeparture is trueAnomalyAtTime(SHIP, calcStartTime + timeUntilTransfer).
print("Ship TA at Departure: " + shipTAatDeparture).
local shipRadiusAtDeparture is radiusAtTrueAnomaly(shipTAatDeparture, ship:ORBIT).
local rendezvousTL is trueAnomalyToTrueLongitude(shipTAatDeparture + 180, ship:ORBIT).
local rendezvousRadius is radiusAtTrueAnomaly(trueLongitudeToTrueAnomaly(rendezvousTL, targetObj:ORBIT), targetObj:ORBIT).
local SMAofTransfer is (shipRadiusAtDeparture + rendezvousRadius) / 2.
local TOF is period(SMAofTransfer, ship:ORBIT:BODY)/2.
PRINT("Time of Flight: " + TOF).

local targetTLatArrival is mod(trueAnomalyToTrueLongitude(trueAnomalyAtTime(targetObj, calcStartTime + timeUntilTransfer + TOF), targetObj:ORBIT), 360).
PRINT("Target TL at Arrival: " + targetTLatArrival).