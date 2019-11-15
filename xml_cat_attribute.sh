#!/bin/bash


if [ "x$1" = "x-h" ]; then
	nombre="xml_cat_attribute.sh";
	echo "* $nombre
	* Uso
		> $nombre -h
		> $nombre xpath parametro fichero_xml
	* Descripción
		Saca por salida estándar el valor del parámetro del elemento xpath 
		del fichero_xml.
	";
	exit 0
fi


xpath=$1
parameter=$2
xml=$3

xml sel -T -t -m "$xpath" -v "@$parameter" -n $xml \
| grep -v '^$'
