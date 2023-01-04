#!/bin/bash

conf=~/.ntfy.rc
# aquí está definida la variable canal

. $conf
urlbase=ntfy.sh

url=$urlbase/$canal

if [ "$1" = "-S"  ] || [ "$i" = "--silent" ]; then
	silencio=1; 
	shift 
else
	silencio=0
fi

for i in "$@"; do
	curl --silent --data "$i" $url \
	| (if [ $silencio -eq 0 ]; then  cat ; else  cat >/dev/null; fi)
done
