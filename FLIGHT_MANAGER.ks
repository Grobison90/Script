local _FLIGHT_STATUS is "Prelaunch".
local _OPERATION_STATUS is "Nominal".
GLOBAL _ERROR_QUEUE is queue().

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