
rm -rf pipe pipe2
mkfifo pipe
mkfifo pipe2
echo "a" > pipe &
cat pipe | mawk -f ./test.awk  
#cat pipe2 | mawk -f ./test.awk  > pipe &
#
while true
do
    read -p "Enter fullname: " pepe
    echo pepe > pipe
done

