#!/bin/bash
set -euo pipefail

#colors
RED=$'\e[31m'   # Красный цвет текста
GRN=$'\e[32m'   # Зелёный цвет текста
YEL=$'\e[33m'   # Жёлтый цвет текста
EC=$'\e[0m'    # Сброс цвета

# Оформление начала строк
ST="${YEL}ENV║   ║${EC}" # Обычный ход программы
EST="${RED}ENV║ E |${EC}" # Ошибка или предупреждение

#Проверка запуска от root
if [[ $EUID -eq 0 ]]; then
    printf '%s\n' "${ST} ${GRN}$(whoami)${EC} is running as root"
else
    printf '%s\n' "${EST} ${RED} Launched from a regular user. Use sudo ${EC}"
    exit 1
fi

printf '%s\n' "${YEL}╔═════════════════════════════════════════════════════╗"
printf '%s\n' "║             Setup bootstrap Vaster                  ║"
printf '%s\n' "║   Updating and installing customized packages       ║"
printf '%s\n' "╚══╗   ╔══════════════════════════════════════════════╝${EC}"

printf '%s\n' "${ST} A temporary file has been created"
dpkg-query -W -f='${Package}\n' > allinst.tmp

if [[ -s ./packages.txt ]]
    then
        printf '%s\n' "${ST} ${YEL}packages.txt${EC} exists, overwriting..."
    else
        printf '%s\n' "${ST} ${YEL}packages.txt${EC} not found, downloading..."
fi

curl -s -L -o ./packages.txt "https://raw.githubusercontent.com/vaster0012/test_git/refs/heads/main/packages.txt"

check_all_installed () {
    printf '%s\n' "${ST} reconciliation of installed packages"
    


}

help_page () {
    printf '%s\n' "${ST}  Скрипт позволяет установить окружение "
    printf '%s\n' "${ST}  В будущем бдует более гибким. Флаги: "
    printf '%s\n' "${ST}  -h --- Помощь "
    printf '%s\n' "${ST}  -a --- Вывести преднастроенный список и выделить уже установленные "
    printf '%s\n' "${ST}  -u --- Обновить только установленные "
    printf '%s\n' "${EST}  Просьба использовать только один флаг "
    printf '%s\n' "${ST}  Это все тесты, если вдруг кто-то это увидит, простите, что увидели! (С)Vaster "

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
        *) printf '%s\n' "${EST}Unsupported key. Open help"
           help_page
           rm -f allinst.tmp
           exit 1 ;;
    esac
done

case "$FLAG" in
    h) help_page ;;
    a) check_all_installed ;;
    u) printf '%s\n' "${EST}not ready ...." ;;
esac

shift $((OPTIND - 1))

trap 'rm -f allinst.tmp' ERR
rm -f allinst.tmp

printf "\n"