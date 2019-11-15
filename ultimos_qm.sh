#!/bin/bash

segundos_defecto=$((20*60))
ano=$(date +"%Y")

help() {
	nombre=$(basename $0)

	echo "* $nombre
	* Uso
		> $nombre [segundos]
	* Descripción
		Saca por salida estándar la cantidad de quinceminutales que hay en 
		Idor/Datos$ano@idor con fecha posterior a la fecha actual menos segundos.

	* Opciones
		- segundos :: Tiempo antes de la fecha actual. :: La opción por defecto es $segundos_defecto."
}

if [ "x$1" = "x-h" ]; then
	help
	exit 0
fi

if [ "x$1" = "x" ]; then
	segundos=$segundos_defecto
else
	segundos=$1
fi

f=$(date --date=@$(echo $(($(date +%s) - segundos))) +"%Y-%m-%d %H:%M")

echo "select count(*) from Datos$ano where fecha >= '$f'"  \
| mysql --login-path=Idor Idor --silent
