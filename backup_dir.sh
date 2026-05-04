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
                echo -e "Rewrite ARCHIVE: ${DIR}-$(date +%d.%m).tar.gz" | tee ./backup/tar.log
                echo -e "\e[0m Archive is rewrite!"
            else
                tar -czvf "./backup/$(date +%Y)/${DIR}-$(date +%d.%m).tar.gz" "${DIR}"
                echo -e "Create ARCHIVE: ${DIR}-$(date +%d.%m).tar.gz" | tee ./backup/tar.log
        fi  
    else
    echo "${DIR} - not found or is not a directory"  
fi



echo " directive: ${DIR} "






#case "$1" in
#    -d echo Direcory
#    echo $1 not a supported
#esac