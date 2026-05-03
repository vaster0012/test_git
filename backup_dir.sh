#!/bin/bash

#перебор чисел, пока не остановится на определенном. while do done

min_num=1
max_num=9
step=1

while [ "$min_num" -lt "$max_num" ]
    do
        echo "$min_num"
        min_num=$(( min_num + step ))
done

for num in $(seq 1 1 9)
    do
        echo "$num"
done