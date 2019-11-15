#!/bin/bash

readonly ARGS="$@"
readonly PROGNAME=$(basename $0)

readonly DEFAULT_FIELD=id
readonly R_NO_CAMBIADO=1

readonly R_MISMO_VALOR=0
readonly R_DIFERENTE_VALOR=1
readonly R_ERROR_NO_EXISTE=2
readonly R_ERROR_SINTAXIS=3

readonly DEFAULT_COMMAND="list"
#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
	* $PROGNAME
		Obtiene los campos "id" de un fichero xml.

		Se creó para analizar los esquemas de las estaciones de Intranet.
		* Uso
			> $PROGNAME [-h|--help]
			> $PROGNAME [-l|--list|-d|--duplicates|-h|--has-duplicates] [-f|--field field] fichero.xml
		* Opciones
			* -h | --help
				Muestra esta ayuda
			* -f | --field field
				Busca los campos field.

				Si no se especifica busca el campo "$DEFAULT_FIELD".
			* -l|--list
				Muestra el listado de valores de ids.
			* -d|--duplicates
				Muestra los valores de los ids repetidos
			* -u|--uniqness
				Si tiene duplicados devuelve 1 y si no tiene devuelve 0.
HELP
}
#-------------------------------------------------------------------------------
parsearg(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)			args="${args}-h ";;
			--field)		args="${args}-f ";;
			--field)		args="${args}-f ";;
			--list)			args="${args}-l ";;
			--duplicates)	args="${args}-d ";;
			--uniqness)		args="${args}-u ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "hf:ldu" OPTION; do
		case $OPTION in
			h) help; exit;;
			f) local option_field=$OPTARG; shift;;
			l) readonly command_option=list;;
			d) readonly command_option=duplicates;;
			u) readonly command_option=uniqness;;
		esac
	done 

	if [ -z $option_field ]; then
		readonly FIELD=$DEFAULT_FIELD
	else
		readonly FIELD=$option_field
	fi

	if [ -z $command_option ]; then
		readonly COMMAND=$DEFAULT_COMMAND
	else
		readonly COMMAND=$command_option
	fi

	shift $(( $OPTIND -1 )) 

	readonly FILE="$arg"
}
#-------------------------------------------------------------------------------
all() {
#-------------------------------------------------------------------------------
	iconv -t UTF-8 -f ISO-8859-1 "$FILE" \
	| sed "s/ $FIELD=/\n$FIELD=/g" \
	| grep "$FIELD=" \
	| sed "s/^$FIELD=\"//;s/\".*//" 
}
#-------------------------------------------------------------------------------
duplicates() {
#-------------------------------------------------------------------------------
	all \
	| sort \
	| uniq -d
}
#-------------------------------------------------------------------------------
uniqness() {
#-------------------------------------------------------------------------------
	local d=$(duplicates)
	if [ -z "$d" ];then
		exit 0
	else
		exit 1
	fi
}
#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	case $COMMAND in
		list)	all;;
		duplicates) duplicates;;
		uniqness) uniqness;;
	esac
}
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
parsearg $ARGS
main
