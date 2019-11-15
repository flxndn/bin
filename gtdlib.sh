#!/bin/bash

#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre

	* Uso
		> $nombre [dit]
		> $nombre w dias [persona]
		> $nombre -h

	* Descripción
		Lee de la entrada estándar y elimina las cadenas

		(INFO|TODO|DONE|WAIT [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])

		Añade otras dependiendo de las opciones.

		Es útil para utilizar como filtro para el editor VIM.

	* Opciones
		* d
			Añade a la línea 'DONE:'

		* i
			Añade a la línea 'INFO::'

		* t
			Añade a la línea 'TODO:'

		* w dias [persona]
			Añade a la línea 'WAIT fecha_actual+dias: [persona, ]'

		* -h
			Muestra esta ayuda

	* Autor
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
if [ "$1" = "-h" ]; then
	help
	exit 0
fi

comando=""
dias=""
usuario=""

if [ "$1" != "" ]; then
	comando=$1
fi

if [ "$1" == "w" ]; then
	dias="$2"
	persona="$3"
fi

sust=""

case "$comando" in
	"i") sust="INFO: ";;
	"t") sust="TODO: ";;
	"d") sust="DONE: ($(date +"%Y-%m-%d %k:%M:%S")): ";;
	"w") fecha=$(\
		perl -e '
				@d=localtime(time+'$dias'*24*60*60);
				$a=1900+$d[5];
				$m=$d[4]+1;if ($m<10){$m="0$m";};
				$d=$d[3]+1;if ($d<10){$d="0$d";};
				print "$a-$m-$d"'\
		)
		sust="WAIT $fecha: ";
		if [ "$persona" != "" ]; then sust="$sust$persona: ";fi;;
esac

sed "s/\t\(\(INFO\)\|\(TODO\)\|\(DONE\)\|\(WAIT [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)\): /\t$sust/"
