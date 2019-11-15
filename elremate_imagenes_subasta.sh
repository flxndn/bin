#!/bin/bash
readonly url_base="http://www.elremate.es/lotes"

#-------------------------------------------------------------------------------
function ayuda {
#-------------------------------------------------------------------------------
	cat << HELP
* elremate_imagenes_subasta.sh
	Busca el remate de una subasta y un número de lote (pueden ser varios) concreto en $url_base.
	
	* Uso
		> busqueda_remates.sh -h
		> busqueda_remates.sh numero_subasta [numero_de_imagenes]

	* Opciones
		- -h | --help :: Muestra esta ayuda.
		- numero_subasta :: Subasta de la que se obtienen las imagenes
		- numero_de_imagenes :: Número de imágnes que se deescargarán, desde la 1 hasta numero_de_imagenes. :: Si no se especifica el valor por defecto es 1000
HELP

}
#-------------------------------------------------------------------------------


if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
	ayuda
	exit;
fi

subasta=$1;
shift;

if [ "x$1" = "x" ]; then
	max=1000
else
	max=$1
	shift
fi

seq $max \
| sed "s|^|$url_base/$subasta/|;s|$|.jpg|" \
| xargs -n1 wget

