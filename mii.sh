#!/bin/bash

readonly NOMBRE=`basename $0`
readonly RUNTIME_CONF=$HOME/.mii

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	cat <<HELP
* $nombre

	* Uso
		> $nombre [-S] ["sql"]
		> $nombre -e
        > $nombre -h

	* DESCRIPCIÓN
		Pasa la consulta por entrada estandar o como argumento a mysql 
		utilizando los parámetros que están en el fichero de configuración 
		$rc.
	
	* Opciones
		* -h
			Muestra esta ayuda.

		* -e
			Edita el fichero de configuración.

		* -c [nombre_fichero]
			Si se especifica un fichero se copia a $rc.

			Si no se especifica interactivamente cambia entre los ficheros de 
			configuración que hay en \$HOME/.mii.xxx
		* -S
			Muestra el encabezado de las tablas.
	* AUTOR
		Félix Anadón Trigo

HELP 
}
#-------------------------------------------------------------------------------

encabezados=0

if [ "$1" = "-h" ]; then
	help
	exit 0
fi

if [ "$1" = "-e" ]; then
	vi $RUNTIME_CONF
	exit 0
fi


if [ "$1" = "-c" ]; then
	if [ "x$2" != "x" ] && [ -e $2 ]; then
		cp $2 $RUNTIME_CONF
	else  
		select i in $HOME/.mii.*; do
			$0 -c $i;
			break;
		done
	fi
	exit 0
fi

if [ "$1" == "-S" ]; then
	encabezados=1
	shift
fi

if [ $encabezados == 1 ]; then
	opciones=""
else
	opciones="-s"
fi

if [ "$1" == "" ]; then
	. $RUNTIME_CONF
	mysql $opciones -u $user -p$pass -h $host $database
else
	echo $* | $nombre
fi

