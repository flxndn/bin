#!/bin/bash

function ayuda {
	nombre=md5infile.sh;
	echo "* $nombre
	* Uso
		> $nombre -h|--help
		> $nombre [-s|q] fichero_de_md5s fichero1
	* Descripción
		Devuelve 0 si el md5sum de fichero1 se encuentra en fichero_de_md5s y un 1 en caso contrario.
	* Opciones
		- -s :: Muestra el fichero con el que coincide el md5sum.
		- -q :: No muestra el fichero sólo devuelve o o 1. :: Es la opción por defecto.
"

}

if [ "x$1" = "x-h" ] || [ "x$1" = "x-help" ]; then
	ayuda
	exit 0
fi

opcion="no_mostrar";

if [ "x$1" = "x-s" ]; then
	opcion="mostrar";
	shift;
fi

if [ "x$1" = "x-q" ]; then
	opcion="no_mostrar";
	shift;
fi

if [ "$#" -ne 2 ]; then
	echo "Error. Tiene que haber 2 argumentos." >&2
	ayuda >&2
	exit 2;
fi

md5cache="$1"
file="$2"
md5sum="$(cat "$file" | md5sum|cut -f1 -d' ')"

if [ $opcion = 'no_mostrar' ]; then
	grep -q "^$md5sum " "$md5cache"
	exit $?
fi

if [ $opcion = 'mostrar' ]; then
	grep "^$md5sum " "$md5cache" | sed "s/[^ ]* *//"
	exit $?
fi
