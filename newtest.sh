#!/bin/bash

#colors
RED="\e[31m"
GRN="\e[32m"
YEL="\e[33m"
EC="\e[0m"


printf "Мониторинг сайтов\n"


while getopts "a" opt
do
    case "$opt" in
        a) cat ./site.txt || printf "File deleted or is damage"
           exit 0 ;;
        *) echo "Non supported key. Run." ;;
    esac
done

if [ -s "./site.txt" ]
    then
        printf "OK. Cheking list" #change
    else
        printf "File doesn't exist or is empty\n" #change
        printf "Create site.txt\n"
        touch ./site.txt #change
fi

