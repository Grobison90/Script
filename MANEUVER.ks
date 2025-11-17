runOncePath("0:/SHIP.ks").
runOncePath("0:/ORBITS.ks").

GLOBAL function executeManeuver{
    parameter mnvr.
    parameter isPrecise is false.
    
    local startTime to calculateBurnStartTime(mnvr).
    lock steering to mnvr:burnvector.
    wait until TIME:SECONDS > startTime - 10.
    set _FLIGHT_STATUS to "Executing Burn".
    
    local dV0 is mnvr:DELTAV.
    if isPrecise {burnPrecisely().}
    else {burnRoughly().}
    lock steering to ship:PROGRADE.
    REMOVE mnvr.

    local function burnPrecisely{//Implement this method. TODO
        WAIT until TIME:SECONDS >= startTime.
        lock throttle to 1.
        wait until VDOT(dV0, mnvr:DELTAV) < 10.
        lock throttle to 0.1.
        wait until VDOT(dV0, mnvr:DELTAV) < 0.1.
        lock throttle to 0.
    }

    local function burnRoughly{
        wait until TIME:SECONDS >= startTime.
        lock throttle to 1.
        wait until VDOT(dV0, mnvr:DELTAV) < 1.
        lock throttle to 0.
    }
    
}  

GLOBAL function calculateBurnTime {
    parameter deltaV.

    local function calculate{
        parameter dV, m0, mFlow, isp.

        local mt is m0 / (CONSTANT:e^(dV / (isp * CONSTANT:g0))) .
        return (m0 - mt)/mFlow.

    }

    if(deltaV < stage:DeltaV:Vacuum){
        local enginesThisStage is getEnginesByStage(ship:stagenum).
        local specImpulse is getAverageISP(enginesThisStage).
        local massFlow is sumEnginesMaxMassFlow(enginesThisStage).
        return calculate(deltaV, ship:mass, massFlow, specImpulse).

    } else {
        local time1 is getStageBurnTime(ship:stagenum).
        local massNextStage is getStageMass(ship:stagenum-1).
        local enginesNextStage is getEnginesByStage(ship:stagenum - 1).
        local specImpulseNextStage is getAverateISP(enginesNextStage).
        local massflowNextStage is sumEnginesMaxMassFlow(enginesNextStage).
        return time1 + calculate(deltaV - stage:DELTAV:VACUUM, massNextStage, massflowNextStage, specImpulseNextStage).
    }
}

GLOBAL function calculateBurnStartTime{
    parameter mnvr.

    return mnvr:time - calculateBurnTime(mnvr:deltaV:mag) / 2.
}

GLOBAL function createOrbitalInsertionManeuver{
    
    local mu is ship:BODY:mu.
    local r1 is ship:BODY:radius + ship:PERIAPSIS.
    local r2 is ship:BODY:radius + ship:APOAPSIS.

    local v1 is sqrt(mu / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).

    return node((time:seconds + ship:Orbit:ETA:apoapsis) , 0 , 0 , v1).
}

GLOBAL function planCircularize{
    parameter atApoapsis is true.
    local radius is ship:ORBIT:PERIAPSIS + ship:orbit:body:radius.
    local deltaT is ship:ORBIT:ETA:PERIAPSIS.
    if(atApoapsis){
        set radius to SHIP:ORBIT:APOAPSIS + SHIP:ORBIT:BODY:RADIUS.
        set deltaT to SHIP:ORBIT:ETA:APOAPSIS.
    }
    local targetOrbit is CREATEORBIT(0, 0, radius, 0, 0, 0, 0, ship:orbit:body).
    planHohmann2(targetOrbit, ship:orbit, TIME:SECONDS + deltaT).
}

GLOBAL function planHohmannToRadius{
    parameter radius.
    parameter atTime.

    local shipTAatT is trueAnomalyAtTime(ship, atTime).
    local HTO_SMA is (radiusAtTrueAnomaly(shipTAatT) + radius) / 2.
    local shipVatT is velocityAtTrueAnomaly(shipTAatT).
    return visViva(HTO_SMA, HTO_SMA, SHIP:BODY) - shipVatT.
}

GLOBAL function planHohmann1{//Creates the first of 2 maneuvers in a hohmann transfer.
    parameter targetOrbit.
    parameter atTime.

    local r1 is ship:ORBIT:SEMIMAJORAXIS. 
    local r2 is targetOrbit:SEMIMAJORAXIS.

    local dV1 is visViva(r1, (r1 + r2)/2, ship:body) - visViva(r1, r1, ship:body). // 
    ADD NODE(atTime, 0, 0, dV1).//TODO make this ASAP?
}

GLOBAL function planHohmann2{//Creates the second maneuver of a hohmann transfer.
    parameter targetOrbit.
    parameter atTime.

    local r1 is SHIP:ORBIT:SEMIMAJORAXIS.
    local r2 is targetOrbit:SEMIMAJORAXIS.

    local dV is visViva(r2, r2, SHIP:BODY) - visViva(r2, (r1+r2)/2, SHIP:BODY).
    ADD NODE(atTime, 0, 0, dV).

}

GLOBAL function hohmannTransferPeriodSimple{//Simplified version assuming circular orbits.
    parameter targetOrbit.
    parameter currentOrbit.

    local r1 is currentOrbit:semimajoraxis.
    local r2 is targetOrbit:semimajoraxis.
    return CONSTANT():PI * sqrt(((r1+r2)/2)^3 / ship:body:MU).
}

GLOBAL function planHohmannToOrbit{ // assuming a roughly circular starting orbit
//todo
    parameter targetOrbit.
    parameter atTime.

    local r1 is ship:orbit:SEMIMAJORAXIS. 
    local r2 is targetOrbit:SEMIMAJORAXIS.
    local transitTime is hohmannTransferPeriodSimple(targetOrbit, ship:ORBIT).

    planHohmann1(targetOrbit, ship:ORBIT, atTime).
    planHohmann2(targetOrbit, ship:ORBIT, atTime + transitTime).

}

GLOBAL function phaseAngle{
    parameter trgtBody.
    parameter fromBody.
    local trgtTA is trgtBody:ORBIT:TRUEANOMALY.
    local fromTA is fromBody:ORBIT:TRUEANOMALY.

    return mod(trueAnomalyToTrueLongitude(trgtTA, trgtBody:ORBIT) - trueAnomalyToTrueLongitude(fromTA, fromBody:ORBIT), 360).
}

GLOBAL function transferPhaseAngleSimple{//Assumes circular orbits.
    parameter trgtOrbit.
    parameter currentOrbit.

    local transitTime is hohmannTransferPeriodSimple(trgtOrbit, currentOrbit).

    return mod((180 - (transitTime * 360) / trgtOrbit:PERIOD) + 360, 360).//This will be in "mean anomaly" terms.

}



GLOBAL function planHohmannToIntercept{//TODO test this.
    parameter trgt.

    local targetPhaseAngle is transferPhaseAngleSimple(trgt:ORBIT, ship:ORBIT).// This will be given in Mean Anomaly degrees.
    PRINT("Target PA: " + targetPhaseAngle).
    local currentPhaseAngle is phaseAngle(trgt, ship).
    PRINT("Current PA: " + currentPhaseAngle).
    local phaseRate is (360/ship:orbit:period) - (360/trgt:orbit:period).
    PRINT("Phase Rate: " + phaseRate).
    local degreesUntilTransfer is targetPhaseAngle - currentPhaseAngle.
    
    PRINT("degrees Until: " + degreesUntilTransfer).

    local timeUntilTransfer is degreesUntilTransfer / phaseRate.
    PRINT("ETA " + timeUntilTransfer).
    local departureTime is

    planHohmannToRadius(trgt:ORBIT, ship:ORBIT, TIME:SECONDS + timeUntilTransfer).
}




