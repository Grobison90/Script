runOncePath("0:/CONSOLE.ks").
runOncePath("0:/LAUNCH.ks").
RunOncePath("0:/ORBITS.ks").

{
//this file is to create a relatively generic display and methods for interacting with it. 
//
// +-------------------------------------------------------+
// | Header 1:                                             |
// | Header 2:                                             |
// | Header 3:                                             |
// +=======================================================+   
// | State:                                                |
// +-----------------+------------------+------------------+
// | table[0][0]     | table[0][0]      | table[0][0]      |
// | table[1][0]     | table[1][1]      | table[1][2]      |
// | table[...][...] | table[...][...]  | table[...][...]  |
// | table[n][0]     | table[n][1]      | table[n][2]      |
// +-----------------+------------------+------------------+
}
{
// CONFIGURE DEFAULT DISPLAY SETTINGS///////////////////////////////////////////////////////////////////
local h1 is list("Mission: ", {return "".}).
local h2 to list("Flight Status: ", getFlightStatus@).
local h3 to list("Operating Status: ",  getOperationStatus@).

GLOBAL _DEFAULT_HEADERS to list(h1, h2, h3).

GLOBAL _DEFAULT_TABLE_HEADERS is list("Param", "Current", "Target").

GLOBAL _DEFAULT_TABLE to list(
    _DEFAULT_TABLE_HEADERS,
    list("Apoapsis", getApoapsis@, blank_@),
    list("Periapsis", getPeriapsis@, blank_@),
    list("Velocity (SRF)", getVelocitySrf@, blank_@),
    list("Velocity (ORB)", getVelocityOrb@, blank_@)
    ).

//----------------------------------------------------------------------------------------------------------

GLOBAL _DEFAULT_LAUNCH_TABLE to list(
    _DEFAULT_TABLE_HEADERS,
    list("Apoapsis", getApoapsis@, {RETURN _TARGET_APOAPSIS.}),
    list("Periapsis", getPeriapsis@, {RETURN _LAUNCH_AZIMUTH.}),
    list("Velocity (SRF)", getVelocitySrf@, blank_@),
    list("Velocity (ORB)", getVelocityOrb@, {return round(visViva(kerbin:radius + _TARGET_APOAPSIS, kerbin:radius + _TARGET_APOAPSIS, kerbin)).}),
    list("Pitch", getPitch@, {return round(launchTargetPitch(ALT:RADAR)).}),
    list("AoA", getAoA@, {return "<" + _AoA_MAX.}),
    list("Q", getQ@, blank_@)
).



////////////////////////////////////////////////////////////////////////////////////////////////////////////
////DISPLAY GENERIC FUNCTIONS///////////////////////////////////////////////////////////////////////////////
local function blank_{
    return " - ".
}

local function getFlightStatus{
    return _FLIGHT_STATUS.
}

local function getOperationStatus{
    return _OPERATION_STATUS.
}

local function getApoapsis{
    return round(ship:orbit:apoapsis).
}

local function getPeriapsis{
    return round(ship:orbit:periapsis).
}

local function getVelocitySrf{
    return round(ship:VELOCITY:SURFACE:MAG).
}

local function getVelocityOrb{
    return round(ship:VELOCITY:ORBIT:MAG).
}

local function getPitch{
    return round(VANG(ship:FACING:FOREVECTOR, UP:VECTOR)).
}

local function getAoA{
    return round(VANG(ship:FACING:FOREVECTOR, SHIP:VELOCITY:SURFACE), 2).
}

local function getQ{
    return round(ship:dynamicPressure, 2).
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

local headers is list().
local table is list(list()).
local flightLog is list().

local nColumns is 1.
local nRows is 1.
local colWidth is 15.
local rowHeight is 1.

local hChar is "-". // horizontal character
local vChar is "|". // Vertical character
local iChar is "+". // Intersect character
local sMargin is 4. //side margins
local vMargin is 2. //vertical margins
local logLength is 10.

local maxHeaderLabelLength is 0.

GLOBAL function configureDisplay{
//Configure Display is the first method of the display library to call. It takes as input 2 mandatory parameters. The first is a list() of headers,
// the second is a list(list()) which comprises a table. The table is in table[row][column] format. The table is customizable, but usually the
// first row and column would be labels.
    parameter hdrs is _DEFAULT_HEADERS.
    parameter tbl is _DEFAULT_TABLE.

    set headers to hdrs.
    set table to tbl.
    set nColumns to table[0]:LENGTH.
    set nRows to table:LENGTH.

    set headerRow to vMargin.
    set tableRow to headerRow + 2 + headers:LENGTH * 2. // +2 is for a row divider and a blank line at top of headers.
    set logRow to tableRow + table:LENGTH + 1.

    set debug to true.
    
    if debug {// if debugging, run with a bigger kOS terminal, so that I can actually read ALL of the error messages.
        SET TERMINAL:WIDTH TO (100).
        SET TERMINAL:HEIGHT TO (75).
        //print "0    5    10   15   20   25   30   35   40   45   50   55   60   65   70   75   80   85   90   95" at(0,0).
        //print "|    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |" at(0,1).
    }.

    else{//otherwise run with the calculated size.
        SET TERMINAL:WIDTH TO ((nColumns * colWidth) + (nColumns * vChar:Length + 1) + (2 * sMargin)).
        SET TERMINAL:HEIGHT TO ((headers:LENGTH * 2 + 3) + (nRows * rowHeight) + (2 * vMargin) + logLength). 
    }

    // Layout the fixed display components:
    configureHeaders().
    configureTable().
    configureLog().

    updateDisplay().
}

GLOBAL function updateDisplay{
    updateHeaders().
    updateTable().
    updateLog().
    
    }

local function configureHeaders{//the configue methods print the STATIC portion of the Headers and Table (i.e. line dividers, labels etc.
    local count is 0.
    
    printRowSep(getLine()).
    printBlankLine(getLine()).
    for i in headers{
        local row is getLine().
        printBlankLine(row).
        print i[0] at(sMargin + 2, row).
        if i[0]:LENGTH > maxHeaderLabelLength { set maxHeaderLabelLength to i[0]:LENGTH. }
        printBlankLine(getLine()).
        
    }
    printRowSep(getLine()).

    local function getLine{
        local l is count + headerRow.
        set count to count + 1.
        return l.
    }
}

local function configureTable{//the configue methods print the STATIC portion of the Headers and Table (i.e. line dividers, labels etc.)
    local count is 0.

    printRowSep(getLine()).
    local i is 0.
    until i >= table:LENGTH {
        printEmptyTableRow(getLine()). 
        set i to i+1.}

    printRowSep(getLine()).

    for col in range(0, table[0]:LENGTH) { printCell(0,col). }//print Column Labels.
    for row in range(1, table:LENGTH) { printCell(row,0). }    //Print Row Labels.
    

    local function getLine{
        local l is count + tableRow.
        set count to count + 1.
        return l.

    }
}

local function configureLog{
    local count is 0.
    printRowSep(getLine()).
    print "Log:" at(sMargin + 2, getLine()).

    local function getLine{
        local l is count + logRow.
        set count to count + 1.
        return l.

    }
}

local function printEmptyTableRow{
    parameter row.

    local string1 is vChar:padright(colWidth + vChar:LENGTH).
    local line is repeatString(string1, nColumns) + vChar.
    print line at(sMargin, row).

}

local function printCell{
    parameter row, col.
    local text is " " + table[row][col]().

    local x is col * (colWidth + 1) + sMargin + 1.
    local y is row + tableRow + 1.
    print text:padright(colWidth) at(x,y).
}

GLOBAL function setColumns{
    parameter cols.
    set nColumns to cols.
}

GLOBAL function setRows{
    parameter rows.
    set nRows to rows.
}

function getRowSep{
    parameter width is (nColumns * colWidth) + (nColumns * vChar:LENGTH) - 1.

    local line is "+":padright(width + hChar:length).
    set line to line:replace(" ", hChar).
    set line to line + iChar.
    set line to line:padleft(line:length + sMargin).
    
    return line.  
}

function printRowSep{
    parameter row.
    parameter width is (nColumns * colWidth) + (nColumns * vChar:LENGTH) - vChar:LENGTH.

    local line is "+":padright(width + hChar:length).
    set line to line:replace(" ", hChar).
    set line to line + iChar.
    set line to line:padleft(line:length).
    
    print line at(sMargin, row).
}

function printBlankLine{
    parameter row.
    parameter width is (nColumns * colWidth) + (nColumns * vChar:LENGTH) - vChar:LENGTH.

    local line is vChar:padright(width + vChar:length) + vChar.
    set line to line:padleft(line:length).
    print line at(sMargin, row).
    
    }

function updateHeaders{

    for i in range(0, headers:LENGTH){
        local wtSpace is 3.
        local x is sMargin + maxHeaderLabelLength + wtSpace.
        local y is (vMargin + 2) + (i * 2).
        print headers[i][1]():padright((nColumns * colWidth) + (nColumns * vChar:LENGTH) - (vChar:LENGTH + maxHeaderLabelLength + wtSpace)) at(x , y).
        
    }

}

function updateTable{
    for row in range(1, table:LENGTH){
        for col in range(1, table[row]:LENGTH){
            printCell(row, col).
        }
    }

}

function updateLog{
    //TODO, make this better.
    if(flightLog:LENGTH >= 1){
    print flightLog[flightLog:LENGTH - 1][0] at(sMargin + 2, logRow + 1 + flightLog:LENGTH).
    print "t+" + round(flightLog[flightLog:LENGTH - 1][1], 2) at(getRight() - 10, logRow + 1 + flightLog:LENGTH).
    }.
}

function logEntry{//Use this method to add an entry into the log. It will be timestamped, and then printed with the updateLog() function.
    parameter text.
    local entry is list(text, MISSIONTIME).
    flightLog:add(entry).
    updateLog().
}

function getCenter{
    local ctr is ((nColumns * colWidth) + (ncolumns * vChar:LENGTH) + vChar:LENGTH ) / 2.
    return sMargin + ctr.
}

function getRight{
    return sMargin + nColumns + nColumns*colWidth + sMargin -1.//fix this
}

function printCentered{
    parameter text.
    parameter row.
    print text at(getCenter() - text:LENGTH /2, row).

}


