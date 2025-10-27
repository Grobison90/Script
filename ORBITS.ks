    
GLOBAL function vectorToAngleDegrees{
    parameter vec.


}

GLOBAL function angleDegreesToVector{
    parameter ang.

    local x is cos(ang).
    local z is sin(ang).

    return v(x,0,z).

}

GLOBAL function createTargetOrbit{
    parameter TARGET_BODY.
    parameter TARGET_APOAPSIS.
    parameter TARGET_PERIAPSIS.
    parameter TARGET_ECCENTRICITY.
    
    parameter TARGET_INCLINATION.
    parameter TARGET_LAN.
    parameter TARGET_AoP.

    local TARGET_SMA is calculateSMA(TARGET_APOAPSIS, TARGET_PERIAPSIS, TARGET_BODY).

    return createOrbit(TARGET_INCLINATION, TARGET_ECCENTRICITY, TARGET_SMA, TARGET_LAN, TARGET_AoP, 0, TIME:SECONDS, TARGET_BODY ).
    
}


GLOBAL function visViva{
    parameter radius.
    parameter SMA.
    parameter parentBody.

    return sqrt(parentBody:MU * ((2 / radius) - (1 / SMA))).
}


GLOBAL function planHohmanToOrbit{ // assuming a roughly circular starting orbit
//todo
    parameter targetOrbit.
   
    //meanTargetAlt = (targetOrbit:APOAPSIS + targetOrbit:PERIAPSIS) / 2.
    local meanTargetAlt is (targetOrbit:APOAPSIS + targetOrbit:PERIAPSIS) / 2.
    local r1 is ship:orbit:apoapsis + ship:orbit:body:radius. 
    local r2 is meanTargetAlt + targetOrbit:body:radius.

    local dV1 is visViva(r1, (r1 + r2), ship:body) - visViva(r1, r1, ship:body).
    local burn1ETA is TIME:SECONDS + 60.
    ADD NODE(TIME:SECONDS + 60, 0, 0, dV1).//TODO make this ASAP?

    local dV2 is visViva(r2, 2*r2, ship:body) - visViva(r2, (r1+r2), ship:body).
    local transitTime is CONSTANT():PI * sqrt((r1+r2)^3 / ship:body:MU).
    ADD NODE(burn1ETA + transitTime, 0, 0, dV2).
    


}

GLOBAL function calculateSMA{
    parameter ORBIT_APOAPSIS.
    parameter ORBIT_PERIAPSIS.
    parameter ORBIT_BODY.

    set rA to ORBIT_APOAPSIS + ORBIT_BODY:RADIUS.
    set rP to ORBIT_PERIAPSIS + ORBIT_BODY:RADIUS.

    return ( rA + rP )/2.
}

GLOBAL function calculateEccentricity{
    parameter ORBIT_APOAPSIS.
    parameter ORBIT_PERIAPSIS.
    parameter ORBIT_BODY.

    set rA to ORBIT_APOAPSIS + ORBIT_BODY:RADIUS.
    set rP to ORBIT_PERIAPSIS + ORBIT_BODY:RADIUS.

    return ((rA - rP)/(rA + rP)).

}

GLOBAL function calculateMeanMotionFromSMA{
    parameter SMA.
    parameter ORBIT_BODY.

    set BODY_MU to ORBIT_BODY:MU.

    return SQRT(BODY_MU/SMA^3) * CONSTANT:radtodeg.
}

//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function trueAnomalyToMeanAnomaly{
    parameter TRUE_ANOMALY_DEGREES.
    parameter ECCENTRICITY.

//    PRINT("--").
//    print "TRUE_ANOM_DEG: " + TRUE_ANOMALY_DEGREES.

    local TRUE_ANOMALY_RADS is TRUE_ANOMALY_DEGREES * CONSTANT:degtorad.

    local ECCENTRIC_ANOMALY_RADS is TrueAnomalyToEccentricAnomaly(TRUE_ANOMALY_RADS, ECCENTRICITY).
    print "ECC_ANOM_RAD: " + ECCENTRIC_ANOMALY_RADS.

    local MEAN_ANOMALY_RADS is EccentricAnomalyToMeanAnomaly(ECCENTRIC_ANOMALY_RADS, ECCENTRICITY).
    print "MEAN_ANOM_RAD: " + MEAN_ANOMALY_RADS.


    return MEAN_ANOMALY_RADS * CONSTANT:radtodeg.

}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
local function trueAnomalyToEccentricAnomaly{
    parameter TRUE_ANOMALY_RADS.
    parameter ECCENTRICITY.

    //print "TRUE_ANOM_RADS: " + TRUE_ANOMALY_RADS.

    local arg1 is sin(TRUE_ANOMALY_RADS * constant:radtodeg) * SQRT(1 - ECCENTRICITY^2).
   // print "arg1: " + arg1.

    local arg2 is ECCENTRICITY + cos(TRUE_ANOMALY_RADS*constant:radtodeg). 
   // print "arg2: " + arg2.
    
    local ECCENTRIC_ANOMALY_DEG is arcTan2(arg1, arg2).
    
   // print "ECC_ANOM_DEG: " + ROUND(ECCENTRIC_ANOMALY_DEG).

    return ECCENTRIC_ANOMALY_DEG * constant:degtorad. 

}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
local function eccentricAnomalyToMeanAnomaly{
    parameter ECCENTRIC_ANOMALY_RADS.//in radians
    parameter ECCENTRICITY.

    // print "ECC Anom Rad: " + ROUND(ECCENTRIC_ANOMALY_RADS).

    local MEAN_ANOMALY_RAD is ECCENTRIC_ANOMALY_RADS * sin(ECCENTRICITY).
    set MEAN_ANOMALY_RAD to mod(MEAN_ANOMALY_RAD, 2*CONSTANT:pi).

//    print "MEAN_ANOM_0: " + ROUND(MEAN_ANOMALY_RAD*constant:radtodeg).

    if MEAN_ANOMALY_RAD < 0 {set MEAN_ANOMALY_RAD to MEAN_ANOMALY_RAD + 2*CONSTANT:pi.}

//    print "MEAN_ANOM_1: " + ROUND(MEAN_ANOMALY_RAD*constant:radtodeg).

    return MEAN_ANOMALY_RAD.
}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function meanAnomalyToTrueAnomaly{
    parameter MEAN_ANOMALY_DEG.
    parameter ECCENTRICITY.

    local MEAN_ANOMALY_RADS is MEAN_ANOMALY_DEG * CONSTANT:degtorad.

    local ECCENTRIC_ANOMALY_RADS is meanAnomalyToEccentricAnomaly(MEAN_ANOMALY_RADS, ECCENTRICITY).
    local TRUE_ANOMALY_RADS is eccentricAnomalyToTrueAnomaly(ECCENTRIC_ANOMALY_RADS, ECCENTRICITY).

    return TRUE_ANOMALY_RADS * CONSTANT:radtodeg.

}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
local function meanAnomalyToEccentricAnomaly{
    parameter MEAN_ANOMALY_RADS.
    parameter ECCENTRICITY.

    local Enew is MEAN_ANOMALY_RADS + ECCENTRICITY.
    if MEAN_ANOMALY_RADS > CONSTANT:pi{
        set Enew to MEAN_ANOMALY_RADS - ECCENTRICITY.
        }
    set Eold to Enew +0.001.
    until abs(Enew - Eold) <= 1*10^8{
        set Eold to Enew.
        set Enew to Eold + (MEAN_ANOMALY_RADS - Eold + ECCENTRICITY*sin(Eold*constant:radtodeg))/(1 - ECCENTRICITY*cos(Eold*constant:radtodeg)).
    }
    return Enew.
}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
local function eccentricAnomalyToTrueAnomaly{
    parameter ECCENTRIC_ANOMALY_RADS.
    parameter ECCENTRICITY.

    local TRUE_ANOMALY is arcTan2(sin(ECCENTRIC_ANOMALY_RADS*Constant:radtodeg)*sqrt(1-ECCENTRICITY^2), 
                                            cos(ECCENTRIC_ANOMALY_RADS * Constant:radtodeg)-ECCENTRICITY).
    if TRUE_ANOMALY < 0{
        set TRUE_ANOMALY to TRUE_ANOMALY + 2*CONSTANT:pi.
    }
    
    return TRUE_ANOMALY.
}

GLOBAL function timeUntilTrueAnomaly{//this will take a true anomaly and return the time until ship reaches this true anomaly next.
    parameter TRUE_ANOMALY_DEG.

    print "TRUE_ANOM DEG: " + TRUE_ANOMALY_DEG.

    local MEAN_ANOMALY_DEG is trueAnomalyToMeanAnomaly(TRUE_ANOMALY_DEG, ship:orbit:eccentricity).
    local CURRENT_MEAN_ANOMALY is trueAnomalyToMeanAnomaly(ship:orbit:trueanomaly, ship:orbit:eccentricity).
    local MEAN_MOTION is calculateMeanMotionFromSMA(ship:orbit:SEMIMAJORAXIS, ship:orbit:body).

    // print "mean anom deg: " + MEAN_ANOMALY_DEG.
    // print "curr anom deg: " + CURRENT_MEAN_ANOMALY.
    // print "mean motion: " + MEAN_MOTION.

    local result is ((MEAN_ANOMALY_DEG - CURRENT_MEAN_ANOMALY) / MEAN_MOTION).

    // if result < 0 { return result + ship:orbit:period.}
    // else {
        return result.  //TODO test this function.

}

GLOBAL function vectorToRelativeAN{//todo No idea if this works.
    parameter TARGET_ORBIT.

    local SHIP_ORBIT_AXIS is vectorToNormal(ship:ORBIT).
    local TARGET_ORBIT_AXIS is vectorToNormal(TARGET_ORBIT).

    return vectorCrossProduct(SHIP_ORBIT_AXIS, TARGET_ORBIT_AXIS).//NOT Sure the order of these.
    
}

GLOBAL function vectorToRelativeDN{//todo No idea if this works.
    parameter TARGET_ORBIT.

    local SHIP_ORBIT_AXIS is vectorToNormal(ship:ORBIT).
    local TARGET_ORBIT_AXIS is vectorToNormal(TARGET_ORBIT).

    return vectorCrossProduct(TARGET_ORBIT_AXIS, SHIP_ORBIT_AXIS).//NOT Sure the order of these.
    
}

GLOBAL function vectorToNormal{
    parameter orb.

    set radiusV to orb:POSITION.
    set tangentV to orb:VELOCITY:ORBIT.
    local resultVec is vectorCrossProduct(tangentV, radiusV).

    return resultVec:NORMALIZED.
}

GLOBAL function vectorToAN{
    parameter orb.
    local AN_X is COS(orb:LAN).
    local AN_Z is SIN(orb:LAN).

    local resultVec is v(AN_X, 0, AN_Z):normalized.
    return resultVec.

}

GLOBAL function vectorToPeriapsis{
    parameter orb.
    
    local peX is cos(orb:ARGUMENTOFPERIAPSIS).
    local peZ is sin(orb:ARGUMENTOFPERIAPSIS).

    local peY is -1 * sin(orb:INCLINATION). 

    local resultVec is v(peX,peY,peZ).

    return resultVec:NORMALIZED.
}

GLOBAL function trueAnomalyAtVector{
    parameter vec.
    parameter orb.

    local norm is vectorToNormal(orb).
    local checkAngle is vang(norm, vec).
    local alpha is 0.00001.
    local result is vang(vec, vectorToPeriapsis(orb)).

    if checkAngle > (90-alpha) AND checkAngle < (90+alpha){
        return result.
    }
}

GLOBAL function showOrbitVectors{
    //parameter relativeToShip.
    
    set loc to v(1,1,1).
    set loc2 to v(-1,-1,-1).

    set NOR_VEC to vectorToNormal(SHIP:ORBIT).
    set AN_VEC to vectorToAN(ship:ORBIT).
    set PE_VEC to vectorToPeriapsis(SHIP:ORBIT).


    SET x TO VECDRAW(

        loc2,
        v(1,0,0),
        RGB(1,0,0),
        "X",
        1.0,
        TRUE,
        0.2,
        TRUE,
        TRUE
        ).


    SET y TO VECDRAW(
        loc2,
        v(0,1,0),
        RGB(0,1,0),
        "Y",
        1.0,
        TRUE,
        0.2,
        TRUE,
        TRUE
        ).


    SET z TO VECDRAW(
        loc2,
        v(0,0,1),
        RGB(0,0,1),
        "Z",
        1.0,
        TRUE,
        0.2,
        TRUE,
        TRUE
        ).



    SET normalArrow TO VECDRAW(

        loc,
        NOR_VEC,
        RGB(1,0,0),
        "ORBIT_NORMAL",
        1.0,
        TRUE,
        0.2,
        TRUE,
        TRUE
        ).


    SET anARROW TO VECDRAW(
        loc,
        AN_VEC,
        RGB(0,1,0),
        "AN",
        1.0,
        TRUE,
        0.2,
        TRUE,
        TRUE
        ).


    SET peARROW TO VECDRAW(
        loc,
        PE_VEC,
        RGB(0,0,1),
        "Pe",
        1.0,
        TRUE,
        0.2,
        TRUE,
        TRUE
        ).
    }

