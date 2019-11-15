#!/bin/bash

readonly ARGS=$@
readonly PROGNAME=$(basename $0)
readonly TAMANO='2560x1920>'
readonly QUALITY='80%'

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
* $PROGNAME
	* Uso
		> $PROGNAME directorio [directorio2 ...]
		> $PROGNAME [-h|--help]
	* Descripción
		Para cada imagen contenida en el directorio especificado como 
		argumento convierte la calidad a $QUALITY y tamaño $TAMANO.

		El resultado lo deja en el archivo con el nombre formado por la 
		fecha de la toma de la foto el nombre del punto saih y un número 
		de orden entre paréntesis.

		El nombre saih tiene que ser el del directorio donde se encuentra.
	* Opciones
		* -h | --help
			Muestra esta ayuda
	* Dependencias
		- imagemagic:convert
		- jhead
	* Bugs
		No funciona si el nombre del directorio tiene espacios.
HELP
}
#-------------------------------------------------------------------------------
main(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)			args="${args}-h ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "h" OPTION; do
		case $OPTION in
			h) help; exit;;
		esac
	done

	shift $(( $OPTIND -1 ))

	for d in $args; do
		local dir=$(echo $d| sed "s/\"//g")
		posicion=0
		IFS=$'\n'
		for i in $(ls $dir/*.jpg $dir/*.JPG 2>/dev/null); do
			local input="$(echo "$i"| sed "s/\"//g")"
			#formato de salida AAAA.MM.DD A008(1).jpg
			fecha=$(jhead "$input" \
				| grep 'Date\/Time' \
				| cut -c16-25 \
				| sed "s/:/./g")
			codigo_saih=$(basename "$dir")
			posicion=$((posicion+1))

			output="$fecha $codigo_saih($posicion).jpg"

			if [ ! -e "$dir/$output" ];then
				convert "$input" -resize $TAMANO -quality $QUALITY "$dir/$output"  \
				&& rm "$input"
			fi 
		done
	done
}
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
main $ARGS
