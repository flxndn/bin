#!/bin/bash

declare -a extensiones=(Makefile '*.sh' '*.bash' \
							'*.pl' '*.php' '*.js' '*.htm' '*.html' \
							'*.css' '*.cpp' '*.py' '*.java' '*.jrxml' \
							'*.xml' '*.xsl' '*.c' '*.h' '*.frm' '*.vb' \
							'*.svg' )

lista=""
listainames=""

for i in "${extensiones[@]}"; do
	lista="$lista
		- $i";
	listainames="$listainames -o -iname '$i'";
done
listainames=${listainames/-o /}
#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	local nombre=$(basename $0)
	echo "* $nombre
	* Uso
		> $nombre -h|--help
		> $nombre [-i] [-l] cadena_a_buscar
	* Descripción
		Busca la cadena de texto cadena_a_buscar en todos los ficheros de 
		programación que estén en el directorio actual o por debajo.

		Busca en los ficheros que tengan las extesiones en mayúsculas o minúsculas: $lista
	* Opciones
		* -i
			El texto de la cadena a buscar es independiente del caso 
			(mayúsculas/minuúsculas).
		* -l
			Muestra sólo el nombre del fichero donde se encuentra, 
			sin la línea.
"
}
#-------------------------------------------------------------------------------

verbose=''

caseoption=''
lineoption=''
cadena_a_buscar=""

while [ "x$1" != "x" ];do
	case "$1" in 
	-h|--help) help; exit 0;;
	-i|--ignore_case) caseoption="-i"; shift;;
	-l) lineoption="-l";shift;;
	*) cadena_a_buscar="$1"; shift;;
	esac
done

IFS=$'\n'
#grep -a $caseoption $lineoption "$cadena_a_buscar" $(eval "find . $listainames")
eval "find .  $listainames"| xargs -d'\n' grep -a $caseoption $lineoption "$cadena_a_buscar" 
