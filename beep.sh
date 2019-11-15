#!/bin/bash
function main {
	local dirbase=/usr/share/sounds/gnome/default/alerts
	local sounds=( $(ls $dirbase) )
	local pos=0

	if [ "x$1" != "x" ]; then
		pos=$1
	fi

	play -q $dirbase/${sounds[$pos]} 
}
main
