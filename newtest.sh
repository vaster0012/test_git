#!/bin/bash
#./site.txt 
    #colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета
DEF_SITE="./site.txt" # стандартный файл

printf "${GRN}Мониторинг сайтов${EC}\n"

monitor () {
    local SITE=${1:-$DEF_SITE}
        if [ -s "SITE" ]
        then
            printf "${GRN}OK${EC}. Cheking list\n"
            cat site.txt | column -t -s "//" | awk '{print $2}' || echo "nofile"
        else
            printf "File doesn't exist or is empty\n"
            touch "${SITE}"
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
    done < SITE
}

while getopts "fh:" opt
do
    case "$opt" in
        f) U_SITE=$OPTARG
           touch ${U_SITE} 
           monitor "U_SITE"
        h) echo "add the key -f <NAME> to create or specify the file "
        *) echo "Unsupported key. Running without flags" ;;
    esac
done

if [ $OPTIND -eq 1 ]
then
    printf "${YEL}No flags. Use default:${GRN}./site.txt ${EC}\n"
    monitor
fi


