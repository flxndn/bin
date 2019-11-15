#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly DIR=/etc/apache2/sites-enabled
readonly ARGS="$@"
#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	cat <<END
* $PROGNAME
	* Descripción
		Saca los sites-available que hay en el directorio $DIR como un fichero [[https://en.wikipedia.org/wiki/Tab-separated_values|tsv]].

		Los campos son:
		- ruta del fichero
		- puerto
		- docroot

		Están definidos en el directorio $DIR.
END
}
#-------------------------------------------------------------------------------
arguments() {
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
main() {
#-------------------------------------------------------------------------------
	local file
	for file in $DIR/*.conf;do
		local puerto=$(grep '<VirtualHost' $file \
						| cut -f2 -d: \
						| sed "s/>//" )

		local documentroot=$(grep DocumentRoot $file \
						| cut -f2 -d' ')

		echo "$file	$puerto	$documentroot"
	done
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
arguments $ARGS
main
