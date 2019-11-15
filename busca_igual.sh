#!/bin/bash

#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	cat <<END
* busca_igual.sh 
	* Uso
		- busca_igual.sh fichero [directorio]
		- busca_igual.sh -h|--help

	* Descripción
		Busca en el directorio especificado o en el directorio de trabajo un 
		fichero que tenga el mismo tamaño y que diff diga que es igual que
		'fichero'.

		No muestra si es el mismo inode.
	* Resultado
		- 0: Si encuentra uno o más ficheros iguales al fichero
		- 1: Si no encuentra ningún fichero igual.
		- 64: Si los parámetro producen error.
END
}

#-------------------------------------------------------------------------------
function assert() {
#-------------------------------------------------------------------------------
	if [ ! $1 ] ; then
		echo "$0, ($1) línea $2: $3." >&2
		exit 64
	fi
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
	help
	exit
fi

fichero=$1

assert "x$fichero != 'x'"  $LINENO "Falta el parámetro fichero"
assert "! -r \"$(printf '%q' $fichero)\""       $LINENO "No puedo leer el fichero \"$fichero\""

if [ "x$2" = "x" ]; then
	directorio=$(pwd)
else
	directorio=$2
fi
assert "-d $directorio"	   $LINENO "Directorio \"$directorio\" inexistente."

encontrado=1
# Buscamos en el directorio los fichero con los mismos bytes
IFS=$'\n'
for f in $(find "$directorio" -size $(stat -c%s "$fichero")c); do
	assert "-r \"$(printf '%q' $f)\""       $LINENO "No puedo leer el fichero \"$f\""
	# Ignoramos si estamos accediendo con dos nombres al mismo fichero
	if [ $(ls --inode "$fichero"|cut -f1 -d' ') != $(ls --inode "$f"|cut -f1 -d' ') ]; then
		if diff "$fichero" "$f" >/dev/null ; then
			echo "$f"
			encontrado=0
		fi
	fi
done
exit $encontrado
