#!/bin/bash

atsha204_client -d 2 -a 0x38  &

/etc/ec20.sh 1>/dev/null 2>&1 &

cat /etc/version | grep -q "gui"
if [ $? -eq 0 ]; then
	/etc/xset.sh 1>/dev/null 2>&1 &
fi
