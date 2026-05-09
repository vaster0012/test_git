#!/bin/bash
set -euo pipefail

#colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета
DEF_SITE="./site.txt" # стандартный файл
ST="\n${YEL}|${EC}"
EST="\n${RED}|${EC}"

printf "\n${YEL}....   ....   ....   ........   ........   ....\n"
printf "....  Setup bootstrap Vaster "
printf "....  Updating and installing customized packages  ....\n"
printf "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${EC}"

check_all_installed () {
    printf "\n Chek ...  "

}

help_page () {
    #ОПИСАНИЕ И ПОМОЩЬ ПО ФЛАГАМ
    #ПО ЭТОМУ СКРИПТУ
    printf "${ST}  Скрипт позволяет установить окружение "
    printf "${ST}  В будущем бдует более гибким. Флаги: "
    printf "${ST}  -h --- Помощь "
    printf "${ST}  -a --- Вывести преднастроенный список и выделить уже установленные "
    printf "${ST}  -u --- Обновить только установленные \n"
    printf "${ST}  Просьба использовать только один флаг "
    printf "${ST}  Это все тесты, если вдруг кто-то это увидит, простите, что увидели! (С)Vaster \n"

}

while getopts "hau" opt
FLAG=""
do  
    if [ -n "$FLAG"  ] 
        then 
            echo -e "${EST}Error: ${YEL}KEY -$opt ${EC} conflicts with already used key -$FLAG"
            exit 1
    fi
    case "$opt" in        
        h)  FLAG=h ;;
        a)  FLAG=a ;;
        u)  FLAG=u ;;
        *)  printf "${EST} Unsupported key. Open help"
            help_page
            exit 1 ;;
    esac
done

if [ $OPTIND -eq 1 ]
then
    printf "${EST} Entered without flags."
    printf "${ST} Output and configuration of required packages in packages.txt${ST}"
    if [ -s "./packages.txt" ]
        then
            printf "${ST}${GRN}the file is found and filled in\n"
        else
            printf "${EST}${RED}the file was not found or not filled in\n"
    fi
fi