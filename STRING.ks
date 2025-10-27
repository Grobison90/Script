GLOBAL function repeatString{
    parameter s.
    parameter n.

    if n = 1 { return s. }
    else { return s + repeatString(s, (n-1)). }

}