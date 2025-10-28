//The FLIGHT_MANAGER will be scripts related to managing problems with a mission from one level above, say "launch" or "landing." 
// It will call those delegated subroutines and if they return errors, or suboptimal results, FLIGHT_MANAGER will deal with them. For now
// much of it will probably be un-implemented. It will also be in charge of managing user interfaces like "DISPLAY"

runOncePath("0:/DISPLAY.ks").

local _FLIGHT_STATUS is "Prelaunch".
local _OPERATION_STATUS is "Nominal".
local _DISPLAY is false.
GLOBAL _ERROR_QUEUE is queue().

GLOBAL function manageFlight{
    parameter flightPlan.
    parameter display.

    for phase in flightPlan{
        local errors is phase:call().
        _ERROR_QUEUE:push(errors).
        //Manage these errors somehow.
    }
}

global function setFlightStatus{
    parameter fs.
    set _FLIGHT_STATUS to fs.
}

function setOperationStatus{
    parameter os.
    set _OPERATION_STATUS to os.
}

function getFlightStatus {
    return _FLIGHT_STATUS.
}

function getOperationStatus {
    return _OPERATION_STATUS.
}

GLOBAL function notify{
    parameter message.
    if _DISPLAY{
        logEntry(message).
    }
    else hudtext(message, 3, 1, 48, yellow, true).
}