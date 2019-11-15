#!/bin/bash 


#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
nombre=$(basename $0)
echo "* $nombre
	* Uso
		$nombre prefijo fichero.sec
		$nombre -h|--help
	* Descripción
		Saca por salida estándar el fichero _fichero.sec_ convertido al formato 
		que indica _prefijo_.

		_prefijo_ puede ser rtf o pdf.

	* Opciones
		* -h | --help
			Muestra esta ayuda.
"
}
		
#-------------------------------------------------------------------------------

if [ "x$1" = "x-h" ] || [ "x$1" = "x--help" ]; then
	help
	exit 0
fi

sufijo=$1
if [ $sufijo != "pdf" ] || [ $suffix != "rtf" ]; then
	help;
	exit 1
fi

xml=$(mktemp --suffix=.xml)
fo=$(mktemp --suffix=.fo)
file=$(mktemp --suffix=.$sufijo)

sectxt.py --article "$*" > $xml \
&& xsltproc --output $fo ~/doc/article_fo.xslt $xml \
&& fop $fo $file  \
&& cat $file \
&& rm $xml $fo $file
