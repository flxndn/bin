#!/bin/bash


#-------------------------------------------------------------------------------
function ayuda {
#-------------------------------------------------------------------------------
	cat << HELP
* el_remate_busqueda_remates.sh
	Da información sobre la próxima subasta de El Remate

	El formato en el que lo devuelve es:
	>> 224 - 17  MARZO 2022 18:00
	
	* Uso
		> busqueda_remates.sh -h
		> busqueda_remates.sh 

	* Opciones
		- -h | --help :: Muestra esta ayuda.
HELP

}
#-------------------------------------------------------------------------------


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	ayuda
	exit;
fi

url="https://www.elremate.es"

wget -O-  $url \
| grep rotulo \
| sed "s/.*SUBASTA \(.*\)h<.*/\1/"
