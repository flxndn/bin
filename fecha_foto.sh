#!/bin/bash

if [ x$1 = "x-h" ]; then 
echo "
* $(basename $0)
	* Uso
		> $(basename $0) fichero1 [fichero2 ...]
	* Descripción
		Para cada uno de los ficheros usados como parámetros devuelve una 
		cadena con la fecha de modificación de la forma aaaa/mm/dd. 
		
		Apto para almacenar como lo hace shotwell."
	exit 0
fi

ls --full-time $* \
| sed "s/  */ /g" \
| cut -f6 -d' ' \
| sed "s/-/\//g" 
