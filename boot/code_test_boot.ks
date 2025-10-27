//Terminal Management
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
wait 1.

print "Booting.".
wait 1.

CLEARSCREEN.
runOncePath("0:/CODE_TEST.ks").
print "Code Test Complete.".