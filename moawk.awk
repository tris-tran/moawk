#!/usr/bin/awk -f

BEGIN {
    FS="#moawk#"
    OFS=""

}


$1 == "text" {
    if ( $2 == "newline" ) {
        print $3
    } else {
        printf("%s", $3)
    }
}

$2 == "replacer"  {
    key=$3
    value=getValue(key)
    printf("%s", value)
}


function getValue(key) {
    return ENVIRON[key]
}
