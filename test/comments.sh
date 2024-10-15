
@test
function comment1() {
    name="Simple"
    desc="Comment blocks should be removed from the template"

    template="{{! Comment }}"
    expected=""
}

@test
function comment4() {
    template="moawk{{! Comment with spaces }}"
    expected="moawk"
}

@test
function comment2() {
    template="m{{! comment in between }}oawk{{! Comment with spaces }}"
    expected="m"
}

@test
function comment3() {
    template=$(cat << END
moawk {{! Comment with spaces }}
{{! Another comment }}
ads
END
)

    expected=$(cat << END
moawk 

ads
END
)

}

@test
function comments.multiline() {
    template=$(cat << END
moawk {{! 
Comment with multiline
 comment end }} asd
{{! Another comment }}
ads
END
)

    expected=$(cat << END
moawk  asd

ads
END
)

}
