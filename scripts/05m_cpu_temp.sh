#!/bin/bash

dir=`dirname "${BASH_SOURCE-$0}"`
dir=`cd "$dir"; pwd`
bin=`basename "${BASH_SOURCE-$0}" .sh`
db="$dir/rrds/$bin.rrd"

if ! [ -f $db ]; then
    echo "create database $db"
    mkdir -p $(dirname $db)
    rrdtool create $db -s 300 \
            DS:temp:GAUGE:600:0:U \
            RRA:AVERAGE:0.5:1:288 \
            RRA:AVERAGE:0.5:6:336 \
            RRA:AVERAGE:0.5:12:1440
fi

temp=$(bash $dir/lib/get-temp.sh $@)

echo "update_value = $temp"
rrdtool updatev $db N:$temp
