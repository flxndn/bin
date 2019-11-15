#!/bin/bash

#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	local nombre=$(basename $0)
	echo "* $nombre
	* Uso
		> $nombre -h
		> $nombre [fichero]
	* Descripción
		Cuando se usa la construcción error_log(print_r(array(... en php los 
		tabuladores, retornos de carro y nueva línea son escapados, para 
		formatear estos logs hay que desescaparlos.

		Eso es lo que hace esta función.
	* Opciones
		* -h
			Muestra esta ayuda
"
}
#-------------------------------------------------------------------------------

if [ "x$1" = "x-h" ]; then
	help
	exit 0
fi

#sed 's/\\t/\t/g' | sed 's/\\r/\n/g' | sed 's/\\n//g'
sed 's/\\t/\t/g;s/\\r/\n/g;s/\\n//g'
