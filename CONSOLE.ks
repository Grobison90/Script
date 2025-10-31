GLOBAL function notify{
    parameter message.
    if _DISPLAY{
        logEntry(message).
    }
    else hudtext(message, 3, 2, 32, yellow, true).
}

GLOBAL function repeatString{
    parameter s.
    parameter n.

    if n = 1 { return s. }
    else { return s + repeatString(s, (n-1)). }

}


GLOBAL FUNCTION printTable{
    parameter table.

    set row_n to 0.
    set col_n to 0.
    for row in table{
        for col in row{
            print(table[row][col])at(col_n*_colWidth, row_n).
            set col_n to col_n + 1.
        }
        set col_n to col_n + 1.
    }

}