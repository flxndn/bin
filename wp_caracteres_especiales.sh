#!/bin/bash

help() {
	nombre=$(basename $0)
	echo "* $nombre
	* Uso
		- $nombre [fichero]
		- $nombre -h
	* Descripción 
		Convierte algunas abreviaturas de signos en los signos correspondientes
	* Símbolos convertidos
		- Tres puntos en elipsis
		- Dos guiones en guión largo
		- ss. en el símbolo de sección
	* Opciones
		* -h
			Muestra esta ayuda 
"
}

if [ "x$1" = "x-h" ]; then
	help
	exit 0
fi

cat \
| sed "s/\.\.\./…/g" \
| sed "s/--/—/g" \
| sed "s/\<ss\./§/g"
