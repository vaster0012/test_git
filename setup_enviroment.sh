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

log () {
    echo "[$(date '+%m.%d.%Y %H:%M:%S')] $1" >> enviroment.log
}
log "Start script!" 

title_bar () {
    local MESG=$1
    printf '%s' "${YEL}"   # Авто построение бара
            printf '%s\n' "ENV║ ⇓ ⇓ ╚════════════════════════════════╗ "
            printf '%s\n' "ENV║          $MESG  "
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
            log "End OK!"
            log "       "
        else
            printf '%s' "${YEL}"   # Все закончилось плохо
            printf '%s\n' "ENV║ ⇓ ⇓ ╚════════════════════════════════╗ "
            printf '%s\n' "ENV║                                  BAD ║ "
            printf '%s\n' "ENV╚══════════════════════════════════════╝ " 
            printf '%s' "${EC}"  
            log "End ERROR!"
            log "       "
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
    log "Open help"
}

printf '%s\n' "${ST} A temporary file has been created"
dpkg-query -W -f='${Package}\n' > allinst.tmp

check_all_installed () { # только провека установлено ли что-то из списка # в работе
    title_bar "CHECK INSTALLED APT"
    printf '%s\n' "${ST} reconciliation of installed packages"

    printf '%s\n' "${ST} Update..."
    printf '%s\n' "${ST}   ...Please wait"
    #apt-get update &>/dev/null

    OV_COUNT=0
    NO_INST_COUNT=0
    while IFS= read -r number
    do
        if grep -qxF "$number" "./allinst.tmp"
        then 
            OV_COUNT=$((OV_COUNT + 1))
            printf '%s\n' "${GST} $number installed!"
        else 
            NO_INST_COUNT=$((NO_INST_COUNT + 1))
             printf '%s\n' "${EST}${RED} $number not install!${EC}"
        fi
    done < <(grep -v '^ *#' "./packages.txt")
    printf '%s' "${ST} $((OV_COUNT + NO_INST_COUNT)) total PACK | "
    printf '%s' "${GRN} $OV_COUNT ${EC} Already installed | "
    printf '%s\n' "${RED} $NO_INST_COUNT ${EC} of them are not installed"
    log "TOTAL $((OV_COUNT + NO_INST_COUNT)). INSTALL $OV_COUNT. NOT INTALL $NO_INST_COUNT."
}   

installation () { # в работе. Установка требуемых пакетов
    title_bar "FULL INSTALL"
     printf '%s\n' "${ST}➤   The full installation of packages begins: "
     printf '%s\n' "${ST}"
     printf '%s\n' "${ST}➤   List ./packages.txt "
     printf '%s\n' "${ST}➤   ZSH shell and its settings "
     printf '%s\n' "${ST}➤   GIT repository (IN WORK) "

    while IFS= read -r PACKAGE
    do
        if grep -qxF "$PACKAGE" "./allinst.tmp"
        then 
            printf '%s\n' "${GST} $PACKAGE installed!"
        else 
            sudo DEBIAN_FRONTEND=noninteractive apt install -y "$PACKAGE"\
                        -o Dpkg::Options::="--force-confdef" \
                        -o Dpkg::Options::="--force-confold" \
                        пакет > /dev/null 2>&1
            title_bar "INSTALL $PACKAGE"
            log "INST $PACKAGE"
            printf '%s\n' "${ST} Installing ${YEL}$PACKAGE${EC}"
            printf '%s\n' "${ST} Please wait!"

        fi
    done < <(grep -v '^ *#' "./packages.txt")
}

install_zsh() { 
    sh -c "$(curl -sSL https://github.com/vaster0012/first-config-zsh/raw/refs/heads/main/stab/stableinst.sh)"
    }

git_env_intallation () {
    printf '%s\n' "${ST} IN PROGRES...."
    mkdir projet && cd projet
    git config -- global user.name "vaster0012"
    git config -- global user.email "vaster0012@gmail.com"
    git clone git@github.com:vaster0012/test_git.git
    git fetch origin
    git pull origin main
    cd ~
}

check_box_title () {
    export TERM=xterm
    export NEWT_COLORS='
    root=white,black
    window=white,black
    border=yellow,black
    button=yellow,yellow
    title=yellow,black'

    whiptail --topleft --title "Updating and installing customized packages" \
        --menu "SELECT NEXT STEP TO Setup bootstrap Vaster" 14 48 4 \
    "1" "FULL INSTALL" \
    "2" "ONLY PACKAGES" \
    "3" "MORE OPTION" \
    "4" "EXIT" 2> /tmp/ans
    case $(cat /tmp/ans) in
        1) title_bar "SELECTED FULL INSTALL"
            installation
            git_env_intallation 
            install_zsh   ;;
        2) title_bar "SELECTED ONLY PACKAGES" ;;
        3) title_bar "MORE OPTION" 
            check_box_more;;
        4) exit 1 ;;
    esac
}
check_box_more () {
 whiptail --topleft --title "Updating and installing customized packages" \
        --menu "More option" 14 48 4 \
    "1" "CHECK INSTALLED APT" \
    "2" "INSTALL ONLY ZSH" \
    "3" "INSTALL ONLY GIT" \
    "4" "BACK" 2> /tmp/ans
    case $(cat /tmp/ans) in
        1) check_all_installed ;;
        2) title_bar "INSTALL ONLY ZSH"
            install_zsh ;;
        3) git_env_intallation ;;      
        4) check_box_title ;;
    esac
}

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
    a) check_all_installed 
        exit 1;;
    s)  check_box_title
        printf '%s\n' "${EST}not ready ...." ;;
esac

shift $((OPTIND - 1))
check_box_title
log "EXIT WHITOUT TRAP"
trap cleanup EXIT