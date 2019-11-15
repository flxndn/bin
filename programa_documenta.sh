#!/bin/bash

# Constantes

#-------------------------------------------------------------------------------
function e() {
#-------------------------------------------------------------------------------
	 [ $verbose = 1 ] && echo $(date) "$1"
}
#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre

	* Uso
		> $nombre [-c] [-t cabecera.sec] programa [programa2 ...]
		> $nombre -h

	* Descripción
		Saca la documentación de uno o varios programas en formato sectxt.

	* Requerimientos
		- sectxt.py
		- Los programas para documentar tienen que generar documentación en formato sectxt al invocarlos con la opción [-h].

	* Opciones
		* -h 
			Muestra esta ayuda.
		* -c 
			Añade el código tras la ayuda.
		* -t cabecera.sec
			Añade el fichero cabecera con xxx.
HELP

}
#-------------------------------------------------------------------------------
function tab() {
	cat | sed "s/^/\t/"
}
#-------------------------------------------------------------------------------

if [ "$1" = "-h" ]; then
	help
	exit 0
fi

con_codigo=0
cabecera=''
contador=0

while [ "x$1" != "x" ];do
	case "$1" in 
	-c) con_codigo=1;shift;;
	-t) cabecera=$2; shift;shift;;
	*) archivos="$archivos $1";contador=$((contador+1));shift;;
	esac
done

# Cabecera

if [ "x$cabecera" != "x" ]; then
	cat $cabecera
	postproceso=tab
else
	if [ $contador != 1 ]; then
		echo "* Documentación de programas"
		date | tab
		postproceso=tab
	else
		postproceso=cat
	fi
fi

# archivos
for archivo in $archivos; do
	$archivo -h
	if [ "$con_codigo" = 1 ]; then
		echo -e "\t * Código"
		cat $archivos | sed "s/^/\t\t> /"
	fi
done | $postproceso
