#!/bin/bash
#
#

AWK=/bin/mawk
AWK_OPTIONS=" --posix "
COMMONAWK="common.awk"
FROMAWK="from-awk.awk"
MOAWK="moawk.awk"
MOAWKC="moawkc.awk"


function json.flatten() {
    local json=$1

    echo "$json" | jq  '. as $in | reduce paths(type == "array") as $path ({}; . + { ($path | map(tostring) | join(".")):  $in | getpath($path) | length,  ($path | map(tostring) | join(".") + ".type"):  "array" })' \
    | jq 'to_entries|map("\(.key) = \(.value|tostring)")|.[]' \
    | awk '{ print substr($0, 2, length($0) -2)}'

    echo "$json" |  jq '. as $in | reduce paths(type == "object") as $path ({}; . + { ($path | map(tostring) | join(".")):  "object" })' \
    | jq 'to_entries|map("\(.key) = \(.value|tostring)")|.[]' \
    | awk '{ print substr($0, 2, length($0) -2)}'

    echo "$json" \
    | jq  '. as $in | reduce paths(type != "object" and type != "array") as $path ({}; . + { ($path | map(tostring) | join(".")): $in | getpath($path)     })' \
    | jq 'to_entries|map("\(.key) = \(.value|tostring)")|.[]' \
    | awk '{ print substr($0, 2, length($0) -2)}'
}

function compileFile() {
    local template=$1
    $AWK -f $COMMONAWK -f $MOAWKC $template 
}

function compile() {
    local template=$1
    echo "$template" | $AWK -f $COMMONAWK -f $MOAWKC 
}

function interpolate() {
    local compile=$1
    local varfile=$2
    $AWK -f $COMMONAWK -f $FROMAWK -f $MOAWK $varfile $compile
}

function prueba() {
    json=$(cat "./pruebas/two.json")
    template=$(cat "./pruebas/one.mustache")

    json.flatten "$json" > ./pruebas/two || exit 1
    compile "$template" > "./pruebas/one.moc" || exit 1
    interpolate "./pruebas/one.moc" "./pruebas/two" || exit 1
}

