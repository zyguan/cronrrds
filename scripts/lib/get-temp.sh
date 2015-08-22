#!/bin/bash

# USAGE: get-temp.sh <temp_src>

if ! [ -z $1 ] && [ -f $1 ]; then
    temp=$(cat $1)
fi

if [ -z $temp ] && [ -d '/sys/devices/platform/coretemp.0/' ]; then
    temps=$(cat /sys/devices/platform/coretemp.0/temp*_input)
    temp=0
    for t in $temps; do
        if (($temp < $t)); then
            temp=$t
        fi
    done
fi

if [ -z $temp ]; then
    temp_dirs=$(find /sys/class/thermal/ -name thermal_zone?)
    temp=0
    for dir in $temp_dirs; do
        t=$(cat $dir/temp)
        if (($temp < $t)); then
            temp=$t
        fi
    done
fi

echo "$((temp / 1000)).$((temp % 1000))"
