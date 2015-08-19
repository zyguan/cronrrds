#!/bin/bash

IF='eth0'

if [ -z $DB ]; then
    dir=`dirname "${BASH_SOURCE-$0}"`
    dir=`cd "$dir"; pwd`
    bin=`basename "${BASH_SOURCE-$0}" .sh`
    DB="$dir/$bin.rrd"
fi

if ! [ -f $DB ]; then
    echo "create database $DB"
    mkdir -p $(dirname $DB)
    rrdtool create $DB -s 2 \
            DS:rx:COUNTER:4:0:U \
            DS:tx:COUNTER:4:0:U \
            RRA:AVERAGE:0.5:1:7200 \
            RRA:AVERAGE:0.5:15:2880 \
            RRA:AVERAGE:0.5:60:5040
fi

rx=`cat /sys/class/net/$IF/statistics/rx_bytes`
tx=`cat /sys/class/net/$IF/statistics/tx_bytes`

echo "update_value = $rx:$tx"
rrdtool updatev $DB N:$rx:$tx
