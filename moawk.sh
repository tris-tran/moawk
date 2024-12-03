#!/bin/bash
#
#

AWK=/bin/mawk
AWK_OPTIONS=" --posix "
MOAWK="moawkc.awk"

NAME="tochoa"
PERSON="rosa"

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

{{=|| ||=}}{{=|| ||=}}
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
echo "$TEMPLATE" | command $AWK $AWK_OPTIONS -f "./$MOAWK"
