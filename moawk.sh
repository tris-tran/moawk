#!/bin/bash
#
#

AWK=/bin/mawk
AWK_OPTIONS=" --posix "
MOAWK="moawk.awk"
MOAWKC="moawkc.awk"

declare -g NAME="tochoa"
export NAME
declare -g PERSON="rosa"
export PERSON

TEMPLATE=$(cat << END
{{! Comment }}Linea con comentario
inicio {{! Comment }}Linea con comentario
inicio{{! Comment }}Linea con comentario

startend
START COMMENT
start{{! comentario
multilinea}}end
FIN COMMENT

INTERPOLATION
asd {{NAME}} asd
asd{{NAME}}asd
asd {{{NAME}}} asd
{{{NAME}}
asd {{NAME}} {{! esto es {{NAME}} un comentario}} second {{! esto es un comentario}}
no line

a{{=|| ||=}}{{=|| ||=}}
{{=|| ||=}}
||NAME|| |
||=||| |||=||
|||NAME||| |
|||=<% %>=|||{{NAME}}<%NAME%>
pepe<%NAME%> pepe <
<%=%% %%=%>
%%NAME%% %
%%={{ }}=%%
{{NAME}} {

{{#PERSON}} {{.}} {{\PERSON}}
END
)

echo "$TEMPLATE" > template-sample.mustache

echo $AWK "$AWK_OPTIONS" -f "$MOAWK"

echo "$TEMPLATE"
#echo "COMPILATION"
#echo "$TEMPLATE" | command $AWK $AWK_OPTIONS -f "./$MOAWKC"

echo "MUSTACHE"
echo "$TEMPLATE" | command $AWK $AWK_OPTIONS -f "./$MOAWKC" | command $AWK $AWK_OPTIONS -f "./$MOAWK"

