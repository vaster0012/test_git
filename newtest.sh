#!/bin/bash 

#colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета
DEF_SITE="./site.txt" # стандартный файл

printf "${GRN}Мониторинг сайтов${EC}\n"

monitor () {
    local SITE=${1:-$DEF_SITE}
        if [ -s "$SITE" ]
        then
            printf "${GRN}OK${EC}. Cheking list\n"
            if ping -c 1 -w 2 8.8.8.8 > /dev/null 2>&1; then 
                    printf "${GRN}CONNECTED${EC}\n" # change later
                    #cat ${SITE} | column -t -s "//" | awk '{print $2}' || echo "nofile"
                else
                    printf "${RED}NOT CONNECTED!${EC}\n" # change later    
                    exit 1
            fi
        else
            printf "File doesn't exist or is empty\n"
            printf "The $SITE has been created, but it is empty. Please fill it out\n"
            touch "${SITE}"
            exit 0
    fi

    while IFS= read -r LINK
    do
        [[ -z "$LINK" || "$LINK" == \#* ]] && continue
        CODE=$(curl -o /dev/null -s -m 3 -w "%{http_code}" "$LINK")
        if [ "$CODE" -ge 200 ] && [ "$CODE" -lt 400 ]
            then
                printf "${GRN}OK${EC} $LINK (HTTP $CODE)\n"
            else
                printf "${RED}FAIL${EC} $LINK (HTTP $CODE)\n"
        fi
    done < "$SITE"
}

while getopts "f:h" opt
do
    case "$opt" in
        f) U_SITE=$OPTARG
           touch ${U_SITE} 
           monitor "$U_SITE" ;;
        h) echo "add the key -f <NAME> to create or specify the file " ;;
        *) echo "Unsupported key. Running without flags" ;;
    esac
done

if [ $OPTIND -eq 1 ]
then
    printf "${YEL}No flags. Use default:${GRN}./site.txt ${EC}\n"
    monitor
fi