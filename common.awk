BEGIN {
    SEP="#moawk#"


    C_ERROR="error"
    C_TEXT="text"
    C_TXT_NWLN="newline"
    C_TXT_SIMPLE="simple"
    C_TAG="tag"
    C_REPLACE="replacer"
    C_SECTION="section"
    C_END_SECTION="section-end"
    C_TEMPLATE="template"

    C_OUT_ERROR=C_ERROR SEP

    C_OPT_EMPTY="no-opt"
    C_OPT_NO_ESCAPE="no-escape"

    MO_SEC="#"
    MO_END_SEC="\\"
    MO_TEMPLATE=">"
    true=1
    false=0
    LINE=-1

    SEC_DELETE="delete"
}


function removeSpaces(key) {
    gsub(/^[ \t]+|[ \t]+$/, "", key)
    return key
}

LINE > 0 && FNR < LINE { next }
FNR == LINE { LINE=-1 }

function reprocessFile(line) { ARGC+=1; ARGV[ARGC-1]=FILENAME; LINE=line; }

function escapeHtml(text) {
    gsub(/&/, "\\&amp;", text);
    gsub(/\\"/, "\\&quot;", text)
    gsub(/</, "\\&lt;", text);
    gsub(/>/, "\\&gt;", text);
    return text
}

function printArgs() {
    debug("common", "Printing argc y argv")
    print ARGC
    for (i=0; i<ARGC; i++) {
        debug("common", "ARGV[" i "]" ARGV[i])
    }
    debug("common", "END Printing argc y argv")
}

# Tells me if the line is empty
function isEmpty(line) {
    line=removeSpaces(line)
    debug("common", "|" line "|")
    if (line ~ /^[ \t\r\n]*$/) { return true }
    return false
}

function debug(file, msg) {
    #print ":: LOG [" file "]: " msg
}

function error() {
    exit 1
}
