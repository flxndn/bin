#!/bin/bash
set -eo pipefail

if [ "x$1" = "x-h" ]; then
	cat <<HELP
* epoch2date.sh
	* Uso 
		> epoch2date.sh [opciones] <segundos>
		> epoch2date.sh -h 
	* Descripción
		Saca por salida estándar la fecha que corresponde a los segundos desde el 
		[[https://en.wikipedia.org/wiki/Epoch_(computing) Epoch]].
	* Opciones
		-h :: Saca esta ayuda.
		-i :: Fecha en formato ISO.
HELP
	exit 0
fi

formato='%c'

if [ "x$1" = "x-i" ]; then
	formato='"%Y-%m-%d %H:%M:%S"'
	shift
fi

if [ "x$1" = "x" ]; then
	while read line; do
		date +"$formato" -d "@$line"
	done
else
	while [ "x$1" != 'x' ]; do
		date +"$formato" -d "@$1"
		shift
	done
fi

