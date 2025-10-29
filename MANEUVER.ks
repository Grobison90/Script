runOncePath("0:/SHIP.ks").

GLOBAL function addManeuverToPlan{
    parameter mnvr.
    ADD mnvr.
}

GLOBAL function removeManeuverFromPlan{
    parameter mnvr.
    REMOVE mnvr.
}

GLOBAL function executeManeuver{
    parameter mnvr, isPrecise.

    local startTime to calculateBurnStartTime(mnvr, isPrecise).
    lock steering to mnvr:burnvector.
    wait until TIME:SECONDS > startTime - 10.

    local dV0 is mnvr:DELTAV.
    if isPrecise {burnPrecisely().}
    else {burnRoughly().}
    lock steering to ship:PROGRADE.
    removeManeuverFromPlan(mnvr).

    local function burnPrecisely{//Implement this method. TODO
        burnRoughly().
    }

    local function burnRoughly{
        wait until TIME:SECONDS >= startTime.
        lock throttle to 1.
        wait until VDOT(dV0, mnvr:DELTAV) < 1.
        lock throttle to 0.
    }
    
}  

GLOBAL function calculateBurnStartTime {
    parameter mnvr.
    parameter integrated. // if true we'll use the integration approach to calculate the burn start time.

    if integrated{
        return calculateBurnStartTimeIntegration(mnvr).
    }.

    else {
        return calculateBurnStartTimeSimply(mnvr).
    }.

}

GLOBAL function calculateBurnStartTimeSimply{
    parameter mnvr.
    //will be accurate enough for short burns.
    local burnTime is (mnvr:DELTAV:mag / (ship:maxThrust / ship:mass)).
return mnvr:TIME - (burnTime / 2).
}

GLOBAL function calculateBurnStartTimeIntegration{
    parameter mnvr.
    //will be more accurate for very long burns.

    //assignments in the right units for simplicity in maths below:
    local dV is mnvr:DELTAV:MAG.
    local Tau is SHIP:MAXTHRUST * 10^3 .//SHIP:MAXTHRUST is given in kN, converting to Newtons.
    local massFlow is (sumEnginesMaxMassFlow(getActiveEngines()) * 10^3). // for some reason Max Mass Flow is given in Mega-grams.
    local shipMass is SHIP:MASS * 10^3. //SHIP:MASS is in metric tons, converting to kg.
    local C is calculateConstant().

    local exponent is ((massFlow/Tau) * (c-dV/2)). // just breaking this down so it's easier to math. Used in next line.
    local halfBurn is (-1 * (CONSTANT:E^(exponent) - shipMass) / massFlow ).

    function calculateConstant{
        return (Tau * ln(shipMass)) / massFlow.
    }

    return mnvr:TIME - halfBurn.
}

