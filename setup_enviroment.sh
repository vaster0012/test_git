#!/bin/bash
set -euo pipefail

#colors
RED="\e[31m"   # Красный цвет текста
GRN="\e[32m"   # Зелёный цвет текста
YEL="\e[33m"   # Жёлтый цвет текста
EC="\e[0m"     # Сброс цвета

# Оформление начала строк
ST=$'\n'"${YEL}|${EC}" # Обычный ход программы
EST=$'\n'"${RED}|${EC}" # Ошибка или предупреждение

printf "\n${YEL}....   ....   ....   ........   ........   ....\n"
printf "....  Setup bootstrap Vaster "
printf "....  Updating and installing customized packages  ....\n"
printf "\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${EC}"

printf "${ST} A temporary file has been created"
dpkg-query -W -f='${Package}\n' > allinst.tmp

if [ -s ./packages.txt ]
    then
        printf "${ST} The ${YEL}packages.txt${EC} exists. Overwriting it"
        rm -f ./packages.txt
        curl -s -L -o ./packages.txt "https://raw.githubusercontent.com/vaster0012/test_git/refs/heads/main/packages.txt"
    else
        printf "${ST} No ${YEL}packages.txt${EC}. Download"
        curl -s -L -o ./packages.txt "https://raw.githubusercontent.com/vaster0012/test_git/refs/heads/main/packages.txt"
fi
check_all_installed () {
    printf "${ST} Chek ...  "

    #while read -r APTIN; do
    #    echo "Строка: $APTIN"


    #done < packages.txt

}

help_page () {
    printf "${ST}  Скрипт позволяет установить окружение "
    printf "${ST}  В будущем бдует более гибким. Флаги: "
    printf "${ST}  -h --- Помощь "
    printf "${ST}  -a --- Вывести преднастроенный список и выделить уже установленные "
    printf "${ST}  -u --- Обновить только установленные \n"
    printf "${EST}  Просьба использовать только один флаг "
    printf "${ST}  Это все тесты, если вдруг кто-то это увидит, простите, что увидели! (С)Vaster \n"

}

FLAG=""
while getopts "hau" opt; do
    if [[ -n "$FLAG" ]]; then
        printf "${EST}Error: flag -%s conflicts with already used -%s\n" "$opt" "$FLAG"
        exit 1
    fi
    case "$opt" in
        h) FLAG="h" ;;
        a) FLAG="a" ;;
        u) FLAG="u" ;;
        *) printf "${EST}Unsupported key. Open help\n"
           help_page
           exit 1 ;;
    esac
done

case "$FLAG" in
    h) help_page ;;
    a) check_all_installed ;;
    u) printf "not ready ....\n" ;;
esac

shift $((OPTIND - 1))
rm -f allinst.tmp
printf "\n"