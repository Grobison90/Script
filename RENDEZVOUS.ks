local closestApproach is false.
local distance is abs((t:POSITION - ship:POSITION):MAG).
until closestApproach {
    // print("Inside Loop").
    local newDistance to abs((t:position - ship:position):MAG).
    

    if newDistance > distance{
        set closestApproach to true.
        break.
    } else set distance to newDistance.

    PRINT("Distance: " + round(distance))at(0,0).
    wait 1.
}// make this method.
