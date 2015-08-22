#!/bin/bash

dir=`dirname "${BASH_SOURCE-$0}"`
dir=`cd "$dir"; pwd`
bin=`basename "${BASH_SOURCE-$0}" .sh`
db="$dir/rrds/$bin.rrd"

if ! [ -f $db ]; then
    echo "create database $db"
    mkdir -p $(dirname $db)
    rrdtool create $db -s 2 \
            DS:rx:COUNTER:4:0:U \
            DS:tx:COUNTER:4:0:U \
            RRA:AVERAGE:0.5:1:7200 \
            RRA:AVERAGE:0.5:15:2880 \
            RRA:AVERAGE:0.5:60:5040
fi

COUNT=$((60 / 2))
for ((i=1; i <= COUNT; i++)); do

    rxtx=$(bash $dir/lib/get-rxtx-bytes.sh $@)

    echo "update_value = $rxtx"
    rrdtool updatev $db N:$rxtx

    if ((i != COUNT)); then sleep 2; fi
done
