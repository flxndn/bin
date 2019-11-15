#!/bin/bash

if [ "x$1" = "x-h" ]; then
	nombre="xml_ls_childs.sh";
	echo "* $nombre
	* Uso
		> $nombre -h
		> $nombre xpath fichero_xml
	* Descripción
		Saca por salida estándar los hijos del elemento xpath del fichero 
		fichero_xml.
	";
	exit 0
fi

xpath=$1
xml=$2

xml sel -T -t -m "$xpath/child::node()" -v 'name()' -n $xml \
| grep -v '^$'
