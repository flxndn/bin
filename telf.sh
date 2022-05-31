#!/bin/bash

dir=~/.telf
entradas=$dir/contactos.txt
readonly ARGS="$@"
readonly NOMBRE=$(basename $0)

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	cat <<HELP
* $NOMBRE 
	* Uso
		> $NOMBRE -h
		> $NOMBRE -e
		> $NOMBRE [-in] cadena [cadena]

	* Descripción
		Busca en los archivos del directorio $dir las cadenas tanto en minúsculas
		como mayúsculas.

		Si hay una segunda cadena se hace un grep con esta cadena.

		* Opciones
			* -h | --help
				Muestra esta ayuda.
			* -e | --edit
				Edita el archivo $entradas 
			* -i | --ignore-case
				Ignora las diferencias mayúsculas minúsculas.

				Es la opción por defecto.  
			* -n | --no-ignore-case
				No ignora las minúsculas de las mayúsculas.  
HELP
}
#-------------------------------------------------------------------------------
parsearg(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)				args="${args}-h ";;
			--edit)				args="${args}-e ";;
			--ignore-case)		args="${args}-i ";;
			--no-ignore-case)	args="${args}-n ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "hine" OPTION; do
		case $OPTION in
			h) help; exit;;
			i) readonly OPCIONES_GREP_USUARIO="i";shift;;
			n) readonly OPCIONES_GREP_USUARIO="n";shift;;
			e) readonly COMMAND="e";shift;;
		esac
	done 

	case $OPCIONES_GREP_USUARIO in
		n) readonly OPCIONES_GREP="";;
		*) readonly OPCIONES_GREP="-i";;
	esac;

	readonly PARAMS=$*
}
#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	if [ ! -d $dir ];then mkdir -p $dir;fi
	if [ ! -e $entradas ];then touch $entradas;fi

	case $COMMAND in
		e) vi $entradas
			;;
		*) if [ "x$PARAMS" = "x" ]; then
				grep "^[^#]" $dir/*.* | fzf --preview='figlet -f banner {}'
			else
				grep "^[^#]" $dir/*.* | grep $OPCIONES_GREP $PARAMS | fzf --preview='figlet -f banner {}'
			fi
			;;
	esac
} 
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
parsearg $ARGS
main 

