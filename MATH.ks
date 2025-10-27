
GLOBAL function getdXdT {
    parameter function_X.

    local t0 is TIME:seconds. 
    local x0 is function_x().
    set t0 to (t0 + TIME:seconds)/2.

    wait 0.01.

    local t1 is TIME:seconds.
    local x1 is function_x().
    set t1 to (t1 + TIME:seconds)/2.

    return (x1-x0)/(t1-t0).

}

GLOBAL function findMin{
    parameter l.

    local i to 0.//reference to the minimum value.
    for n in range(l:LENGTH){
        if l[n] < l[i] {
            set i to n.
        }
    }
    return i.
}

GLOBAL function getMin{
    parameter l.

    local i to 0.//reference to the minimum value.
    for n in range(l:LENGTH){
        if l[n] < l[i] {
            set i to n.
            set n to n + 1.
        }
    }
    return l[i].
}

GLOBAL function runFiles{
    parameter fileList.
    for file in fileList{
        RUNONCEPATH(file).
    }
}