runOncePath("0:/ORBITS.ks").

local function evaluate{
    set e to SHIP:ORBIT:ECCENTRICITY.
    set TA to ship:ORBIT:TRUEANOMALY.
    set EA_F to trueAnomalytoEccentricAnomaly(TA, e).
    set MA_F to eccentricAnomalyToMeanAnomaly(EA_F, e).

    set MA to meanAnomaly(SHIP:ORBIT).
    set EA_B to meanAnomalytoEccentricAnomaly(MA, e).
    set TA_B to eccentricAnomalyToTrueAnomaly(EA_B, e).

    return list(TIME:SECONDS, TA, EA_F, MA_F, "||", MA, EA_B, TA_B).
}

local function printRow{
    parameter row_list.
    parameter row_number.

    set col_width to 10.
    set col to 0.

    for s in samples{
        print(s)at(col_width * col, row_number).
        set col to col+1.
    }
}

set row to 0.
set wait_time to 10.
set headers to list("t", "TA", "EA_F", "MA_F", "||", "TA_B", "EA_B", "MA").
printRow(headers).

until false{
    
    set samples to evaluate().
    printRow(samples, row).
    set row to row+1.
    wait wait_time.
}


