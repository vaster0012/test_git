#!/bin/bash

    #colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета

printf "Мониторинг сайтов\n"

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
        printf "${GRN}OK${EC}. Cheking list\n" #change
        cat site.txt | column -t -s "//" | awk '{print $2}' || echo "nofile"
    else
        printf "File doesn't exist or is empty\n" #change
        printf "Create site.txt\n"
        printf "Please! Input site in site!))\n"
        touch ./site.txt #change
        exit 0
fi

while IFS= read -r LINK
do
    [[ -z "$LINK" || "$LINK" == \#* ]] && continue
    CLEAN_LINK=$(echo "$LINK" | sed 's|https\?://||' | sed 's|/.*||')
    if ping -c 1 -w 2 $CLEAN_LINK > /dev/null 2>&1
        then
            curl -o dev/null -sm 3 -w "%{http_code}" "$LINK"
            printf "     ${GRN}OK${EC} $LINK\n"
        else
            curl -o dev/null -sm 3 -w "%{http_code}" "$LINK"
            printf "     ${RED}FAIL${EC} $LINK\n"
    fi
done < "./site.txt"



#for LINK in $(cat ./site.txt)
#    do
#    $(ping -c 1 $LINK)
#done
