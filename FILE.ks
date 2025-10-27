
GLOBAL function runFiles{
    parameter fileList.
    for file in fileList{
        RUNONCEPATH(file).
    }
}
