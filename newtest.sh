#!/bin/bash

    #colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета


printf "Мониторинг сайтов\n"
LINK=$(cat site.txt | column -t -s "//" | awk '{print $2}') || echo "nofile"

while getopts "a" opt
do
    case "$opt" in
        a) cat ./site.txt || printf "File deleted or is damage\n"
           exit 0 ;;
        *) echo "Unsupported key. Running without flags" ;;
    esac
done

if [ -s "./site.txt" ]
    then
        printf "OK. Cheking list\n" #change
        echo $(LINK)
    else
        printf "File doesn't exist or is empty\n" #change
        printf "Create site.txt\n"
        printf "Please! Input site in site!))\n"
        touch ./site.txt #change
        exit 0
fi

for LINK in $(cat ./site.txt)
    do
    $(ping -c 1 $LINK)
done
