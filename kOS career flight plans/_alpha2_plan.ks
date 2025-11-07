runoncepath("0:/launch.ks").
runoncepath("0:/SCIENCE.ks").

setHeader(0, "Alpha 2 - Mission 2").
set thermos to ship:partsdubbedpattern(".*therm.*").
set baros to ship:partsdubbedpattern(".*baro.*").
runNextBarometer().

set _FLIGHT_STATUS to "Awaiting Go Command".
print("Go for launch? (y/n)").
local go is false.
until go{
    local input is terminal:input:getchar().
    if input = "y" {set go to true.}

}

when (ship:altitude>1000) then {runNextBarometer().}
when (ship:altitude>30000) then {runNextBarometer(). runNextThermometer().}
when (ship:altitude>70000) then {runNextBarometer(). runNextThermometer().}

doSuborbitalLaunch(0, 999999, 0.45).
