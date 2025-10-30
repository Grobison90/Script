
GLOBAL _LAUNCH_AZIMUTH is "-".
GLOBAL _TARGET_APOAPSIS is "-".
GLOBAL _AoA_MAX is 15.

local padAbortFlag is false.
local launchAbortFlag is false.
local curveConstant is 0.35. //this constant varies between 0 & 1 with values closer to 1 biasing towards a steeper initial ascent, and 0 being a linear
//Tracked data during launch.
local launchEscapeTowers is ship:PARTSNAMEDPATTERN(".*engine-les.*").
local maxDynPressure is 0.
local maxQAchieved is false.
local autoPilotOn is true.
local stagingLock is false.
local apoapsisAchieved is false.
local orbitAchieved is false.


GLOBAL function doPreflightChecks{
    setflightStatus("Preflight Checks").
    
    //Engines
    local ascentStage to ship:stagenum().
    local clamps to ship:partsnamedPattern(".*launchclamp.*").
    if (clamps:length() >=1) {
        set ascentStage to ship:stagenum() - 1.
    }
    set twr to getStageTWR(ascentStage).
    if(twr <= 1.0) {
        errorMessages:push("Error: Launch TWR < 1: (Stage: " + ascentStage + " - " + twr + ")").
    }.

    // are all the engines set to activate with their respective decouplers?
    //
    //-----Electrical
    // Is there a battery?

    // is there power generation?
    //
    //-----Safety
    // is there a parachute?
    // is there thermal protection?
    //
    //-----Coms
    // if this is a probe, is there an antenna?
    //
    //-----Controls
    // is there a reaction wheel?
    // is it strong enough?
    // is there RCS?
    //
    //-----Flight Plan
    // is the target Apoapsis in space?
    //
    //-----Situation
    // Before we start running any scripts, are we where we think we are? Launchpad?
    //-----

    
//return a list of errors. 
}

GLOBAL function resolveErrors{
    setflightStatus("Resolving Errors").
        until errorMessages:EMPTY {
        print errorMessages:peek().
        print("Override? y/n").
        local response is terminal:INPUT:getchar().
        if response = "y" {
            //Override the error
            errorMessages:pop().
        }

        else if response = "n" {
            set padAbortFlag to true.
            print("Launch Aborted.").
            return.
        }
    }
}

GLOBAL function doCountDown{
    parameter tMinus is 5.

    set voice to GETVOICE(0).
    set voice:WAVE to "Triangle".
    set freq to 260.
    set duration to 0.25.

    until tMinus = 0{
    setFlightStatus ("Launching in: " + tMinus).
    voice:PLAY(NOTE(freq,duration)).
    set tMinus to tMinus - 1.
    wait duration.
    wait 1-duration.

    }
    voice:PLAY(NOTE(freq*2, 0.75)).
    lock throttle to 1.
}

GLOBAL function doBoostUp {
    parameter speedThresh is 50.
    parameter altThresh is 200.

    setFlightStatus("Boost-Up"). 
    lock throttle to 1.
    lock steering to UP * R(0,0,180).//TODO is this right?
    on (ship:airspeed > 0.5) {
        notify("Liftoff").
    }

    wait until ship:airspeed > speedThresh  and ship:altitude > altThresh.
    notify("Boost-up complete").
}

GLOBAL function doRollProgram {
    SET _FLIGHT_STATUS TO "Roll Program".
    lock steering to heading(_LAUNCH_AZIMUTH, 90, 0).//this may be wrong TODO
    wait until (getdXdT({return VANG(UP:VECTOR, ship:facing:topvector).}) < 0.1). //TODO make this wait until we're actually facing the right direction
    //print SHIP:FACING:ROLL at(10, 20).
    notify("Roll Program Complete").
}

GLOBAL function doPitchProgram {
    SET _FLIGHT_STATUS TO "Pitch Program".

    if(launchEscapeTowers:length > 0){
        local LES is launchEscapeTowers[0].
        WHEN (ship:altitude > 30000 and getAcceleration(0.01) < 2*9.8) THEN {
            LES:activate.
            LES:getmodule("ModuleDecouple"):DOACTION("Decouple",true).
            launchEscapeTowers:remove(0).
            notify("LES Discarded").
        }
    }

    lock targetPitch to launchTargetPitch(ALT:RADAR).
    lock steering to heading(_LAUNCH_AZIMUTH, targetPitch).
    
    wait until ship:apoapsis >= _TARGET_APOAPSIS.

    
    set stagingLock to true.
    lock steering to ship:velocity:surface.
    lock throttle to 0.
    wait until ship:THRUST = 0.
    wait until ship:altitude > 70000.

}
GLOBAL function launchTargetPitch{
    parameter alt.
    return 90 * ( 1 - ( alt / 75000) ^ curveConstant ).    //This is the pitch function.
}

GLOBAL function doStaging{
    if not stagingLock{
        if (stage:DELTAV:current < 1.0) {
        doSafeStage(). 
        }
    }
}

GLOBAL function doSuborbitalLaunch{
    parameter targetAzimuth is 90.
    parameter targetApoapsis is 80000.
    parameter curveK is 1.

    GLOBAL _LAUNCH_AZIMUTH to targetAzimuth.
    GLOBAL _TARGET_APOAPSIS to targetApoapsis.
    set curveConstant to curveK.
    
    when AutoPilotOn then{
        monitorFlight().
        updateTelemetry().
        updateDisplay().
        PRESERVE.
    }.

    SET _ERROR_QUEUE TO doPreflightChecks().

    resolveErrors().
  
          
    if (not padAbortFlag) {
        doCountDown().

        when (ship:deltav>=1) then {
            doStaging().
            PRESERVE.
        }

        doBoostUp().
        doRollProgram().
        doPitchProgram().
        doReentry().

        //Check subroutine for errors, and report to FLIGHT_MANAGER. TODO
    }.

}

GLOBAL function doToOrbitLaunch {
    parameter targetAzimuth is 90.
    parameter targetApoapsis is 100000.
    parameter curveK is 0.35.

    GLOBAL _LAUNCH_AZIMUTH IS targetAzimuth.
    GLOBAL _TARGET_APOAPSIS to targetApoapsis.
    set curveConstant to curveK.

    SET _ERROR_QUEUE TO doPreflightChecks().
    resolveErrors().

    when AutoPilotOn then{
        monitorFlight().
        updateTelemetry().
        updateDisplay().
        PRESERVE.
    }

    if (not padAbortFlag) {
        doCountDown().

        when (not orbitAchieved) then {
            doStaging().
            PRESERVE.
        }

        doBoostUp().
        doRollProgram().
        doPitchProgram().
        doOrbitalInsertion().
        doShutdownSequence().
    }
    //Check subroutine for errors, and report to FLIGHT_MANAGER. TODO
}

GLOBAL function doLaunchToSpecifiedOrbit{
    parameter target_orbit.


    //launch time (roughly) is next (Ascending |descending node).
    // Launch azimuth is inclination (if ascending) or 360-inclination if descending.
    //wait until launch, and launch.

    //The real trick is how do I calculate where the AN and DN are?
    //AN is = to LAN right?
    //launch to a circular orbit, and then hohman to target orbit.



    //Check subroutine for errors, and report to FLIGHT_MANAGER.TODO
}

GLOBAL function doOrbitalInsertion{
    SET _FLIGHT_STATUS TO "Orbital Insertion".

    set OImaneuver to createOrbitalInsertionManeuver().
    addManeuverToPlan(OImaneuver).
    set _FLIGHT_STATUS to "Awaiting O.I. Maneuver".

    executeManeuver(OImaneuver, TRUE).

    set orbitAchieved to true.
}

GLOBAL function createOrbitalInsertionManeuver{

    local mu is ship:BODY:mu.
    local r1 is ship:BODY:radius + ship:PERIAPSIS.
    local r2 is ship:BODY:radius + ship:APOAPSIS.

    local v1 is sqrt(mu / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).

    return node((time:seconds + ship:Orbit:ETA:apoapsis) , 0 , 0 , v1).


}

GLOBAL function doDeorbit{
    parameter target_periapsis.

    set _FLIGHT_STATUS to "De-Orbit".
    lock steering to retrograde.
    lock throttle to 1.
    wait until SHIP:PERIAPSIS <= target_periapsis.
    lock throttle to 0.

}

GLOBAL function doReentry{

set _FLIGHT_STATUS to "Reentry".

wait until ship:verticalspeed < 0.

set proximalDecoupler to findNearestPart("Decoupler").
set decouplerModule to proximalDecoupler:(0).
// print proximalDecoupler at(10, 50).

set parachutes to getPartsNamed("chute").
set drogues to getPartsNamed("drogue").
for d in drogues{
    parachutes:ADD(d).
}

set parachuteModules to list().
for d in parachutes{
    parachuteModules:ADD(d:GETMODULE("moduleParachute")).
}

wait until ship:altitude < 75000.

LOCK STEERING to UP + R(45,0,0).
notify("Decoupling.").
wait 5.

decouplerModule:DOEVENT("decouple").
wait 3.

LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.

wait until ship:altitude < 20000.
deploySafeChutes().
wait until ship:STATUS = "Landed" or ship:STATUS = "Splashed".

//Check subroutine for errors, and report to FLIGHT_MANAGER. TODO
}

GLOBAL function deploySafeChutes{
    until CHUTES {
        CHUTESAFE ON.
        return true.
    }
}

GLOBAL function doShutdownSequence{
    set _FLIGHT_STATUS to "Shutting Down".
    lock throttle to 0.
    if(not ship:STATUS = "Landed"){
        lock steering to prograde.
        SAS ON.
        set SASMODE to "PROGRADE".
        set autoPilotOn to false.
    }
}

function doAbortSequence {
    // local capsule to SHIP:
    ABORT ON.
    setFlightStatus("ABORTING!").
    setOperationStatus("OFF NOMINAL, ERROR.").
    updateDisplay().
    if(launchEscapeTowers:length > 0){
        local LES is launchEscapeTowers[0].
        if (not LES:IGNITION) LES:ACTIVATE.
        wait until LES:FLAMEOUT.
        LES:GETMODULE("ModuleDecouple"):DOACTION("Decouple", true).
    }
    lock STEERING to ship:srfretrograde.
    wait until ship:verticalspeed < 0.
    deploySafeChutes().
    UNLOCK STEERING.

    // function playAlarm{//TODO
    // set voice to GETVOICE(0).
    // set voice:WAVE to "SQUARE".
    // set high to 666.
    // set low to 333.
    // set dur to 0.5.
    // set reps to 3.
    // set alarmDuration to 10.

    // until alarmDuration <= 0 {
    //     for i in range(0,reps){
    //         voice:PLAY(NOTE(high, dur)).
    //         wait dur.
    //         voice:PLAY(NOTE(low,dur)).
    //         wait dur.
    //     }
    //     wait 2*dur.
    //     set alarmDuration to alarmDuration - dur.
        // }
    // }
}

GLOBAL function doSafeStage{
    parameter isHotStage is true.

    local hotStageSepTime is 1.
    local coldStageSepTime is 2.
    
    wait until stage:ready.
    if _FLIGHT_MANAGER notify("Stage " + ship:stagenum + " complete").

    if isHotStage {
        stage.
        wait hotStageSepTime.
    }

    else {
        lock throttle to 0.
        stage.
        wait coldStageSepTime.
        lock throttle to 1.
    }
    
}

GLOBAL function updateTelemetry{//This method is going to continue to update flight parameter values
        if (maxDynPressure < ship:dynamicPressure) {
        set maxDynPressure to ship:dynamicPressure.
        }
        if(maxDynPressure >= 0.005 and ship:dynamicPressure < maxDynPressure and not maxQAchieved){
            if _FLIGHT_MANAGER notify("Max Q").
            set maxQAchieved to true.

        }

}

function monitorFlight{//This method is purely for monitoring for flight warnings, and flight aborts
    if launchAbortFlag return.
    local WARNING is false.
    local ABORT is false.
    local errorText is "".
    
    local AoA is VANG(ship:FACING:FOREVECTOR, ship:VELOCITY:SURFACE).
    if AoA > _AoA_MAX and ship:airspeed > 25 and ship:altitude < 18000 {
        set ABORT to TRUE.
        set errorText to "AOA EXCEEDED!".
    }

    if ship:DELTAV = 0 and launchApoapsis > ship:apoapsis {
        set _OPERATION_STATUS to "Error. See Log.".
        notify("Target Apoapsis Not Achieved").
    }

    if(WARNING){

    }
    if(ABORT){
        set launchAbortFlag to true.
        doAbortSequence().
        notify("ABORT: " + errorText).

    }
}

