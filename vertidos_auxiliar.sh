#!/bin/bash
dir_base="/home/felix/ute/proyectos/2017-08-file2idor"
dir_pendientes="$dir_base/pendientes"
dir_dict="$dir_base/dic"

#-------------------------------------------------------------------------------
function ayuda {
#-------------------------------------------------------------------------------
	cat << HELP
* vertidos_auxiliar.sh
	Comandos para ayudar a procesar los vertidos.
	
	* Uso
		> vertidos_auxiliar.sh [opciones]

	* Opciones
		- -h | --help :: Muestra esta ayuda.
		- -t | --txt :: Une todos los ficheros *.txt y *.old en uno que se llama vertidos_<SEGUNDOS_EPOCH>.txt
		- -d | --dict :: Si no existe copia del fichero diccionario lo mueve al directorio de directorios. :: Si existe y son diferentes hace un vimdiff de los dos ficheros.
		- -r | --unrar :: Extrae los ficheros *.rar
		- -z | --unzip :: Extrae los ficheros *.zip
HELP

}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
# main
#------------------------------------------------------------------------------- 
while [ "x$1" != "x" ]; do
	if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
		ayuda
		exit;
	fi
	if [ "x$1" = "x-t" ] || [ "x$1" = "x--txt" ]; then
		tmp="$dir_pendientes/vertidos_$(date --rfc-3339=seconds| sed "s/[^0-9]/_/g").txt";

		find . -name \*.txt -o -name \*.old \
		| dos2unix \
		| sort \
		| xargs cat \
		| sed 's/^\xEF\xBB\xBF//' > $tmp \
		&& find . -name \*.txt -o -name \*.old \
		| xargs rm -f;

		shift;
	fi
	if [ "x$1" = "x-d" ] || [ "x$1" = "x--dict" ]; then
		for d in $(find . -name \*.rel);do
			destino="$dir_dict/$(basename $d)";
			if [ ! -e $destino ]; then
				mv -v $d $dir_dict;
			else 
				echo "Diccionario igual al anterior"; \
				diff -q $d $destino >/dev/null \
				&& rm $d \
				|| vimdiff $d $destino
			fi
			touch $destino
		done

		shift;
	fi
	if [ "x$1" = "x-r" ] || [ "x$1" = "x--unrar" ]; then
		for i in $(find . -name \*.rar); do 
			unrar x "$i" \
			&& rm -f "$i";
		done

		shift;
	fi
	IFS=$'\n'
	if [ "x$1" = "x-z" ] || [ "x$1" = "x--unzip" ]; then
		for i in $(find . -name \*.zip); do 
			unzip "$i" \
			&& rm -f "$i";
		done

		shift;
	fi
done
