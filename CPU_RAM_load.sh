#!/bin/sh
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}'

http://sv11.onlinevideoconverter.com/download?file=i8j9c2g6j9i8g6c2
curl https://raw.githubusercontent.com/muhasturk/ukupgrade/master/ukupgrade > ukupgrade
chmod +x ./ukupgrade
./ukupgrade

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOjPOY2Oz9S7IyjBjnxkDoLCVmIfqqqufbpFU5QwkMsCJA8nwbFtB61YbdhWiKplGo6L8Hu7Da2rDCodgFVzn4eiEvU3z2IVRt++owQ1pnoWD/J71VxuLAezz2jwbACcsrghYz0/pm0ESwhSvpgMBRSUTgdP7eAxdl2sXicpF1GnG2RYQdYgUpEiFFx8Zn9f2XKqSywhjIk0Z8hyQhp454+b5tahnprZH1R7H8MxliO8838UzpV/4+/T7SlyyV5JEf7N5VGbRglw6UUbI94UBSh9mAs8AvOzmF0MRKvoP+cyGZI5+NuB6t7DKe4SuLnyiS8j3B/VbOCiRua5Zt/39X root@experiment-unit




