
GLOBAL function vectorToAngleDegrees{
    parameter vec. //TODO
}

GLOBAL function angleDegreesToVector{
    parameter ang.

    local x is cos(ang).
    local z is sin(ang).

    return v(x,0,z).

}

GLOBAL function visViva{
    parameter radius.
    parameter SMA.
    parameter parentBody.

    return sqrt(parentBody:MU * ((2 / radius) - (1 / SMA))).
}

GLOBAL function meanMotion{
    parameter _orbit.

    set SMA to _orbit:SEMIMAJORAXIS.
    set BODY_MU to _orbit:BODY:MU.

    return SQRT(BODY_MU/SMA^3) * CONSTANT:radtodeg.
}

GLOBAL function meanAnomaly{
    parameter _orbit.

    local deltaT is TIME:SECONDS - _orbit:EPOCH.
    local orbitsSinceEpoch is deltaT / _orbit:PERIOD.

    return mod((orbitsSinceEpoch * 360 + _orbit:MEANANOMALYATEPOCH), 360).
}

GLOBAL function trueAnomalyAtTime{
    parameter satellite.
    parameter t.

    local meanMotion to meanMotion(satellite:ORBIT).
    local deltaT to t - satellite:ORBIT:EPOCH.
    local meanAnomalyAtT to (deltaT * meanMotion) + satellite:ORBIT:MEANANOMALYATEPOCH.
    return meanAnomalyToTrueAnomaly(meanAnomalyAtT, satellite:ORBIT:ECCENTRICITY).

}
GLOBAL function longitudeOfPeriapsis{
    parameter _orbit.

    return _orbit:LAN + _orbit:ARGUMENTOFPERIAPSIS.

}

GLOBAL function trueLongitude{
    parameter TA.
    parameter _orbit.

    return mod(TA + longitudeOfPeriapsis(_orbit)).
    
}

//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function trueAnomalyToMeanAnomaly{
    parameter TRUE_ANOMALY.
    parameter ECCENTRICITY.

    local ECCENTRIC_ANOMALY is TrueAnomalyToEccentricAnomaly(TRUE_ANOMALY, ECCENTRICITY).

    local MEAN_ANOMALY is EccentricAnomalyToMeanAnomaly(ECCENTRIC_ANOMALY, ECCENTRICITY).

    return MEAN_ANOMALY.

}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function trueAnomalyToEccentricAnomaly{
    parameter _T.//true anomaly in degrees
    parameter _E.//eccentricity
    local result is arctan2(sin(_T)*sqrt(1-_E^2), cos(_t) + _E).//from Rastro
    // local result is arcTan2(sin(TRUE_ANOMALY)*SQRT(1-ECCENTRICITY^2), ECCENTRICITY + cos(TRUE_ANOMALY)).
    return result.

}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function eccentricAnomalyToMeanAnomaly{
    parameter ECCENTRIC_ANOMALY.//in degrees
    parameter ECCENTRICITY.
    local MEAN_ANOMALY is ECCENTRIC_ANOMALY - (ECCENTRICITY * sin(ECCENTRIC_ANOMALY)).
    if MEAN_ANOMALY < 0 set MEAN_ANOMALY to MEAN_ANOMALY + 360.
    return MEAN_ANOMALY.
}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function meanAnomalyToTrueAnomaly{
    parameter MEAN_ANOMALY.
    parameter ECCENTRICITY.

    local ECCENTRIC_ANOMALY is meanAnomalyToEccentricAnomaly(MEAN_ANOMALY, ECCENTRICITY).
    local TRUE_ANOMALY is eccentricAnomalyToTrueAnomaly(ECCENTRIC_ANOMALY, ECCENTRICITY).

    return TRUE_ANOMALY.

}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function meanAnomalyToEccentricAnomaly{
    parameter MEAN_ANOMALY.
    parameter ECCENTRICITY.

    set MEAN_ANOMALY_RADS TO MEAN_ANOMALY * CONSTANT:DEGTORAD.
    local Enew is MEAN_ANOMALY_RADS + ECCENTRICITY.
    if MEAN_ANOMALY_RADS > CONSTANT:pi{
        set Enew to MEAN_ANOMALY_RADS - ECCENTRICITY.
        }
    set Eold to Enew + 0.001.
    until abs(Enew - Eold) <= 1*10^8{
        set Eold to Enew.
        set Enew to Eold + (MEAN_ANOMALY_RADS - Eold + ECCENTRICITY * sin(Eold*constant:radtodeg))/(1 - ECCENTRICITY*cos(Eold*constant:radtodeg)).
    }
    return Enew * CONSTANT:radtodeg.
}
//THIS FUNCTION WAS TRANSCRIBED FROM https://github.com/lbaars/orbit-nerd-scripts. IT IS UNTESTED. TODO
GLOBAL function eccentricAnomalyToTrueAnomaly{
    parameter ECCENTRIC_ANOMALY.
    parameter ECCENTRICITY.

    local TRUE_ANOMALY is arcTan2(sin(ECCENTRIC_ANOMALY)*sqrt(1-ECCENTRICITY^2), 
                                            cos(ECCENTRIC_ANOMALY)-ECCENTRICITY).
    SET TRUE_ANOMALY TO mod(TRUE_ANOMALY + 360, 360).
    
    return TRUE_ANOMALY.
}

GLOBAL function timeUntilTrueAnomaly{//this will take a true anomaly and return the time until ship reaches this true anomaly next.
    parameter satellite.
    parameter TRUE_ANOMALY_DEG.

    local MEAN_ANOMALY_DEG is trueAnomalyToMeanAnomaly(TRUE_ANOMALY_DEG, satellite:orbit:eccentricity).
    local CURRENT_MEAN_ANOMALY is trueAnomalyToMeanAnomaly(satellite:orbit:trueanomaly, satellite:orbit:eccentricity).
    local MEAN_MOTION is meanMotion(satellite).

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

