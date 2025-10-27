
GLOBAL function sumEnginesMaxMassFlow{
    PARAMETER engineList.

    local massFlow is 0.
    //local engines is list().
    for e in engineList{
        set massFlow to massFlow + e:MAXMASSFLOW.
    }
    return massFlow.
}

GLOBAL function getStageTWR{
    parameter stageNum.
    return getStageThrust(stageNum) / ship:mass.
}

GLOBAL function getStageThrust{
    parameter stageNum.

    LIST ENGINES in englist.
    local totalThrust is 0.

    for e in englist{
        if e:STAGE = stageNum {
            set totalThrust to totalThrust + e:POSSIBLETHRUST.
        }
    }
    return totalThrust.

}

GLOBAL function getActiveEngines{
    LIST ENGINES in eng.
    local activeEngines is list().

    for e in eng{
        if e:ignition {
            activeEngines:add(e).
        }
    }
    return activeEngines.
}

GLOBAL function getAverageISP{
// This function takes a list of engines and returns the average Isp of them together (a weighted average of their Isp by Mass flow rate)
    parameter engines.
    local numerator is 0.
    local denominator is 0.

    for e in engines{
           set numerator to numerator + (e:ISP * e:MAXMASSFLOW).
           set denominator to denominator + (e:MAXMASSFLOW).

    }

return numerator / denominator.
}

GLOBAL function getRollRate{
    getdXdT({return SHIP:ANGULARVEL * v(0,0,1).}).
}

GLOBAL function getPartsNamed{
    parameter partName.

    set regex to ("(?i)" + "\w*" + partName + "\w*").
    set candidates to SHIP:ROOTPART:PARTSNAMEDPATTERN(regex).//a list of decouplers
    return candidates.

}

GLOBAL function getPartsTitled{
    parameter partName.

    set regex to ("(?i)" + "\w*" + partName + "\w*").
    set candidates to SHIP:ROOTPART:PARTSTITLEDPATTERN(regex).//a list of decouplers
    return candidates.

}

GLOBAL function findNearestPart{
    parameter partName.

    set regex to ("(?i)" + "\w*" + partName + "\w*").
    set candidates to SHIP:ROOTPART:PARTSTITLEDPATTERN(regex).//a list of decouplers

    set distances to list().
    for i in range(0,candidates:LENGTH){
        distances:ADD(distanceToRoot(candidates[i])).

    }
    return candidates[findMin(distances)].
    
}

GLOBAL function distanceToRoot{
    parameter part.

    set dist to 0.
    until not(part:HASPARENT){
        set part to part:PARENT.
        set dist to dist + 1.
    }

    return dist.
}

GLOBAL function getAcceleration{
    parameter deltaT.

    local t1 is time:SECONDS.
    local v1 is ship:velocity:SURFACE.
    wait deltaT.
    local t2 is time:SECONDS.
    local v2 is ship:velocity:SURFACE.

    return (v2 - v1):MAG/(t2-t1).
}

GLOBAL function getGravitationalAcceleration{
 return ship:body:mu / (ship:altitude + ship:body:radius)^2.
}