#!/bin/bash

<<<<<<< HEAD
. ~/.ntfy.rc

for i in "$@"; do 
	curl -d "$i" ntfy.sh/$canal
=======
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
>>>>>>> cf8df2a9c14114335485347837f12f104ad0c472
done
