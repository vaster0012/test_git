#!/bin/bash 

#colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета
DEF_SITE="./site.txt" # стандартный файл
DEF_LINK="8.8.8.8"

printf "${GRN}Мониторинг сайтов${EC}\n"

monitor () {
    local SITE=${1:-$DEF_SITE}
        if [ -s "$SITE" ]
        then
            printf "${GRN}OK${EC}. Cheking list\n"
            if ping -c 1 -w 2 $DEF_LINK > /dev/null 2>&1; then 
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
    printf "\n=== $(date) ===\n" | tee -a "./smonitor.log"
    while IFS= read -r LINK
    do
        [[ -z "$LINK" || "$LINK" == \#* ]] && continue
        CODE=$(curl -o /dev/null -s -m 3 -w "%{http_code}" "$LINK")
        if [ "$CODE" -ge 200 ] && [ "$CODE" -lt 400 ]
            then
                printf "${GRN}OK${EC} $LINK (HTTP $CODE)\n" | tee -a "./smonitor.log"
            else
                printf "${RED}FAIL${EC} $LINK (HTTP $CODE)\n" | tee -a "./smonitor.log"
        fi
    done < "$SITE"
}

one_site () {
    local LINK=${1:-$DEF_LINK}
    printf "\n=== $(date) ===\n" | tee -a "./smonitor.log"
    printf "Test one site - $LINK"
    while IFS= read -r LINK
    do
        [[ -z "$LINK" || "$LINK" == \#* ]] && continue
        CODE=$(curl -o /dev/null -s -m 3 -w "%{http_code}" "$LINK")
        if [ "$CODE" -ge 200 ] && [ "$CODE" -lt 400 ]
            then
                printf "${GRN}OK${EC} $LINK (HTTP $CODE)\n" | tee -a "./smonitor.log"
            else
                printf "${RED}FAIL${EC} $LINK (HTTP $CODE)\n" | tee -a "./smonitor.log"
        fi
    done < "$SITE"


}

help_page () {
    #ОПИСАНИЕ И ПОМОЩЬ ПО ФЛАГАМ
    #ПО ЭТОМУ СКРИПТУ
    printf "\n Скрипт позволяет просто пингануть сайты "
    printf "\n Флаги: "
    printf "\n -h --- Помощь "
    printf "\n -f --- Задать свой файл дял проверки "
    printf "\n -s --- Задать только сайт для проверки П.с. Работает пока криво \n"
    printf "\n Просьба использовать только один флаг "
    printf "\n Это все тесты, если вдруг кто-то это увидит, простите, что увидели! \n"

}

while getopts "f:hs:" opt
do  
    if [ -n "$FLAG"  ] 
        then 
            echo -e "Error: ${YEL}KEY -$opt ${EC} conflicts with already used key -$FLAG"
            exit 1
    fi
    case "$opt" in        
        f)  FLAG=f
            U_SITE=$OPTARG
            touch ${U_SITE} 
            monitor "$U_SITE" ;;
        h)  FLAG=h
            help_page ;;
        s)  FLAG=s
            L_SITE=$OPTARG 
            one_site "L_SITE" ;;
        *)  echo "Unsupported key. Running without flags" ;;
    esac
done

if [ $OPTIND -eq 1 ]
then
    printf "${YEL}No flags. Use default:${GRN}./site.txt ${EC}\n"
    monitor
fi
