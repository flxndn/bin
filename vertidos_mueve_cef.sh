#!/bin/bash 

validez_archivo_cache_minutos=1
tiempo_maximo_ficheros_rar_dias=7
dir_cef=/mnt/scada/SAIHEBRO/Wapl/CEF
dir_destino=/tmp/kk

cache=~/.cache_cef_rar;
if [ -z $(find ~/ -maxdepth 1 -name $(basename $cache) -cmin -$validez_archivo_cache_minutos ) ] ; then
	echo "Actualizando caché" >&2
	IFS=$'\n'
	for d in $(find $dir_cef -mindepth 1 -maxdepth 2 -iname 'Datos para actualizar'); do
		find $d -maxdepth 1 -ctime -$tiempo_maximo_ficheros_rar_dias -name \*.rar ;
	done > $cache
	#find "$dir_cef/*/Datos para actualizar/" -maxdepth 1 -name \*.rar > $cache
fi
f=$(cat $cache |fzf)
[ -n "$f" ] && mv -v "$f" $dir_destino
