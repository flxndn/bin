#!/bin/bash

#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre
	* Uso
		> $nombre [fichero]
		> $nombre -h|--help

	* Descripción
		Lee la entrada estándar o el fichero pasado como parámetro y saca por 
		salida estándar las plantillas SIGLO que encuentra.

		La utilidad prevista es encontrar si hay wikienlaces repetidos a siglos, 
		ejecutando la orden
		> $nombre fichero.wiki | sort | uniq -c

	* Opciones
		* -h | --help
			Muestra esta ayuda
	* AUTOR
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
while echo $1 | grep -q '^-' ;do
	case "$1" in 
	-h|--help) help; exit;;
	esac
done

grep '{{SIGLO|' $* \
| sed "s/{{/\n{{/g;s/}}/}}\n/g" \
| grep '{{SIGLO|'
