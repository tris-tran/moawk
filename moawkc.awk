#!/usr/bin/awk -f

BEGIN {
    FS="\n"
    OFS=""

    ESCAPE_TEST=")(}{><%\\"    
    if (match(ESCAPE_TEST, escapeRegex(ESCAPE_TEST))) {
    } else {
        print "CANNOT CONTINUE IMPOSSIBLE TO ESCAPE"
        exit 1
    }   

    redefineTags("{{", "}}")
    SEC_I=0
}

function redefineTags(openTag, closeTag) {
    OPEN_TAG=escapeRegex(openTag)
    CLOSE_TAG=escapeRegex(closeTag)

    KEY_VALID_CHARS="[a-zA-Z0-9._-]"

    OPEN_TAG_LEN=length(openTag)
    CLOSE_TAG_LEN=length(closeTag)

    DELIMITER=OPEN_TAG"=[^ =]+ [^ =]+="CLOSE_TAG

    ANY_TAG=OPEN_TAG".*"CLOSE_TAG
    ANY_NORMAL=OPEN_TAG"[!#\\\]? *"KEY_VALID_CHARS"+ *"CLOSE_TAG

    COMMENT=OPEN_TAG"! *.* *"CLOSE_TAG

    COMMENT_START=OPEN_TAG"! *.*"
    COMMENT_END=CLOSE_TAG

    NORMAL=OPEN_TAG"[^!#\\\{}] *"KEY_VALID_CHARS"+ *"CLOSE_TAG
    UNESCAPE_NORMAL=OPEN_TAG"{[^!#\\\{}] *"KEY_VALID_CHARS"+ *}"CLOSE_TAG
    BLOCK=OPEN_TAG"# *"KEY_VALID_CHARS"+ *"CLOSE_TAG
    END_BLOCK=OPEN_TAG"\\\ *"KEY_VALID_CHARS"+ *"CLOSE_TAG

    END_BLOCK=OPEN_TAG"\\\ *"KEY_VALID_CHARS"+ *"CLOSE_TAG
}

function escapeRegex(regex) {
    result=""
    split(regex, chars, "")
    for(i=1; i<=length(regex); i++) { 
        c=chars[i]
        if (c == "(") c="[\\\(]"
        else if (c == ")") c="[\\\)]"
        else if (c == "|") c="[\\\|]"
        #else if (c == "}") c="[\\\}]"
        
        result = result c
    }
    return result
}

function compile(type, subtype, opt, text) {
    sec=sectionKey()
    print type SEP subtype SEP opt SEP sec SEP text
}

function compiletext(text) {
    compile(C_TEXT, C_TXT_NWLN, C_OPT_EMPTY, text)
}

function checkLine() {
    if ($0 !~ ANY_TAG) { return true }
    return false
}

$0 !~ ANY_TAG && $0 !~ COMMENT_START && !insideComment { compiletext($0); next } 

match($0, COMMENT) && !insideComment {
    do {
        removeTag("")
        if (isEmpty($0)) { next }
        debug("moawkc", "Full commnet " $0)
        if (checkLine()) { compiletext($0); next }
    } while(match($0, COMMENT))
}

match($0, COMMENT_START) && !insideComment {
    insideComment=1
    $0=substr($0, 0, RSTART-1) 
    if (isEmpty($0)) { next }
    compile("text", "simple", C_OPT_EMPTY, $0)
}

insideComment && match($0, COMMENT_END) {
    $0=substr($0, RSTART+CLOSE_TAG_LEN, length($0))
    insideComment=0
    if (isEmpty($0)) { next }
}

$0 !~ ANY_TAG && !insideComment {
    compiletext($0)
    next
}

# If we are here it means that $0 have a tag and it is free of comments
!insideComment { 
    delimiter()
}

function delimiter() {
    if (match($0, DELIMITER)) {
        tag=getTag()
        key=substr(tag, OPEN_TAG_LEN+2, length(tag)-CLOSE_TAG_LEN-OPEN_TAG_LEN-2)
        split(key, separators, " ")

        delStart=RSTART
        delLength=RLENGTH

        if (RSTART != 0) {
            start=substr($0, 0, RSTART - 1)
            end=substr($0, RSTART, length($0))
            $0=start
            parseTags(C_TXT_SIMPLE)
            $0=end
        }

        redefineTags(separators[1], separators[2])
        $0=substr($0, delStart + delLength, length($0))
        delimiter()
    }
    if ($0 == "") return
    parseTags(C_TXT_SIMPLE)
}

function parseTags(textType) {
    while(match($0, ANY_NORMAL)) {
        options=C_OPT_EMPTY

        if (RSTART != 0) {
            text = substr($0, 0, RSTART - 1)
            compile(C_TEXT, C_TXT_SIMPLE, C_OPT_EMPTY, text)
        }

        tag=getTag()
        escape=true
        if (match(tag, ESCAPE_NORMAL)) { escape=false }
        key=substr(tag, OPEN_TAG_LEN+1, length(tag)-CLOSE_TAG_LEN-OPEN_TAG_LEN)
        key=removeSpaces(key)

        type=substr(key, 0, 1)
        
        start=2
        if (type == MO_SEC) {
            type=C_SECTION
            secVal=substr(key, start, length(key))
            SEC=secVal
            SECTION[SEC_I]=SEC
            SEC_I+=1
        } else if (type == MO_END_SEC) {
            type=C_END_SECTION
            secVal=substr(key, start, length(key))
            SEC=secVal
            SEC_I-=1
            CURR_SEC=SECTION[SEC_I]
            if (CURR_SEC != SEC) {
                print "ERROR"
                exit 1
            }
            SECTION[SEC_I]=""
        } else if (type == MO_TEMPLATE) {

        } else { 
            start=start - 1
            type = C_REPLACE
            if ( ! escape) {
                options = C_OPT_NO_ESCAPE
            }
        }

        value=substr(key, start, length(key))
        value=removeSpaces(value)

        compile(C_TAG, type, options, value)
        $0=substr($0, RSTART + RLENGTH, length($0))
    }
    compile(C_TEXT, C_TXT_NWLN, C_OPT_EMPTY, $0)
}

function sectionKey() {
    key=""
    for (i=0; i<SEC_I-1; i++) {
        key=key SECTION[i] "."
    }
    return key "" SECTION[SEC_I-1]
}

function removeTag(value) {
    $0=substr($0, 0, RSTART-1) value substr($0, RSTART + RLENGTH, length($0))
}

function getTag() { return substr($0, RSTART, RLENGTH) }


