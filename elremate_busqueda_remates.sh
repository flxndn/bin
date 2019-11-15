#!/bin/bash
readonly url_base="http://www.elremate.es/busqueda_remates.php"

#-------------------------------------------------------------------------------
function ayuda {
#-------------------------------------------------------------------------------
	cat << HELP
* el_remate_busqueda_remates.sh
	Busca el remate de una subasta y un número de lote (pueden ser varios) concreto en $url_base.
	
	* Uso
		> busqueda_remates.sh -h
		> busqueda_remates.sh numero_subasta numero_lote [numero_lote_2 ...]

	* Opciones
		- -h | --help :: Muestra esta ayuda.
HELP

}
#-------------------------------------------------------------------------------


if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
	ayuda
	exit;
fi

subasta=$1;
shift;

for lote in $*; do 
	wget -q --post-data "Tx_Subast=$subasta&Tx_Lote=$lote" $url_base -O - \
	| awk '/#F5ECC5/ {show=1} show; /<\/TR>/ {show=0 }' \
	| sed -n '19p' \
	| sed "s/ //g; s/\&nbsp;€//"
done
