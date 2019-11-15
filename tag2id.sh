#!/bin/bash

#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	local nombre=$(basename $0)
	echo "* $nombre
	* Uso
		> $nombre -h
		> $nombre [-i] tag1 [tag2 … tagN]
	* Descripción
		Busca en Idor/Lista_senales el id de la señal que tenga el tag o los 
		tags de los parámetros.
	* Opciones
		* -h
			Muestra esta ayuda

		* -i
			Inversa. Para in id devuelve el tag.
	* Configuración
		Usuario y clave tiene que está definido mediante las opción 
		--login-path=Idor.
"
}
#-------------------------------------------------------------------------------

directa=1

if [ "x$1" = "x-h" ]; then
	help
	exit 0
fi
if [ "x$1" = "x-i" ]; then
	directa=''
	shift;
fi

(
for i in $*;do 
	if [ -z $directa ]; then
		echo "select ls_tag_txt from ListaSenalesCHE where ls_tag=$i;";
	else
		echo "select ls_tag from ListaSenalesCHE where ls_tag_txt='$i';";
	fi
done
) \
|  mysql \
		--login-path=Idor \
		--skip-column-names \
		Idor
