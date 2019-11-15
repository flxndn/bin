#!/bin/bash
if [ "x$1" = "x-h" ]; then
	nombre="xml_cat_value.sh";
	echo "* $nombre
	* Uso
		> $nombre -h
		> $nombre xpath fichero_xml
	* Descripción
		Saca por salida estándar el valor del elemento xpath del
		fichero_xml.
	";
	exit 0
fi

xpath=$1
xml=$2

xml sel -T -t -m "$xpath" -v '.' -n $xml \
| grep -v '^$'
