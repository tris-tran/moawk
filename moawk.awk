BEGIN {
    FS=SEP
    OFS=""
    SEC_I=0

    SECTION["top"]=-1
}

function c_getType() { return $1 }
function c_getSubtype() { return $2 }
function c_getOpt() { return $3 }
function c_getSection() { return $4 }
function c_getKey() { return $5 }

LINE != -1 { next }

$2 == C_END_SECTION {
    SEC=c_getKey()
    SEC_I-=1

    debug("moawk", "END DELETE SET TO: " DELETE_SEC)
    if (DELETE_SEC > 0) {
        DELETE_SEC-=1
        next
    }

    if (START_SEC) {
        name=secGet("name")
        iter=secGet("iter")
        val=secGet("val")
        start=secGet("start")
        debug("moawk", "END " SEC "ITER: " iter " val " val)
        if (iter+1 == val) {
            debug("moawk", "ITER " iter " out of " val)
            secPop()
            name=secGet("name")
            iter=secGet("iter")
            start=secGet("start")

            if (SECTION["top"] == -1) {
                START_SEC=false
            }
            next
        } else {
            iter+=1
            secSet("iter", iter)
            SEC_ITER=iter

            debug("moawk", "++++++++++++++++++++++++++++++++++++")

            reprocessFile(start)
            nextfile
        }
    }
    next
}

$2 == C_SECTION && DELETE_SEC { DELETE_SEC += 1 }
DELETE_SEC { next }

$1 == C_TEXT {
    if ( $2 == C_TXT_NWLN ) {
        print c_getKey()
    } else {
        printf("%s", c_getKey())
    }
    next
}

$2 == C_REPLACE {
    key=c_getKey()
    value=getValue(key)
    if (c_getOpt() == C_OPT_NO_ESCAPE) {
    } else {
        value=escapeHtml(value)
    }
    printf("%s", value)
    next
}

$2 == C_SECTION {
    SEC=c_getKey()

    value=getSection(SEC)
    type=getSectionType(SEC)

    if (value == SEC_DELETE) {
        #eliminamos seccion
        debug("moawk", "delete section " SEC)
        DELETE_SEC=1
        next
    } else if (type == "array") {
        #imprimimos seccion X veces
        debug("moawk", "array section " SEC " of " value)
        START_SEC=true
        SEC_I=secPush(SEC, value, FNR+1, "arr")
        SEC_ITER=1
        next
    } else {
        #objet
        debug("moawk", "object section " SEC)
        START_SEC=true
        SEC_I=secPush(SEC, 1, -1, "obj")
        SEC_ITER=1
        next
    }
}

function secGet(key) {
    top=SECTION["top"]
    return SECTION[top "." key]
}

function secSet(key, val) {
    top=SECTION["top"]
    SECTION[top "." key]=val
}

function secPush(name, val, start, type) {
    debug("moawk", "PUSH " name)
    top=SECTION["top"]
    top+=1
    SECTION["top"]=top

    debug("moawk", top)
    debug("moawk", "SECTION[" name "] " val)

    SECTION[top ".name"]=name
    SECTION[top ".val"]=val
    SECTION[top ".start"]=start
    SECTION[top ".iter"]=0
    SECTION[top ".type"]=type
    return top
}

function secGetKey(n) {
    top=SECTION["top"]
    key=""
    for(i=0; i<=top; i++) {
        name=SECTION[i ".name"]
        iter=SECTION[i ".iter"]
        type=SECTION[i ".type"]

        if (type == "obj") {
            n=0
            key=key name "."
        } else {
            if (n == 0) {
                key=key name "." iter "."
            } else {
                n-=1
            }
        }
    }

    return key
}

function secPop() {
    debug("moawk", "POP")
    SECTION["top"]-=1
}
