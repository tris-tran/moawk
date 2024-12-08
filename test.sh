
. ./moawk.sh

specFile="./pruebas/interpolation.json"
#specFile="./pruebas/comments.json"

overview=$(cat $specFile | jq -r '.overview')
testCount=$(cat $specFile | jq -r '.tests | length')

echo "$overview"
echo "$testCount"

function spec.get_test() {
    cat $specFile | jq -r '.tests['$1']'
}

function spec.get_field() {
    echo "$1"  | jq -r --arg name "$2" '.[$name]'
}

function test() {
    local testN=$1
    test=$(spec.get_test $testN)
    name=$(spec.get_field "$test" "name")
    desc=$(spec.get_field "$test" "desc")
    data=$(spec.get_field "$test" "data")
    template=$(spec.get_field "$test" "template")
    expected=$(spec.get_field "$test" "expected")

    local tmpC="./pruebas/test.tmp.moc"
    local tmpV="./pruebas/test.tmp.var"


   json.flatten "$data" > $tmpV
   compile "$template" > $tmpC

   local result=$(interpolate $tmpC $tmpV)

   if [[ "$result" != "$expected" ]]; then
       echo "Test $testN: $name"
       echo "$desc"
       cat $tmpV
       echo "$template"

       echo "FALLO"

       echo "VARIABLES"
       cat $tmpV
       echo "================="
       echo ""
       echo ""
       echo "TEMPLATE"
       echo "$template"
       echo "================="
       echo ""
       echo ""
       echo "COMPILE"
       cat $tmpC
       echo "================="
       echo ""
       echo ""
       echo "RESULT"
       echo "$result"
       echo "================="
       echo ""
       echo "EXPECTED"
       echo "$expected"
       echo "================="
       echo ""

       #vimdiff <(echo "$result") <(echo "$expected")
       exit 1
   else
       echo "OK - Test $testN: $name"
   fi

}

for (( i=0; i<testCount; i++ )); do
    test $i
done

function prueba() {
    json=$(cat "./pruebas/two.json")
    template=$(cat "./pruebas/one.mustache")

    json.flatten "$json" > ./pruebas/two || exit 1
    compile "$template" > "./pruebas/one.moc" || exit 1
    interpolate "./pruebas/one.moc" "./pruebas/two" || exit 1
}

