#!/bin/bash

#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	local nombre=$(basename $0)
	echo "* $nombre
	* Uso
		> $nombre -h|--help
		> $nombre -u|--update| fichero [fichero2 ... ficheroN]
		> $nombre -c fichero_cache fichero
	* Descripción
		Devuelve el fichero que es idéntico a fichero que esté guardado en el fichero_cache.

		El resultado es 0 si lo ha encontrado o 1 si no lo ha encontrado.
	* Opciones
		* -c fichero_cache
			Especifica el fichero que se usará como caché.
		* -u|--update
			Actualiza la base de datos.
			Saca por salida estándar el md5 de cada fichero especificado.
		* -h|--help
			Muestra esta ayuda.
"
}
#-------------------------------------------------------------------------------
function update {
#-------------------------------------------------------------------------------
	md5sum "${files[@]}"
}
#-------------------------------------------------------------------------------
function comprobacion {
#-------------------------------------------------------------------------------
	IFS=$'\n'
	for i in ${files[@]}; do
		suma=$(md5sum "$i" | cut -f1 -d' ')
		file=$(grep "^$suma" $cache_md5f| cut -f2- -d' ')
		if [ "x$file" = "x" ]; then
			exit 1
		else 
			echo "$file"
			exit 0
		fi
	done
}
#-------------------------------------------------------------------------------

declare -a files
cache_md5f=""
accion=comprobacion

while [ "x$1" != "x" ];do
	case "$1" in 
	-h|--help) help; exit 0;;
	-c) cache_md5f=$2;shift;shift;;
	-u|--update) accion=update;shift;;
	*) files+=("$1");shift;;
	esac
done

if [ $accion = update ] ; then
	update
else
	comprobacion
fi
