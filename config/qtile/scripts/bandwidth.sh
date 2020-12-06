#!/bin/bash

# Use the provided interface, otherwise the device used for the default route.
if [[ -n $BLOCK_INSTANCE ]]; then
  INTERFACE=$BLOCK_INSTANCE
else
  INTERFACE=$(ip route | awk '/^default/ { print $5 ; exit }')
fi

# # if the connection is down, the corresponding block should not be displayed.
if ! [ -e "/sys/class/net/${INTERFACE}/operstate" ] || ! [ "`cat /sys/class/net/${INTERFACE}/operstate`" = "up" ]
then
    exit 0
fi

# path to store the old results in
path="/dev/shm/$(basename $0)-${INTERFACE}"

# grabbing data for each adapter.
read rx < "/sys/class/net/${INTERFACE}/statistics/rx_bytes"
read tx < "/sys/class/net/${INTERFACE}/statistics/tx_bytes"

# get time
time=$(date +%s)

# write current data if file does not exist. Do not exit, this will cause
# problems if this file is sourced instead of executed as another process.
if ! [[ -f "${path}" ]]; then
  echo "${time} ${rx} ${tx}" > "${path}"
  chmod 0666 "${path}"
fi

# read previous state and update data storage
read old < "${path}"
echo "${time} ${rx} ${tx}" > "${path}"

# parse old data and calc time passed
old=(${old//;/ })
time_diff=$(( $time - ${old[0]} ))

# sanity check: has a positive amount of time passed
[[ "${time_diff}" -gt 0 ]] || exit

# calc bytes transferred, and their rate in byte/s
rx_diff=$(( $rx - ${old[1]} ))
tx_diff=$(( $tx - ${old[2]} ))
rx_rate=$(( $rx_diff / $time_diff ))
tx_rate=$(( $tx_diff / $time_diff ))

# shift by 10 bytes to get KiB/s. If the value is larger than
# 1024^2 = 1048576, then display MiB/s instead

# outgoing
tx_kib=$(( $tx_rate >> 10 ))
if [[ "$tx_rate" -gt 1048576 ]]; then
    tx_mbs=$(printf '%s' "`echo "scale=1; $tx_kib / 1024" | bc`")
  echo -n "<span foreground='#ebdbb2'>${tx_mbs}</span><span font='12' foreground='#d5c4a1'>M</span><span foreground='#83a598'>↑</span><span font='3' foreground='#282A2E'>.</span>"
else
  echo -n "<span foreground='#ebdbb2'>${tx_kib}</span><span font='12' foreground='#d5c4a1'>K</span><span foreground='#83a598'>↑</span><span font='3' foreground='#282A2E'>.</span>"
fi

# incoming
rx_kib=$(( $rx_rate >> 10 ))
if [[ "$rx_rate" -gt 1048576 ]]; then
    rx_mbs=$( printf '%s' "`echo "scale=1; $rx_kib / 1024" | bc`")
  echo -n "<span foreground='#ebdbb2'>${rx_mbs}</span><span font='12' foreground='#d5c4a1'>M</span><span foreground='#83a598'>↓</span>"
else
  echo -n "<span foreground='#ebdbb2'>${rx_kib}</span><span font='12' foreground='#d5c4a1'>K</span><span foreground='#83a598'>↓</span>"
fi
