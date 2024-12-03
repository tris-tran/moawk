#!/usr/bin/awk -f

BEGIN {
    FS="\n"
    OFS=""

    SEP="#moawk#"

    ESCAPE_TEST=")(}{><%\\"    
    if (match(ESCAPE_TEST, escapeRegex(ESCAPE_TEST))) {
    } else {
        print "CANNOT CONTINUE IMPOSSIBLE TO ESCAPE"
        exit 1
    }   

    redefineTags("{{", "}}")
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

function compile(type, subtype, text) {
    print type SEP subtype SEP text
}

function compiletext(text) {
    compile("text", "newline", text)
}

function checkLine() {
    if ($0 !~ ANY_TAG) { return 1 }
    return 0
}

$0 !~ ANY_TAG && $0 !~ COMMENT_START && !insideComment { compiletext($0); next } 

match($0, COMMENT) && !insideComment {
    do {
        removeTag("")
        if (checkLine()) { compiletext($0); next }
    } while(match($0, COMMENT))
}

match($0, COMMENT_START) && !insideComment {
    insideComment=1
    $0=substr($0, 0, RSTART-1) 
    compile("text", "simple", $0)
}

insideComment && match($0, COMMENT_END) {
    $0=substr($0, RSTART+CLOSE_TAG_LEN, length($0))
    insideComment=0
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
            parseTags("simple")
            $0=end
        }

        redefineTags(separators[1], separators[2])
        $0=substr($0, delStart + delLength, length($0))
        delimiter()
    }
    if ($0 == "") return
    parseTags("newline")
}

function parseTags(textType) {
    while(match($0, ANY_NORMAL)) {
        if (RSTART != 0) {
            text = substr($0, 0, RSTART - 1)
            compile("text", "simple", text)
        }

        tag=getTag()
        key=substr(tag, OPEN_TAG_LEN+1, length(tag)-CLOSE_TAG_LEN-OPEN_TAG_LEN)
        key=removeSpaces(key)

        type=substr(key, 0, 1)
        
        start=2
        if (type == "#") type = "section"
        else if (type == "\\") type = "section-end"
        else { 
            start=start - 1
            type = "replacer" 
        }

        value=substr(key, start, length(key))
        value=removeSpaces(value)

        compile("tag", type, value)
        $0=substr($0, RSTART + RLENGTH, length($0))
    }
    compile("text", textType, $0)
}

function removeTag(value) {
    $0=substr($0, 0, RSTART-1) value substr($0, RSTART + RLENGTH, length($0))
}

function getTag() { return substr($0, RSTART, RLENGTH) }

function removeSpaces(key) {
    gsub(/^[ \t]+|[ \t]+$/, "", key)
    return key
}

