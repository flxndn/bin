#!/bin/bash
in=/home/felix
out=/media/felix/Elements/personal
carpeta_imagenes=Fotos
fichero_configuracion=.local/share/shotwell

if [ "$1" = "-h" ]; then
	nombre=$(basename $0);
	echo "* $nombre
	* Uso
		> $nombre [ -o directorio_salida ]
		> $nombre -t
	* Descripción
		Realiza copia del directorio $in/$carpeta_imagenes y del fichero de 
		configuración $in/$fichero_configuracion en el directorio_salida.

		Por defecto el directorio de salida es $out.

	* Opciones
		- -t:: Comprueba que existen los directorios
		- -o directorio:: Realiza la copia e seguridad en este directorio.
"
	exit
fi


if [ "x$1" = "x-o" ]; then
	out="$2"
	shift;shift;
fi

if [ "$1" = "-t" ]; then
	for i in $in $in/$carpeta_imagenes $out; do
		if [ ! -d $i ]; then
			echo "El directorio $i no existe" >&2;
			exit 1
		fi
	done
	for i in $in/$fichero_configuracion; do
		if [ ! -r $i ]; then
			echo "El fichero $i no se puede leer" >&2;
			exit 1
		fi
	done
	exit 0
fi

for i in $carpeta_imagenes $fichero_configuracion; do
#for i in  $fichero_configuracion; do
	echo $i
	#rsync --dry-run -avt $i/ $out/$i
	rsync -avt $in/$i/ $out/$i
done
