#!/bin/bash

if [ "x$1" = "x-h" ]; then
	nombre="xml_structure.sh";
	echo "* $nombre
	* Uso
		> $nombre -h
		> $nombre fichero_xml
	* Descripción
		Saca por salida estándar la estructura del fichero 
		fichero_xml.
	";
	exit 0
fi
xml=$1

xml el -a $1
