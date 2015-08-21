#!/bin/bash

TEMP_SRC='/sys/devices/platform/coretemp.0/temp1_input'

if [ -z $DB ]; then
    dir=`dirname "${BASH_SOURCE-$0}"`
    dir=`cd "$dir"; pwd`
    bin=`basename "${BASH_SOURCE-$0}" .sh`
    DB="$dir/$bin.rrd"
fi

if ! [ -f $DB ]; then
    echo "create database $DB"
    mkdir -p $(dirname $DB)
    rrdtool create $DB -s 300 \
            DS:temp:GAUGE:600:0:U \
            RRA:AVERAGE:0.5:1:288 \
            RRA:AVERAGE:0.5:6:336 \
            RRA:AVERAGE:0.5:12:1440
fi

if ! [ -f $TEMP_SRC ]; then
    TEMP_SRC="/sys/class/thermal/thermal_zone0/temp"
fi

temp=`cat $TEMP_SRC`
temp=$((temp / 1000)).$((temp % 1000))

echo "update_value = $temp"
rrdtool updatev $DB N:$temp
