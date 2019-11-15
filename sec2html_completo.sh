#!/bin/bash

readonly ARGS="$@"
readonly PROGNAME=$(basename $0)
readonly CSSFILE=~/.css/ute.css

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
	* $PROGNAME
		* Uso
			> $PROGNAME -h|--help
			> $PROGNAME fichero_sec
		* Descripción
			Genera un fichero html completo: con head, title de la primera 
			línea del fichero fichero.css y la plantilla de estilos $CSSFILE.
		* Opciones
			* -h | --help
				Muestra esta ayuda
		* Dependencias
			- sectxt.py
			- html_envelope.sh
			- $CSSFILE
		* Bugs
			- El fichero $CSSFILE no se puede cambiar con comandos.  
			- No se puede cambiar la codificación de caractéres
			- No funciona con entrada estándar.
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
			#l) readonly COMMAND="log";shift;;
		esac
	done 
	readonly FILE=$(echo ${args[0]}|sed 's/^"//;s/"[^"]*//')
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main() {
#-------------------------------------------------------------------------------
	local title=$(head -n1 "$FILE" |cut -c3-)

	sectxt.py --toc --html --with-image-title "$FILE" \
	| html_envelope.sh -S $CSSFILE -t "$title" 
} 
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
parsearg $ARGS
main
