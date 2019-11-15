#!/bin/bash

#-------------------------------------------------------------------------------
# Constantes

fichero="$HOME/var/log/bitacora.txt"

#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre
	* Uso
		$nombre [-o fichero] [texto]

		$nombre -c | --cat

		$nombre -h|--help

	* Descripción
		Lee de entrada estándar (o el texto que se ha pasado por comando y lo 
		añade en fichero añadiéndole la fecha actual, usuario y nombre de la 
		máquina.

	* Opciones
		* -o fichero
			Indica el fichero en el que se va a guardar.

			Si no se indica otra cosa el fichero será $fichero

		* -c | --cat
			Saca por salida estandar el fichero registro.

		* -h | --help
			Muestra esta ayuda

		* -i | --interactive
			Va metiendo en el log línea a línea. 
			Se activa cuando hacemos un retorno de línea.
		* -I | --init
			Mete un mensaje de inicio de sesión.
		* -O | --out
			Mete un mensaje de fin de sesión.

	* AUTOR
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
function l {
#-------------------------------------------------------------------------------
	fecha=$(date +"%Y-%m-%d %H:%M:%S")
	usuario=$(whoami)@$(uname -n)
	echo -e "$fecha\t$usuario\t$*"
}
#-------------------------------------------------------------------------------
function log {
#-------------------------------------------------------------------------------
	l $* >> $fichero
}
#-------------------------------------------------------------------------------
while echo $1 | grep '^-' ;do
	case "$1" in 
	-h|--help) help; exit;;
	-c|--cat) cat $fichero; exit;;
	-i|--interactive) 
		while read a; do
			l "$a"
			l "$a" >> $fichero
		done
		exit;;
	-o|--output) fichero=$2; shift;;
	-I|--init) log "Organizando"; exit;;
	-O|--out) log "Fin de sesión"; exit;;
	esac
done

if [ "x$1" = "x-i" ] || [ "x$1" = "x--interactive" ]; then
	while read a; do
		l "$a"
		l "$a" >> $fichero
	done
	exit
fi

while [ "$1" ]; do
	if [ "x$1" == "x" ]; then
		cat | log
	else
		log $*
		exit
	fi
done
log $(cat)

