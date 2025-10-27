//https://ntrs.nasa.gov/api/citations/19640018029/downloads/19640018029.pdf


GLOBAL function performPoweredLanding{
//this may eventually take arguments like:
// parameter coords. //= list(long, lat).
parameter in_Seconds.

//Boolean flags for monitoring status.
local alt_transition is 500.
local touchDown is false.
local landed is false.

print("Awaiting De-Orbit Burn").
wait in_seconds.

//We'll orient ourself retrograd.
lock steering to ship:srfretrograde.

//Do our initial Deorbit burn
lock throttle to 1.
wait until ship:periapsis < -5000.
lock throttle to 0.

set throt_tgt to 0.
set PID_speed to PIDLOOP(0.1, 0.1, 0.1, 0, 1, 0.01).
lock throttle to throt_tgt.

CLEARSCREEN.
print("Speed" + "              " + "Target").
until alt:radar < alt_transition{
    set PID_speed:setpoint to targetSpeed().
    set throt_tgt to 1 - PID_speed:UPDATE(time:seconds, ship:airspeed).
    print(round(ship:airspeed,1) + "              " + round(targetSpeed(),1))at(0,1).
}
CLEARSCREEN.
print("Transition to Final Approach").
lock throttle to 0.1.
wait until ship:groundspeed < 0.01.
set throt_tgt to 0.
lock throttle to throt_tgt.
lock steering to UP.
PID_speed:RESET.

until touchDown{
    set PID_speed:setpoint to targetSpeed() + 0.5.
    set throt_tgt to 1 - PID_speed:update(time:seconds, ship:airspeed).
    if ship:STATUS = "LANDED" { set touchDown to true. }
}
lock throttle to 0.

    local function targetSpeed{
        set slope to 0.02.
        return alt:radar * slope.
    }
}

GLOBAL function hover{
    parameter targetAlt.
    // SET MYPID TO PIDLOOP(Kp, Ki, Kd, min_output, max_output, epsilon).
    lock steering to UP.
    set desired_throttle to 0.
    lock throttle to desired_throttle.
    
    set PID to PIDLOOP(0.1, 0.001, 0.25, 0, 1, 0.001).
    set PID:setpoint to targetAlt.
    CLEARSCREEN.
    print("Alt   P    I    D    Sum  ") at(0,0).
    print(round(alt:radar,0) + " " + round(PID:PTERM,3) + " " + round(PID:ITERM, 3) + " " + round(PID:DTERM, 3) + " " + round(PID:OUTPUT,3)).
    until false{
        set desired_throttle to PID:UPDATE(time:seconds, alt:radar).
        print(round(alt:radar,1) + " " + round(PID:PTERM,1) + " " + round(PID:ITERM, 1) + " " + round(PID:DTERM, 1) + " " + round(PID:OUTPUT)) at(1,0).
    }
    

}
