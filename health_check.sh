#!/bin/bash

RED="\e[31m"
GRN="\e[32m"
EC="\e[0m"

echo -e "${RED}Тест скрипта проверки здоровья"

    echo -e "Дата отчета:\n"
    date

    echo -e "\n uptime:\n"
    uptime
aCPU="$(top -bn1 | grep "%Cpu" | awk '{print $2}')"
echo -e "Загрузка CPU"
echo $(top -bn1 | grep %Cpu | cut -d: -f2-)
if [ $(bc <<< "$aCPU > 40") -eq 1 ]
    then echo OK
    else echo CHECK PROCESS!
fi 