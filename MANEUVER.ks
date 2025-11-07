runOncePath("0:/SHIP.ks").

GLOBAL function executeManeuver{
    parameter mnvr, isPrecise.
    
    local startTime to calculateBurnStartTime(mnvr, isPrecise).
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
        wait until VDOT(dV0, mnvr:DELTAV) < (dV0:DELTAV *0.05).
        lock throttle to 0.1.
        wait until VDOT(dV0, mnvr:DELTAV) < 0.1.
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

        declare mt is CONSTANT:e ^(dV / (isp * CONSTANT:g0)) / m0.
        return (mt - m0)/mFlow.

    }

    if(deltaV < stage:DeltaV:Vacuum){
        declare enginesThisStage is getEnginesByStage(ship:stagenum).
        declare specImpulse is getAverageISP(enginesThisStage).
        declare massFlow is sumEnginesMaxMassFlow(enginesThisStage).
        return calculate(deltaV, ship:mass, massFlow, specImpulse).

    } else {
        declare time1 is getStageBurnTime(ship:stagenum).
        declare massNextStage is getStageMass(ship:stagenum-1).
        declare enginesNextStage is getEnginesByStage(ship:stagenum - 1).
        declare specImpulseNextStage is getAverateISP(enginesNextStage).
        declare massflowNextStage is sumEnginesMaxMassFlow(enginesNextStage).
        return time1 + calculate(deltaV - stage:DELTAV:VACUUM, massNextStage, massflowNextStage, specImpulseNextStage).
    }
}

GLOBAL function calculateBurnStartTime{
    parameter mnvr.

    return mnvr:time - calculateBurnTime(mnvr:deltaV:mag) / 2.
}


