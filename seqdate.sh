#!/bin/bash

help() {
	nombre=$(basename "$0")
	echo "* $nombre
	* Uso
		> $nombre inicio [fin [duracion]]
	* Descripción
		Saca por salida estándar la secuencia de quinceminutales entre inicio 
		y fin con formato rfc 3339.

	* Parámetros
		- inicio :: Fecja de inicio :: Parámetro obligatorio
		- fin :: Fecha de finalización :: Si no se indica se toma la fecha actual
		- duracion :: Segundos para la repetición :: Por defecto quince minutos, 60*15 
	* Ejemplo
		> seqdate.sh \"2016-12-12 00:00\" \"2016-12-12 09:00\"
";
}
if [ "x$1" = "x-h" ]; then
	help;
	exit 0
fi

if [ "x$1" = "x" ]; then
	echo "Error. No se ha indicado fecha de inicio." >&2
	echo >&2
	help >&2
	exit 1
fi
inicio="$(date +%s -d "$1")"

if [ "x$2" = "x" ]; then
	fin="$(date +%s)"
else
	fin="$(date +%s -d "$2")"
fi

if [ "x$3" = "x" ]; then
	qm=$((15*60))
else
	qm=$(($3))
fi

for i in $(seq $inicio $qm $fin); do 
	date --rfc-3339=seconds  -d "@$i";
done
