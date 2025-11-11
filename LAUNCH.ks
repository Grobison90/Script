RunOncePath("0:/CONSOLE.ks").
RunOncePath("0:/SHIP.ks").
RunOncePath("0:/MANEUVER.ks").

GLOBAL _LAUNCH_AZIMUTH is 90.
GLOBAL _TARGET_APOAPSIS is 100000.
GLOBAL _AoA_MAX is 15.

local padAbortFlag is false.
local launchAbortFlag is false.
local curveConstant is 0.35. //this constant varies between 0 & 1 with values closer to 1 biasing towards a steeper initial ascent, and 0 being a linear
//Tracked data during launch.
local launchEscapeTower is ship:PARTSTAGGED("LES").
local reentryDecoupler is SHIP:PARTSTAGGED("REENTRY_DECOUPLER").
local currentEngines is list().
local maxDynPressure is 0.
local maxQAchieved is false.
local autoPilotOn is true.
local stagingLock is false.
local apoapsisAchieved is false.
local orbitAchieved is false.



GLOBAL function doPreflightChecks{
    SET _FLIGHT_STATUS TO "Preflight Checks".
    
    //Engines
    set twr to getStageTWR(ship:stagenum-1).
    if(twr <= 1.0) {
        _ERROR_QUEUE:push("Error: Launch TWR < 1: (Stage: " + ascentStage + " - " + twr + ")").
    }.

    if(reentryDecoupler:LENGTH = 0){
        _ERROR_QUEUE:Push("Error: No Reentry Decoupler").
    }
    // are all the engines set to activate with their respective decouplers?
    //
    //-----Electrical
    // Is there a battery?

    // is there power generation?
    //
    //-----Safety
    // is there a parachute?
    local chutes is ship:partsdubbedpattern(".*chute.*").
    if(chutes:length = 0){
        _ERROR_QUEUE:push("Error: No Chutes Onboard").
    }
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
    set _FLIGHT_STATUS to "Resolving Errors".
    until _ERROR_QUEUE:EMPTY {
        print _ERROR_QUEUE:peek().
        print("Override? y/n").
        local response is terminal:INPUT:getchar().
        if response = "y" {
            //Override the error
            _ERROR_QUEUE:pop().
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
    SET _FLIGHT_STATUS TO ("Launching in: " + tMinus).
    voice:PLAY(NOTE(freq,duration)).
    set tMinus to tMinus - 1.
    wait duration.
    wait 1-duration.

    }
    voice:PLAY(NOTE(freq*2, 0.75)).
}

GLOBAL function doBoostUp {
    parameter speedThresh is 50.
    parameter altThresh is 200.

    
    SET _FLIGHT_STATUS TO("Boost-Up"). 
    lock throttle to 1.
    lock steering to UP * R(0,0,180).//TODO is this right?
    doSafeStage().

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

    if (not LaunchEscapeTower:length = 0){    
        WHEN (ship:altitude > 30000 and getAcceleration(0.01) < 2*9.8) THEN {
            LaunchEscapeTower:activate.
            LaunchEscapeTower:getmodule("ModuleDecouple"):DOACTION("Decouple",true).
            notify("LES Discarded").
            }
        }

    lock targetPitch to launchTargetPitch(ALT:RADAR).
    lock steering to heading(_LAUNCH_AZIMUTH, targetPitch).
    
    wait until ship:apoapsis >= _TARGET_APOAPSIS.
       
    lock steering to ship:velocity:surface.
    lock throttle to 0.
    wait until ship:THRUST = 0.
    notify("Apoapsis Achieved").
    set apoapsisAchieved to true.
    set _FLIGHT_STATUS to "Coasting to Space".
    wait until ship:altitude > 70000.

}
GLOBAL function launchTargetPitch{
    parameter a.
    return 90 * ( 1 - ( a / 75000) ^ curveConstant ).    //This is the pitch function.
}

GLOBAL function doStaging{
    list ENGINES in currentEngines.
    
    if not stagingLock{
        for e in currentEngines{
        if (e:flameout) { 
            doSafeStage().
            break.}

    }
        // if (stage:DELTAV:current < 0.05) {
        // doSafeStage(). 
        // }
    }
}

GLOBAL function doSuborbitalLaunch{
    parameter targetAzimuth is 90.
    parameter targetApoapsis is 80000.
    parameter curveK is 0.75.

    GLOBAL _LAUNCH_AZIMUTH to targetAzimuth.
    GLOBAL _TARGET_APOAPSIS to targetApoapsis.
    set curveConstant to curveK.
    
    when AutoPilotOn then{
        monitorFlight().
        updateTelemetry().
        PRESERVE.
    }.

    doPreflightChecks().
    resolveErrors().
  
          
    if (not padAbortFlag) {
        doCountDown().

        when (not apoapsisAchieved) then {
            doStaging().
            return not apoapsisAchieved.
        }

        doBoostUp().
        doRollProgram().
        doPitchProgram().
        doReentry().

    }.

}

GLOBAL function doToOrbitLaunch {
    parameter targetAzimuth is 90.
    parameter targetApoapsis is 100000.
    parameter curveK is 0.35.

    GLOBAL _LAUNCH_AZIMUTH IS targetAzimuth.
    GLOBAL _TARGET_APOAPSIS to targetApoapsis.
    set curveConstant to curveK.

    doPreflightChecks().
    resolveErrors().

    when AutoPilotOn then{
        monitorFlight().
        updateTelemetry().
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
    }
}

GLOBAL function doLaunchToSpecifiedOrbit{
    parameter target_orbit.


    //launch time (roughly) is next (Ascending |descending node).
    // Launch azimuth is inclination (if ascending) or 360-inclination if descending.
    //wait until launch, and launch.

    //The real trick is how do I calculate where the AN and DN are?
    //AN is = to LAN right?
    //launch to a circular orbit, and then hohman to target orbit.



}

GLOBAL function doOrbitalInsertion{
    SET _FLIGHT_STATUS TO "Orbital Insertion".

    set OImaneuver to createOrbitalInsertionManeuver().
    add OImaneuver.
    set _FLIGHT_STATUS to "Awaiting O.I. Maneuver".

    executeManeuver(OImaneuver, TRUE).
    //Check if orbit achieved TODO
    set orbitAchieved to true.
}



GLOBAL function doDeorbit{
    parameter target_periapsis.
    parameter atTime is TIME:SECONDS + 10.

    until (TIME:SECONDS >= atTime){
        set _FLIGHT_STATUS to "De-Orbit Burn in: " + round(atTime - TIME:SECONDS).
    }.

    
    lock steering to retrograde.
    wait until (VANG(ship:facing:forevector, SHIP:retrograde:forevector) < 5).
    lock throttle to 1.
    wait until SHIP:PERIAPSIS <= target_periapsis.
    lock throttle to 0.

}

GLOBAL function doReentry{

set _FLIGHT_STATUS to "Reentry".
LOCK STEERING to RETROGRADE.
wait until ship:altitude < 75000.

notify("Decoupling.").
if(reentryDecoupler:LENGTH = 1){
    reentryDecoupler:GETMODULE("ModuleDecouple"):doEvent("Decouple").
}
else{
local decoupled is false.
    for p in ship:rootpart:children{
        if p:HASMODULE("ModuleDecouple"){
            p:GETMODULE("ModuleDecouple"):doevent("Decouple").
            set decoupled to true.
        }
    }
    if not decoupled{
            for p in ship:rootpart:children {
                for q in p:children{
                    if p:HASMODULE("ModuleDecouple"){
                        q:GETMODULE("ModuleDecouple"):DOECENT("Decouple").
                    }
                }
            }
        }

wait 5.

LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.

wait until ship:altitude < 20000.
deploySafeChutes().
unlock steering.
wait until ship:STATUS = "Landed" or ship:STATUS = "Splashed".

}
}

GLOBAL function deploySafeChutes{
    notify("Deploying Chutes").
    when (NOT CHUTESSAFE) THEN{
        CHUTESSAFE ON.
        return (NOT CHUTES).
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
    SET _FLIGHT_STATUS TO("ABORTING!").
    SET _OPERATION_STATUS TO ("OFF NOMINAL, ERROR.").
    if(not launchEscapeTower:length = 0){
        launchEscapeTower:activate.
        launchEscapeTower:getmodule("ModuleDecouple"):DOACTION("Decouple",true).
        notify("LES Activated").
    }
    if(not reentryDecoupler:length = 0){
        reentryDecoupler:getmodule("ModuleDecouple"):DOACTION("Decouple",true).
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
    // set reps to 2.
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
    //     }
    // }
}

GLOBAL function doSafeStage{
    parameter isHotStage is true.

    local hotStageSepTime is 1.
    local coldStageSepTime is 2.
    
    wait until stage:ready.
    notify("Stage " + ship:stagenum + " complete").

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
            notify("Max Q").
            set maxQAchieved to true.

        }

}

function monitorFlight{//This method is purely for monitoring for flight warnings, and flight aborts
    if launchAbortFlag return.
    local WARNING is false.
    local ABORT is false.
    local errorText is "".
    
    local AoA is VANG(ship:FACING:FOREVECTOR, ship:VELOCITY:SURFACE).
    if AoA > _AoA_MAX and ship:airspeed > 25 and ship:altitude < 18000{
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

