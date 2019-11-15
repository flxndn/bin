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

	* Sinópsis
		Realiza las sustituciones de los #include como el 
		[[https://es.wikipedia.org/wiki/Preprocesador_de_C#Incluyendo_archivos|preprocesador de C]].
	* Descripción
		Lee la entrada estándar o el fichero pasado como parámetro.

		Si encuentra alguna de las opciones de la sintaxis ejecuta la acción correspondiente.

		Si no la deja sin modificar.

		Ni la ruta ni el fichero tienen que llevar comillas ni < o >.
	* Sintaxis
		Las órdenes tienen que estar al principio de la línea.

		* #include
			> #include ruta/fichero
			Sustituye la línea por el contenido del fichero.
		* #bash
			> #bash orden;
			Sustituye esta cadena por el resultado de la orden.

			Mantiene el resto de la línea, tanto lo que hay antes de #bash 
			como lo que hay a la derecha del punto y coma.

			Dentro de la orden sólo puede haber un punto y coma, sin 
			posibilidad de escape.

			La orden puede llevar argumentos, filtros, etc.
	* Opciones
		- -h | --help:: Muestra esta ayuda
	* Autor
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
while echo $1 | grep -q '^-' ;do
	case "$1" in 
	-h|--help) help; exit;;
	esac
done

IFS=$'\n'
for a in $(cat $1|dos2unix); do
	if echo $a | grep -q '^#include '; then
		fichero=$(echo $a|cut -f2- -d' ')
		if [ ! -r $fichero ]; then
			if [ ! -e $fichero ]; then
				mensaje="El fichero [$fichero] no existe.";
				error=1
			else
				mensaje="El fichero [$fichero] no se puede leer.";
				error=2
			fi
			(
			echo "Error: $error"
			echo $mensaje 
			) >&2
			exit $error
		fi
		cat $fichero
	else
		if echo $a | grep -q '#bash .*;'; then
			inicio=$(echo $a | sed "s/#bash [^;]*;.*//")
			orden=$(echo $a | sed "s/.*#bash \([^;]*\);.*/\1/")
			fin=$(echo $a | sed "s/.*#bash [^;]*;//")

			res=$(eval $orden)
			error=$?
			if [ $error != 0 ];then
				echo "Error $error" >2
				exit $error
			else
				echo "$inicio$res$fin"
			fi
		else
			echo "$a"
		fi
	fi
done 
