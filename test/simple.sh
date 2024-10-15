
@test
function simple1() {
    name="Simple Interpolation"
    desc="Interpolate simple"

    NAME="tochoa"

    template="{{NAME}}"
    expected="tochoa"
}

@test
function simple.unicode() {
    name="Simple Interpolation"
    desc="Interpolate simple"

    NAME="áßðëäåé®þþü²²"

    template="ññ{{NAME}}"
    expected="ññáßðëäåé®þþü²²"
}

@test
function simple.interpolate_comment() {
    name="Simple Interpolation"
    desc="Interpolate simple"

    NAME="tochoa"

    template="{{! Comment {{NAME}} }}"
    expected=""
}
