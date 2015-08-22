#!/bin/bash

# USAGE: get-rxtx.sh <if_name>

if ! [ -z $1 ] && [ -d "/sys/class/net/$1" ]; then
    rx=`cat /sys/class/net/$1/statistics/rx_bytes`
    tx=`cat /sys/class/net/$1/statistics/tx_bytes`
    echo "$rx:$tx"
    exit
fi

mflow=0;
mrx=0; mtx=0;
for if in $(ls /sys/class/net); do
    rx=`cat /sys/class/net/$if/statistics/rx_bytes`
    tx=`cat /sys/class/net/$if/statistics/tx_bytes`
    flow=$((rx/1000 + tx/1000))
    if (($mflow < $flow)); then
        mrx=$rx; mtx=$tx;
    fi
done

echo "$rx:$tx"
