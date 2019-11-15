#!/bin/bash

readonly BASEDIR=$HOME/.gtd
readonly GTD_DEFAULT_FILE=$BASEDIR/organize.gtd
readonly HTML_FILE=$BASEDIR/out/pendiente.html

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre

	* Uso
		> $nombre [ARCHIVO_GTD]
		> $nombre --make
		> $nombre -h

	* Descripción
		Convierte el ARCHIVO_GTD o el archivo por defecto ($GTD_DEFAULT_FILE)
		en formato .gtd a formato texto.
		
		Convierte los WAIT con fecha vencida a TODO e invoca al editor de texto.

		Si se han realizado cambios convierte otra vez de texto a gtd y lo
		almacena en el archivo con el que estemos trabajando.

		Realiza una copia de seguridad mediante rcs.

	* Opciones
		* --make
			Ejecuta $BASEDIR/Makefile. Lo que sirve para generar 
			$html.

		* --firefox
			Ejecuta lo mismo que --make y muestra el resultado en firefox.

	* Autor
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
if [ "$1" = "-h" ]; then
	help
	exit 0
fi

if [ "$1" = "--make" ]; then
	cd $BASEDIR
	make
	exit 0
fi

if [ "$1" = "--firefox" ]; then
	$0 --make
	firefox $HTML_FILE
	exit 0
fi

if [ "$1" != "" ]; then
	gtd=$1
else
	gtd=$GTD_DEFAULT_FILE
fi

if [ ! -e $gtd ]; then
	echo "Error. El fichero $gtd no existe." >&2
	exit 1
fi

txt=~/tmp/$$.gtd

cad="WAIT `date +%Y-%m-%d`"
tmp=~/tmp/$$.tmp.gtd

gtd2txt.pl $gtd > $txt &&
wait2todo.pl $txt > $tmp &&
vi $tmp 

mv $tmp $txt && 
txt2gtd.pl $txt > $gtd &&
rm $txt

rcsdiff $gtd || ci -l $gtd
