#!/bin/bash

readonly ARGS="$@"
readonly PROGNAME=$(basename $0)
readonly LOGDIR=~/.change

readonly R_CAMBIADO=0
readonly R_NO_CAMBIADO=1

readonly R_MISMO_VALOR=0
readonly R_DIFERENTE_VALOR=1
readonly R_ERROR_NO_EXISTE=2
readonly R_ERROR_SINTAXIS=3
#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
	* $PROGNAME
		Si la entrada de texto es un listado de n números saca por salida 
		estándar las n-1 diferencias entre los números consecutivos.
		* Uso
			> $PROGNAME
			> $PROGNAME
		* Opciones
			* -h | --help
				Muestra esta ayuda
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
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	read a0

	while read a1; do
		echo $((a1-a0));
		a0=$a1;
	done
} 
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
parsearg $ARGS
main 
