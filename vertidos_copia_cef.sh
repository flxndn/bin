#!/bin/bash 

validez_archivo_cache_minutos=30
tiempo_maximo_ficheros_rar_dias=7
dir_cef=/media/scada/SAIHEBRO/Wapl/CEF
dir_destino=/tmp/kk

cache=~/.cache_cef_rar;
if [ -z $(find ~/ -maxdepth 1 -name $(basename $cache) -cmin -$validez_archivo_cache_minutos ) ] ; then
	find $dir_cef -ctime -$tiempo_maximo_ficheros_rar_dias -name \*.rar > $cache
fi
f=$(cat $cache |fzf)
[ -n "$f" ] && cp "$f" $dir_destino
