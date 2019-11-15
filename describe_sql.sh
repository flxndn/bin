#!/bin/bash 

#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	local nombre=$(basename $0)
	echo "* $nombre
	* Uso
		> $nombre -h|--help
		> $nombre <tabla>
	* Descripción
		Genera el código SQL compatible con ODBC para realizar una 
		descripción de los campos de <tabla>.
	* Motivaciones
		La orden DESCRIBE de las bases de datos Oracle no se puede invocar a 
		través del protocolo ODBC.
	* Opciones
		* -h
			Muestra esta ayuda.
"
}
#-------------------------------------------------------------------------------


tabla=''

while [ "x$1" != "x" ];do
	case "$1" in 
	-h|--help) help; exit 0;;
	*) tabla=$1;shift;;
	esac
done

if [ x$tabla = x ]; then
	echo "Error: no se ha definido la tabla." >&2
	echo "Uso:" >&2
	help >&2
	exit
fi

q="SELECT
		column_name, 
		data_type, 
		data_length, 
		nullable 
	FROM 
		all_tab_columns 
	WHERE 
		table_name = '$tabla'
	ORDER BY
		column_name;";
echo $q
