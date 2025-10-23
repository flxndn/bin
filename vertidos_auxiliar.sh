#!/bin/bash
IFS=$'\n'
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

	* Directorios 
		- base :: $dir_base
		- pendientes :: $dir_pendientes
		- diccionarios :: $dir_dict
	* Opciones
		- -h | --help :: Muestra esta ayuda.
		- -t | --txt :: Une todos los ficheros *.txt y *.old en uno que se llama vertidos_<SEGUNDOS_EPOCH>.txt
		- -d | --dict :: Si no existe copia del fichero diccionario lo mueve al directorio de directorios. :: Si existe y son diferentes hace un vimdiff de los dos ficheros.
		- -r | --unrar :: Extrae los ficheros *.rar
		- -z | --unzip :: Extrae los ficheros *.zip
		- -c | --copia :: Copia interactivamente los ficheror CEF/*.rar al directorio auxiliar.
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
	if [ "x$1" = "x-c" ] || [ "x$1" = "x--copia" ]; then
		dir_destino=/tmp/kk
		validez_archivo_cache_minutos=30
		tiempo_maximo_ficheros_rar_dias=7
		dir_cef=/media/scada/SAIHEBRO/Wapl/CEF
		cache=~/.cache_cef_rar;

		[ -d $dir_destino ] || mkdir $dir_destino
		if [ -z $(find ~/ -maxdepth 1 -name $(basename $cache) -cmin -$validez_archivo_cache_minutos ) ] ; then
			find $dir_cef -ctime -$tiempo_maximo_ficheros_rar_dias -name \*.rar > $cache
		fi
		f=$(cat $cache |fzf)
		[ -n "$f" ] && cp "$f" $dir_destino
		exit
	fi
	if [ "x$1" = "x-t" ] || [ "x$1" = "x--txt" ]; then
		tmp="$dir_pendientes/vertidos_$(date --rfc-3339=seconds| sed "s/[^0-9]/_/g").txt";

		find . -name \*.txt -o -name \*.old \
		| dos2unix \
		| sort \
		| xargs cat \
		| sed 's/^\xEF\xBB\xBF//' \
		| sed 's/; */;/g' \
		| sed 's/\x0d/\n/g' | grep BUEN \
		> $tmp \
		&& find . -name \*.txt -o -name \*.old \
		| xargs rm -f;

		shift;
	fi
	if [ "x$1" = "x-d" ] || [ "x$1" = "x--dict" ]; then
		for d in $(find . -name \*.rel);do
			set -x
			destino="$dir_dict/$(basename $d)";
			if [ ! -e $destino ]; then
				mv -v $d $dir_dict;
			else 
				if diff -q $d $destino >/dev/null ; then
					#echo "Diccionario igual al anterior"; 
					rm -i $d 
				else
					vimdiff $d $destino
				fi
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
