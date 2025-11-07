runoncepath("0:/launch.ks").

set _FLIGHT_STATUS to "Awaiting Go Command".
print("Go for launch? (y/n)").
local go is false.
until go{
    local input is terminal:input:getchar().
    if input = "y" {set go to true.}

}

doSuborbitalLaunch(90, 80000, 0.4).
