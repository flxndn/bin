#!/bin/bash 
readonly ret=$'\n' 

IFS=$'\n'

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	nombre=$(basename $0)
	cat <<HELP
* $nombre

	* Uso
		> $nombre fichero_sql
		> $nombre -h

	* Descripción
		Coje el fichero fichero_sql, lo convierte en una única línea y se lo 
		pasa al alias? que está indicado en el fichero db_cliente.txt en el 
		mismo directorio

		El formato de salida es un fichero csv con primera línea de 
		encabezado de nombres de columnas y campos separados por tabuladores.

	* Opciones
		* -h:: Saca esta ayuda

	* Motivación
		Que se pueda operar en todas la tablas de manera similar.

	* Autor
		Félix Anadón Trigo
HELP
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

if [ "x$1" = "x-h" ]; then help; exit 0; fi 

fichero_sql="$1";
	
. $(dirname $fichero_sql)/db_cliente.sh
echo $(grep -v '^--' -- $fichero_sql) | $command -v -b -c -d$'\t' $db $user $passwd
