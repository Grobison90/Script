GLOBAL function getEnginesByStage{
    parameter stageNum.

    list engines in englist.
    set stageEngines to list().
    for e in englist{
        if e:stage= stageNum{
            stageEngines:add(e).
        }
    }
    return stageEngines.
}

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

GLOBAL function getPartsByStage{
    parameter stageNum.
    list parts in allParts.
    local stageParts is list().
    for p in allParts{
        if p:STAGE = stageNum {
            stageParts:add(p).
        }
    }
    return stageParts.
}

GLOBAL function partAndAllDescendants{
parameter part.
local partList is list(part).
if(part:children:length = 0){
	return partList.
		}
else {
	for c in part:children{
		set partList to joinLists(partList, partAndAllDescendants(c)).
	}
}
return partList.
}

GLOBAL function sumMass{
    parameter partList.
    local massSum is 0.
    for p in partList{
        set massSum to massSum + p:MASS.
    }
    return massSum.
}

GLOBAL function sumDryMass{
    parameter partList.
    local massSum is 0.
    for p in partList{
        set massSum to massSum + p:DRYMASS.
    }
    return massSum.
}

GLOBAL function sumWetMass{
    parameter partList.
    local massSum is 0.
    for p in partList{
        set massSum to massSum + p:WETMASS.
    }
    return massSum.
}

GLOBAL function getStageMass{
    parameter stageNum.

    local stagedMass is 0.
    local decoups is ship:partsdubbedpattern(".*decoup.*").
    for d in decoups{
        if(d:STAGE = stageNum){
        set stagedMass to sumMass(partAndAllDescendants(d)).
    }
    }
    return SHIP:MASS - stagedMass.

//     set stageParts to getPartsByStage(stageNum).
//     local totalMass is 0.
//     for p in stageParts{
//         set totalMass to totalMass + p:MASS.
//     }
//     return totalMass.
}

GLOBAL function getResourceByStage{
    parameter stageNum.
    parameter resourceName.

    set stageParts to getPartsByStage(stageNum).
    local totalAmount is 0.
    for p in stageParts{
        if p:HASRESOURCE(resourceName){
            set totalAmount to totalAmount + p:GETRESOURCE(resourceName):AMOUNT.
        }
    }
    return totalAmount.
}

GLOBAL function getStageBurnTime{
    parameter stageNum.
    list engines in englist.
    local totalMassFlow is sumEnginesMaxMassFlow(englist).
    declare stageParts is getPartsByStage(stageNum).
    declare wet is sumWetMass(stageParts).
    declare dry is sumDryMass(stageParts).
    return (wet-dry)*1000/totalMassFlow.
    
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

GLOBAL function sumMaxThrustByStage{
    parameter stageNum.

    list ENGINES in englist.
    local sumThrust is 0.
    for e in englist{
        if(e:STAGE = stageNum){
            set sumThrust to sumThrust + e:POSSIBLETHRUST.
        }
    }
    return sumThrust.
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

GLOBAL function findReentryDecoupler{
    list PARTS in candidates.
    local decouplers is list().
    for p in candidates{
        if (p:HASMODULE("ModuleDecouple")){
            decouplers:ADD(p).
            print(p).
        }
    if decouplers:LENGTH < 1 return "None".

    local prox is decouplers[0].
    local lowest_dist is distanceToRoot(d[0]).
    for d in decouplers{
        local dist is distanceToRoot(d).
        if dist < lowest_dist{
            set prox to d.
            set lowest_dist to dist.
        }

    }
    }
    return prox.
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