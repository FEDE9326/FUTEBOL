#!/bin/sh
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}'

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6HqVxoe+553qJIz8L2NcWD7u68ux6FOOurry++5l6PIQNUQ1MKJLwQOtM5N5q9Y1Erx/y8e5x/tN7XRgIHUzsr3SEsv3sDkiv+uKjFO0tmcuOs//vZXKOuzdZosdgiy7C21N61rCRfmddUO8+YjxmRsW4due35S0MJaZCB2s6+JNwYFYZMWm76Y3uWR5gIvsVD+7Yalj8jP/ETiZHg3pgMSBSmoZFJbAFmZ2B8rfqXXvcnLCa1d883K0XaqZLfHNjiAMxvEfLyZ5XzH38+aQLV2XaTwL6Y+u/z77D06UIiiaCHvpL5ys2u24z8jx6E0qozrDBBzbGznVsYl3VVOYf root@docker






