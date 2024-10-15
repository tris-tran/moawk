
AWK=/bin/mawk

LOG_RED=$(tput setaf 1)
LOG_GREEN=$(tput setaf 2)
LOG_COLOR_RESET=$(tput sgr0)

SHOW_INFO=false

function _log.color() {
    local color=$1
    shift

    echo -n $color
    echo -e "$@"
    echo -n $LOG_COLOR_RESET
}
function log.red() {
    _log.color $LOG_RED $@
}

function log.green() {
    _log.color $LOG_GREEN $@
}

function run_moawk() {
    result=$(echo "$template" | $AWK --posix -f moawk.awk 2> /dev/null)
}

function assert_result() {
    local testName=$1

    run_moawk

    if [[ "$result" != "$expected" ]]; then
        log.red "FAIL[$testName] - $name: $desc"
        show_info
    else
        log.green "SUCCESS[$testName] - $name: $desc"
        [[ $SHOW_INFO == true ]] && show_info
    fi
}

function show_info() {
    echo "++++++ Template +++++++"       
    echo "$template"
    echo ""
    echo "++++++ Expected +++++++"       
    echo "$expected"
    echo ""
    echo "++++++ Result +++++++"       
    echo "$result"

}

declare -a TESTS
function @test() {
    local file=${BASH_SOURCE[1]}
    local annotationLine=${BASH_LINENO[0]}
    local line=$((annotationLine + 1))
    local annotated=$(
        $AWK -v "n=$line" '
        BEGIN { FS=" |\(\)" } 
        NR == n { 
            if ( $1 == "function" ) {
                print $2
                exit 0
            } else {
                exit 1
            }
        }
        ' "$file" || { 
            echo "Error annotation @test bad: $file:$annotationLine"
            exit 1
        }
    ) 

    TESTS+=($annotated)
}

function should_exist() {
    local defaultValue=$2

    if [ -z "${!1}" ]; then
        declare -g "$1=$defaultValue"
    fi
}

function validate_test() {
    should_exist name "$1"
    should_exist desc "No desc"
    should_exist template
    should_exist expected
}

function run_test() {(
    $1 
    validate_test $1
    assert_result "$1"
)}


source ./test/comments.sh
source ./test/simple.sh
source ./test/delimiters.sh

if [[ ! -z "$1" ]]; then
    SHOW_INFO=true
    run_test "$1"
else
    for test in "${TESTS[@]}"
    do
        run_test "$test"
    done
fi

