//the MISSION file will run and instantiate all the global variables and methods. Mostly so we don't have to do it in every boot file. instead we can just run this script.

GLOBAL _FLIGHT_STATUS is "Prelaunch".
GLOBAL _OPERATION_STATUS is "Nominal".
GLOBAL _DISPLAY is true.
GLOBAL _ERROR_QUEUE is queue().

until _MISSION_COMPLETE{
    updateDisplay().
}

GLOBAL function notify{
    parameter message.
    if _DISPLAY{
        logEntry(message).
    }
    else hudtext(message, 3, 2, 32, yellow, true).
}