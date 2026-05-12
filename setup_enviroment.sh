#!/bin/bash
set -euo pipefail

#colors
RED=$'\e[31m'   # Красный цвет текста
GRN=$'\e[32m'   # Зелёный цвет текста
YEL=$'\e[33m'   # Жёлтый цвет текста
BLU=$'\e[34m'   # Голубой цвет текста
EC=$'\e[0m'    # Сброс цвета

# Оформление начала строк
ST="${YEL}ENV║ ⇓ ⇓ ║${EC}" # Обычный ход программы
EST="${RED}ENV║ ⇓ E ║${EC}" # Ошибка или предупреждение
HST="${BLU}ENV║ ⇓ H ║${EC}" # Информационнное сообщение
GST="${GRN}ENV║ O K ║${EC}" # Подтвержение

printf '%s\n' "${YEL}"
printf '%s\n' "╔═════════════════════════════════════════════════════╗"
printf '%s\n' "║       Setup bootstrap Vaster                        ║"
printf '%s\n' "║         Updating and installing customized packages ║"
printf '%s\n' "╚══╗ ⇓ ⇓ ╔════════════════════════════════════════════╝"
printf '%s' "${EC}"

#Проверка запуска от root
if [[ $EUID -eq 0 ]]; then
    printf '%s\n' "${ST} Is running as ${GRN}$(whoami)${EC}"
else
    printf '%s\n' "${EST} ${RED} Launched from a regular user. Use sudo ${EC}"
    exit 1
fi

if [[ -s ./packages.txt ]]
    then
        printf '%s\n' "${ST} ${YEL}packages.txt${EC} exists, overwriting..."
    else
        printf '%s\n' "${ST} ${YEL}packages.txt${EC} not found, downloading..."
fi
curl -s -L -o ./packages.txt "https://raw.githubusercontent.com/vaster0012/test_git/refs/heads/main/packages.txt"

info_bar () {
    local MESG=$1
    printf '%s' "${YEL}"   # Авто построение бара
            printf '%s\n' "ENV║ ⇓ ⇓ ╚════════════════════════════════╗ "
            printf '%s\n' "ENV║               $MESG  "
            printf '%s\n' "ENV║ ⇓ ⇓ ╔════════════════════════════════╝ " 
            printf '%s' "${EC}"  
}

cleanup() { # обработка trap
    local exit_code=$?
    rm -f allinst.tmp
    if [[ $exit_code -eq 0 ]]
        then
            printf '%s' "${YEL}"   # Все закончилось збс
            printf '%s\n' "ENV║ ⇓ ⇓ ╚════════════════════════════════╗ "
            printf '%s\n' "ENV║                                   OK ║ "
            printf '%s\n' "ENV╚══════════════════════════════════════╝ " 
            printf '%s' "${EC}"  
        else
            printf '%s' "${YEL}"   # Все закончилось плохо
            printf '%s\n' "ENV║ ⇓ ⇓ ╚════════════════════════════════╗ "
            printf '%s\n' "ENV║                                  BAD ║ "
            printf '%s\n' "ENV╚══════════════════════════════════════╝ " 
            printf '%s' "${EC}"  
    fi
}

help_page () {  #Страница помощи
    printf '%s\n' "${HST}     Скрипт позволяет установить окружение "
    printf '%s\n' "${HST}     В будущем бдует более гибким. Флаги: "
    printf '%s\n' "${HST}     -h --- Помощь "
    printf '%s\n' "${HST}     -a --- Вывести преднастроенный список и выделить уже установленные "
    printf '%s\n' "${HST}     -u --- Обновить только установленные "
    printf '%s\n' "${HST}     Просьба использовать только один флаг "
    printf '%s\n' "${HST}     Это все тесты, если вдруг кто-то это увидит, простите, что увидели! (С)Vaster "

}

printf '%s\n' "${ST} A temporary file has been created"
dpkg-query -W -f='${Package}\n' > allinst.tmp

check_all_installed () { # только провека установлено ли что-то из списка # в работе
    info_bar "CHECK INSTALLED APT"
    printf '%s\n' "${ST} reconciliation of installed packages"

    printf '%s\n' "${ST} Update..."
    printf '%s\n' "${ST}   ...Please wait"
    #apt-get update &>/dev/null

    while IFS= read -r number
    do
        if grep -qxF "$number" "./allinst.tmp"
        then 
            printf '%s\n' "${GST} $number installed!"
        else 
             printf '%s\n' "${EST}${RED} $number not install!${EC}"
        fi
    done < <(grep -v '^ *#' "./packages.txt")
}

installation () { # в работе. Установка требуемых пакетов
    printf '%s\n' "${ST} in work"
    

}
check_box () {
    export TERM=xterm
    export NEWT_COLORS='
    root=white,black
    window=white,black
    border=yellow,black
    button=yellow,yellow
    title=yellow,black'

    whiptail --topleft --title "Updating and installing customized packages" \
        --menu "SELECT NEXT STEP TO Setup bootstrap Vaster" 14 48 3 \
    "1" "FULL INSTALL" \
    "2" "ONLY PACKAGES" \
    "3" "HELP" 2> /tmp/ans
    case $(cat /tmp/ans) in
        1) info_bar "SELECTED FULL INSTALL" ;;
        2) info_bar "SELECTED ONLY PACKAGES" ;;
        3) info_bar "SELECTED HELP" 
            help_page;;
    esac
}
check_box
FLAG=""
while getopts "has" opt; do
    if [[ -n "$FLAG" ]]; then
        printf "${EST}Error: flag -%s conflicts with already used -%s\n" "$opt" "$FLAG"
        exit 1
    fi
    case "$opt" in
        h) FLAG="h" ;;
        a) FLAG="a" ;;
        s) FLAG="u" ;;
        *) printf '%s\n' "${EST}Unsupported key. Open help"
           help_page
           exit 1 ;;
    esac
done

case "$FLAG" in
    h) help_page ;;
    a) check_all_installed ;;
    s)  check_box
        printf '%s\n' "${EST}not ready ...." ;;
esac

shift $((OPTIND - 1))

trap cleanup EXIT