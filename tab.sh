#!/bin/bash

readonly BASEDIR=$HOME/.gtd
readonly GTD_DEFAULT_FILE=$BASEDIR/organize.gtd
readonly HTML_FILE=$BASEDIR/out/pendiente.html

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre

	* Uso
		> $nombre [-n tabs] [archivo]
		> $nombre -h

	* Descripción
		Saca por salida estándar la entrada estándar (o el archivo) añadiendo 
		uno o más tabuladores al inicio de cada línea.

	* Opciones
		* -n tabs
			tabs es el número de tabuladores que se añaden al principio de cada línea.

			Por defecto es 1
	* Autor
		Félix Anadón Trigo

HELP



}
#-------------------------------------------------------------------------------
if [ "$1" = "-h" ]; then
	help
	exit 0
fi

pre='\t'
if [ "$1" = "-n" ]; then
	tabs=$2
	pre=''
	for i in $(seq $tabs); do
		pre="$pre"'\t'
	done
	shift;shift;
fi

cat $* \
| sed "s/^/$pre/"

