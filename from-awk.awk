# Gets variables set like:
#
# # Normal interpolations
# name = name
#
# # Array sections
# sec = 3
# sec.1.name = name1
# sec.1.surname = surname1
#
# sec.1.insidesec = 1
# sec.1.insidesec.1.person = person
# ...
#
# sec.2.name = name2
# sec.2.surname = surname2
# ...
# sec.3.name = tochoa
# sec.3.surname = surnametoachoa
# ...
#
# # Object sections
# object = one, two
# object.one = 1
# object.two = 2
#
# # Empty sections
# seca = false
# secb = null
# secc = ""
# secd = 
#
BEGIN {
    FS=""
    LOADING=1
}

FNR == 1 && LOADING { 
    if ( ! length(FLOAD)) {
        FLOAD=FILENAME
    }
    if (FLOAD != FILENAME) {
        LOADING=0;
    }
}

LOADING {
    if ( $0 ~ /^#/ || $0 == "") {
        next
    }
    
    equals=index($0, "=")
    if (equals) {
        key=substr($0, 0, equals-1)
        val=substr($0, length(key)+2, length($0))

        key=removeSpaces(key)
        val=removeSpaces(val)

        if (val == "\"\"") val=""

        VAL[key]=val
    } 
}

function getValue(key) {
    for(j=0;;j++) {
        env=secGetKey(j)
        debug("from-awk.getValue", "query(" j ") env(" env ") key(" key ")")
        if (j > 0 && env == prevEnv) {
            return
        }
        if (env == -1) {
            return ""
        }

        if (key == ".") {
            env=substr(env, 0, length(env) -1)
            val=VAL[env]
        } else {
            qkey=env key
            val=VAL[qkey]
            debug("from-awk.getValue", "key{" qkey "} val{" val "}")
        }

        if (val != "") {
            return val
        }
        prevEnv=env
    }
}


function getSectionType(key) {
    debug("from-awk", "KEY {" key "}")
    return getValue(key ".type")
}

function getSection(key) {
    debug("from-awk", "KEY {" key "}")
    sec=getValue(key)


    debug("from-awk", "KEY {" key "} SEC {" sec "}")

    if (sec == "") {
        return SEC_DELETE
    } else if (sec == "null") {
        return SEC_DELETE
    } else  if (sec == "false") {
        return SEC_DELETE
    }  else if ( sec+0 || sec ~ /^0/) {
        #array
        return sec
    } else {
        #objet
        return sec
    }
}
 
