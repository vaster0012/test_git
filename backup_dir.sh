#!/bin/bash


mkdir -p "./backup/$(date +%Y)"
touch ./backup/tar.log

while getopts "d:" opt
do
    case "$opt" in
        d) DIR="$OPTARG" ;;
        *) echo "Non supported key" ;;
    esac
done

if [ -d ${DIR} ]
    then 
        echo "${DIR} - found and is a directory"
        echo -e "${DIR}: start archive\e[32m"
        if [ -e "./backup/$(date +%Y)/${DIR}-$(date +%d.%m).tar.gz" ]
            then
                rm -rf "./backup/$(date +%Y)/${DIR}-$(date +%d.%m).tar.gz"
                tar -czvf "./backup/$(date +%Y)/${DIR}-$(date +%d.%m).tar.gz" "${DIR}"
                echo -e "Rewrite ARCHIVE: ${DIR}-$(date +%d.%m).tar.gz" | tee -a ./backup/tar$(date +%Y).log
                echo -e "Archive is rewrite! \e[0m"
            else
                tar -czvf "./backup/$(date +%Y)/${DIR}-$(date +%d.%m).tar.gz" "${DIR}"
                echo -e "Create ARCHIVE: ${DIR}-$(date +%d.%m).tar.gz" | tee -a ./backup/tar$(date +%Y).log
        fi  
    else
    echo "${DIR} - not found or is not a directory"  
fi
echo -e " directive \e[33m${DIR}\e[0m: end of archiving "