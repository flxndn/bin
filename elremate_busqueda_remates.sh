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

set -x 

cookies=$(mktemp)
wget --quiet --keep-session-cookies --save-cookies $cookies $url_base -O - > /dev/null 

for lote in $*; do 
	tmp=$(mktemp)
	wget 	--quiet \
			--user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0" \
			--post-data "Tx_Subast=$subasta&Tx_Lote=$lote&Tx_Titulo=&Tx_Autor=&Tx_Materi=&Tx_Edicio=&Tx_Lugar=&Tx_Ano=&boton1=Buscar" \
			--load-cookies $cookies \
			-O $tmp \
			$url_base 

	if grep --quiet 'No se ha encontrado' $tmp; then
		echo "No se ha encontrado el lote $lote de la subasta $subasta" >&2
		cat $cookies
		exit 2
	else
		cat $tmp \
		| awk '/#F5ECC5/ {show=1} show; /<\/TR>/ {show=0 }' \
		| sed -n '19p' \
		| sed "s/ //g; s/\&nbsp;€//"
	fi
	#rm $tmp
done
rm $cookies
