@lazyGlobal OFF.

GLOBAL _THERMOMETERS is ship:partsdubbedpattern(".*thermom.*").
local _thermometer_idx is 0.
GLOBAL _BAROMETERS is ship:partsdubbedpattern(".*Barome.*").
local _barometer_idx is 0.
GLOBAL _GOO is ship:partsdubbedpattern(".*mystery.*").
local _goo_idx is 0.

GLOBAL function runNextThermometer{
    if(_thermometer_idx < _THERMOMETERS:LENGTH){
        collectThermometerData(_THERMOMETERS[_thermometer_idx]).
        SET _thermometer_idx to _thermometer_idx + 1.
    }
}

GLOBAL function runNextBarometer{
    if(_barometer_idx < _BAROMETERS:LENGTH){
        collectBarometerData(_BAROMETERS[_barometer_idx]).
        SET _barometer_idx to _barometer_idx + 1.
    }
}

GLOBAL function runNextGoo{
    if(_goo_idx < _GOO:LENGTH){
        collectGooData(_GOO[_goo_idx]).
        SET _goo_idx to _goo_idx + 1.
    }
}

GLOBAL function collectThermometerData{
    parameter t.
    t:getmodule("ModuleScienceExperiment"):DOEVENT("Log Temperature").
}

GLOBAL function collectBarometerData{
    parameter b.
    b:getModule("ModuleScienceExperiment"):DOEVENT("Log Pressure Data").
}

GLOBAL function collectGooData{
    parameter g.
    g:getModule("ModuleScienceExperiment"):DOEVENT("Observe Mystery Goo").
}