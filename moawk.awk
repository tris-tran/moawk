#!/usr/bin/awk -f

BEGIN {
    FS=SEP
    OFS=""
    SEC_I=0
}


$1 == C_TEXT && SEC_I < 1 {
    if ( $2 == C_TXT_NWLN ) {
        print $4
    } else {
        printf("%s", $4)
    }
}

$2 == C_REPLACE  && SEC_I < 1 {
    key=$4
    value=getValue(key)
    printf("%s", value)
}

$2 == C_SECTION {
    SEC=$4   
    SEC_I+=1
    if (SEC_I == 1) {
        next
    }
}

$2 == C_END_SECTION {
    SEC=$4
    SEC_I-=1

    if (SEC_I == 0) {
        print SECTION
        SECTION=""
        next
    }
}

SEC_I > 0 {
    SECTION=SECTION "\n" $0
}

function getValue(key) {
    return ENVIRON[key]
}
