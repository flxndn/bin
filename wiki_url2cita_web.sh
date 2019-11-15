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
		> $nombre [-f]
		> $nombre [-t|--test]
		> $nombre -h

	* Descripción
		Convierte un enlace web de la wikipedia de la forma 
		> [url titulo] 
		de la entrada estándard a 
		> {{ cita web
		> 	| título = titulo
		> 	| url = url
		> 	}}

	* Opciones
		* -h 
			Muestra esta ayuda.

		* -f
			Incluye el campo fechaacceso con la fecha actual.

		* -t o --test
			Realiza una prueba de funcionamiento.

	* Bugs
		- Si no hay título (sólo url) el programa no hace nada.
HELP

}
#-------------------------------------------------------------------------------
if [ "x$1" = "x-h" ]; then
	help
	exit 0
fi

if [ "x$1" = "x-t" ] || [ "x$1" = "x--test" ]; then
	res=$(echo "[protocolo://maquina.dominio.sufijo/path/archivo El título]" | $0)
	correcto="{{
	cita web 
	| título = El título 
	| url = protocolo://maquina.dominio.sufijo/path/archivo
	}}
"
	if [ $res = $correcto ];then
		echo si
	else
		echo no
	fi
	exit 0
fi

fechaacceso=""

if [ "$1" = "-f" ]; then
	fechaacceso=" | fechaacceso = $(date +"%-d de %B de %Y")"
fi

sed "s/\[\([^ ]*\) \([^]]*\)\]/{{ cita web | título = \2 | url = \1$fechaacceso}}/g" \
| sed "s/|/\n\t|/g" \
| sed "s/{{ /{{\n\t/g" \
| sed "s/}}/\n\t}}/g";
#sed "s/\[([^ ]*) ([^\]\]*)/{{cita web\n\t| título = $2\n\t| url = $1\n\t}}/g"
