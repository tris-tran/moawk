
BEGIN {
    PATH="." 
    AWK="mawk"  
    COMMON_AWK="common.awk"
    AWK_AWK="awk.awk"

    MOAWKC="mowkc.awk"
    MOAWK="moawk.awk"
    
    CMD=AWK "-f" COMMON_AWK "-f" AWK_AWK
}

function moawkc() {
    return CMD "-f" MOAWKC 
}

function moawk() {
    return CMD "-f" MOAWK
}

function read() {
    
}

function run(input) {
    compiler=moawkc()
    templater=moawk()
    cmd="echo \"" input "\"| " compiler " | " templater
    system(cmd)
}
