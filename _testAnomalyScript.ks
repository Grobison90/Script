runOncePath("0:/ORBITS.ks").
CLEARSCREEN.
local function evaluate{
    set e to SHIP:ORBIT:ECCENTRICITY.
    set TA to ship:ORBIT:TRUEANOMALY.
    set EA_F to trueAnomalytoEccentricAnomaly(TA, e).
    set MA_F to eccentricAnomalyToMeanAnomaly(EA_F, e).

    set MA to meanAnomaly(SHIP:ORBIT).
    set EA_B to meanAnomalytoEccentricAnomaly(MA, e).
    set TA_B to eccentricAnomalyToTrueAnomaly(EA_B, e).

    set l to list(TIME:SECONDS, TA, TA_B, EA_F, EA_B, MA_F, MA).
    set returnMe to list().
    for item in l{
        returnMe:add(round(item, 10)).
    }
    return returnMe.
}

local function printRow{
    parameter row_list.
    parameter row_number.

    set col_width to 20.
    set col to 0.

    for s in row_list{
        print(s)at(col_width * col, row_number).
        set col to col+1.
    }
}

set row to 1.
set wait_time to 10.
set headers to list("t", "TA", "TA_B", "EA_F", "EA_B", "MA_F", "MA").
printRow(headers, 0).

until false{
    
    set samples to evaluate().
    printRow(samples, row).
    set row to row+1.
    wait wait_time.
}


