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
    if (subtype) {
        print "#moawk#|" type "|" subtype "|" text
    } else {
        print "#moawk#|" type "|" text
    }
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
    delimiter($0)
}

function delimiter(line) {
    if (match(line, DELIMITER)) {
        if (RSTART != 0) {
            start = substr(line, 0, RSTART - 1)
            parseTags(start)
        }

        tag=substr(line, RSTART, RLENGTH)
        key=substr(tag, OPEN_TAG_LEN+2, length(tag)-CLOSE_TAG_LEN-OPEN_TAG_LEN-2)
        split(key, separators, " ")

        print "text" line
        print DELIMITER
        print RSTART " " RLENGTH
        print "TAG" tag
        print "SEP" separators[1] separators[2]

        exit

        redefineTags(separators[1], separators[2])

        text=substr(line, RSTART + RLENGTH, length($0))
        delimiter(line)
    }
    parseTags(text)
}

function parseTags(text) {
    while(match($0, ANY_NORMAL)) {
        if (RSTART != 0) {
            text = substr($0, 0, RSTART - 1)
            compiletext(text)
        }

        tag=getTag()
        compile("tag", "unknown", tag)
        $0=substr($0, RSTART + RLENGTH, length($0))
    }
    compiletext($0)
}

function removeTag(value) {
    $0=substr($0, 0, RSTART-1) value substr($0, RSTART + RLENGTH, length($0))
}

function getTag() { return substr($0, RSTART, RLENGTH) }



