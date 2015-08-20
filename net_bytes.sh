#!/bin/bash

#IF='eth0'

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

function if_main {
    mif='lo'; mrx=0;
    for if in $(ls /sys/class/net); do
        rx=`cat /sys/class/net/$if/statistics/rx_bytes`
        if (($rx > $mrx)); then
            mif=$if; mrx=$rx;
        fi
    done
    echo $mif
}

IF=${IF:-$(if_main)}

COUNT=30
for ((i=1; i <= COUNT; i++)); do
    rx=`cat /sys/class/net/$IF/statistics/rx_bytes`
    tx=`cat /sys/class/net/$IF/statistics/tx_bytes`

    echo "update_value = $rx:$tx"
    rrdtool updatev $DB N:$rx:$tx

    if ((i != COUNT)); then sleep 2; fi
done
