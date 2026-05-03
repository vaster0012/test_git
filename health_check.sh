#!/bin/bash

{
    RED="\e[31m"
    GRN="\e[32m"
    YEL="\e[33m"
    EC="\e[0m"

    echo -e "${RED}Тест скрипта проверки здоровья${EC}"

    echo -e "Дата отчета:\n"
    date

    echo -e "\n uptime: $(uptime | cut -d, -f1 | awk '{print $3}')"

    #переменная вывода только числа загрузки CPU. Хз для чего, мб потом использую нормально.
    aCPU="$(top -bn1 | grep "%Cpu" | awk '{print $2}')"

    #выводит всю строку CPU из top 
    echo -e "\n ${YEL}Загрузка CPU${EC}"
    echo $(top -bn1 | grep %Cpu | cut -d: -f2-)

    #Простая проверка загрузки если больше 40% - красный. Меньше - зеленый ОК (балуюсь)
    if [ $(bc <<< "$aCPU > 40") -eq 1 ]
        then echo -e "${RED}${aCPU} !CHECK PROCESS!${EC}"
        else echo -e "${GRN}${aCPU} - OK! ${EC}"
    fi 

    echo -e "\n"
    echo -e "${YEL}Проверка памяти${EC}" 
    #Проверка памяти. Может потом можно будет улучшить
    free -h --mega

    echo -e "\n"
    echo -e "${YEL}Проверка дисков${EC}"
    # проверка диска. Только первая строка и vol.
    df -h | grep -iE "^filesystem|^/dev/"
    echo "__________________________"
} | tee -a ~/log_health.log

echo -e "${RED}Конец. Отправлен в журнал ~/log_health.l${EC}"