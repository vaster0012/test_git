#!/bin/bash

RED="\e[31m"
GRN="\e[32m"
EC="\e[0m"

echo -e "${RED}Тест скрипта проверки здоровья${EC}"

    echo -e "Дата отчета:\n"
    date

    echo -e "\n uptime: $(uptime | cut -d, -f1 | awk '{print $3}')"

aCPU="$(top -bn1 | grep "%Cpu" | awk '{print $2}')"
echo -e "\n Загрузка CPU"
echo $(top -bn1 | grep %Cpu | cut -d: -f2-)
if [ $(bc <<< "$aCPU > 40") -eq 1 ]
    then echo -e "${RED} ${aCPU} !CHECK PROCESS!${EC}"
    else echo -e "${GRN} ${aCPU} OK! ${EC}"
fi 