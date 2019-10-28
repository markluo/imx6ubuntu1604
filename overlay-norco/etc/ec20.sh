#!/bin/bash
sleep 20
ifconfig -a | grep usb0
if [ "$?" -eq 0 ]
then
	quectel-CM -s ctnet &
sleep 20
#num=0
#while :
#do
#	if ping -c 1 114.114.114.114 >/dev/null 2>&1 ; then
#		num=0
#	else
#		let "num+=1"
#	fi
#	if [ "$num" = 3 ]
#    	then
#        	killall quectel-CM
#		sleep 1
#		echo 90 > /sys/class/gpio/export
#		echo out > /sys/class/gpio/gpio90/direction
#		echo 0 > /sys/class/gpio/gpio90/value
#		sleep 2
#		echo 1 > /sys/class/gpio/gpio90/value
#		echo 90 > /sys/class/gpio/unexport
#		sleep 20
#		quectel-CM -s ctnet &
#   	fi
#	sleep 10
#done
fi
