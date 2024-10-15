
@test
function delimiters.crazy_changes() {
    name="Simple delimiters test"
    desc="Try all combinations of delimiter changes"

    NAME="delimiter"

    template=$(cat << END
{{=|| ||=}} {{=|| ||=}} ||NAME||
||=||| |||=|| ||=||| |||=|| |||NAME|||
|||=<% %>=||| |||=<% %>=||| <%NAME%>
<%=%% %%=%> <%=%% %%=%> %%NAME%%
%%={{ }}=%% %%={{ }}=%% {{NAME}}
{{NAME}}
END
)

    expected=$(cat << END
 {{=|| ||=}} delimiter
 ||=||| |||=|| delimiter
 |||=<% %>=||| delimiter
 <%=%% %%=%> delimiter
 %%={{ }}=%% delimiter
delimiter
END
)
}
