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
    parameter colWidth is 25.

    set row_n to 0.
    set col_n to 0.
    for row in table{
        for col in row{
            print(col)at(col_n*colWidth, row_n).
            set col_n to col_n + 1.
        }
        set col_n to 0.
        set row_n to row_n + 1.
    }

}

GLOBAL function joinLists{
    parameter listA.
    parameter listB.

    for item in listB{
        listA:ADD(item).
    }
    return listA.
}