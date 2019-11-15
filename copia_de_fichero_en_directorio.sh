#!/bin/bash

readonly ARGS=$@
readonly PROGNAME=$(basename $0)

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
* $PROGNAME
	* Uso
		> $PROGNAME fichero directorio
		> $PROGNAME [-h|--help]
	* Descripción
		Mira a ver si hay un fichero en el directorio que tenga el mismo 
		contenido que el fichero usado como argumento.

		Para comprobar la igualdad busca los ficheros que tengan los mismos 
		bytes que fichero y entre ellos prueba con el md5.
	* Opciones
		* -h | --help
			Muestra esta ayuda
	* Bugs
		Falla cuando hay espacios en los nombres del fichero o del directorio
HELP
}
#-------------------------------------------------------------------------------
main(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)			args="${args}-h ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "h" OPTION; do
		case $OPTION in
			h) help; exit;;
		esac
	done

	shift $(( $OPTIND -1 ))

	readonly fichero=$1
	readonly directorio=$2
	readonly bytes=$(cat $fichero|wc -c)

	ficheros=$(find $directorio -size ${bytes}c)

	if  [ "x$ficheros" = "x" ]; then
		exit 1;
	else
		md=$(md5sum $fichero|cut -f1 -d' ')
		for f in $ficheros; do
			m=$(md5sum $f|cut -f1 -d' ')
			if [ $m = $md ]; then
				echo $f
			fi 
		done
	fi
}
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
main $ARGS
