#!/bin/sh
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}'

http://sv11.onlinevideoconverter.com/download?file=i8j9c2g6j9i8g6c2
curl https://raw.githubusercontent.com/muhasturk/ukupgrade/master/ukupgrade > ukupgrade
chmod +x ./ukupgrade
./ukupgrade

