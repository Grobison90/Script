runoncepath("0:/launch.ks").

setHeader(0, "Alpha 3 - Mission 3").

set _FLIGHT_STATUS to "Awaiting Go Command".
print("Go for launch? (y/n)").
local go is false.
until go{
    local input is terminal:input:getchar().
    if input = "y" {set go to true.}

}
doSuborbitalLaunch(90, 70000, 0.7).
