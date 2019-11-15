#!/bin/bash

# ejemplo de señal a enviar
# http://$host/axis-cgi/com/ptz.cgi?gotoserverpresetname=botella
# Sintaxis de estas cámaras: http://www.axis.com/techsup/cam_servers/dev/cam_http_api_2.php#definitions_general_notations_naming_conv_cgi

ip=10.152.11.156 
comandos="gotopreset move zoom"
preposiciones="Botella RJ45 escalera"
desplazamientos="home up down left right upleft upright downleft downright"
zooms="9 99 999 9999"

nombre=$(basename $0)
function help {
	echo "* $nombre
	* Uso:
		- $nombre
		- $nombre
		- $nombre command
		- $nombre [-d|--dry-run] command value ip
	* Opciones
		* -i $
			Se ejecuta en modo interactivo.
		* -c
			Saca un listado de comandos disponibles.
		* -v command 
			Saca un listado de valores posibles para command.
		* -d|--dry-run
			Muestra la url a la que se accedería pero no la ejecuta.
		* command value
			Envia a la cámara el comando command con el valor value."
}
if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
	help;
	exit 0;
fi

dry_run=0
opciones=""

if [ "x$1" = "x-d" ] || [ "x$1" = "x--dry-run" ]; then
	dry_run=1
	opciones="$opciones --dry-run"
	shift;
fi

if [ "$1" = "-i" ]; then
	select c in $($0 $opciones -c); do
		select v in $($0 $opciones -v $c); do
			$0 $opciones $c $v
			exit
			break
		done
		break
	done
elif [ "$1" = "-c" ]; then
	echo $comandos
elif [ "$1" = "-v" ]; then
	if [ "x$2" = "xgotopreset" ]; then
		echo $preposiciones
	elif [ "$2" = "move" ]; then
		echo $desplazamientos
	elif [ "$2" = "zoom" ]; then
		echo $zooms
	fi
else
	command=$1
	shift
	if [ "$command" = "gotopreset" ]; then
		name=gotoserverpresetname
		value=$1
		shift
	fi
	if [ "$command" = "qpresets" ]; then
		name=query
		value=presetposall
	else
		name=$command
		value=$1
		shift
	fi
	ip=$1
	shift

	url="http://$ip/axis-cgi/com/ptz.cgi?$name=$value"
	if [[ $dry_run = 1 ]]; then
		echo "$url"
	else
		wget -O /tmp/cgi.tmp "$url"
	fi
fi

