#!/bin/bash

readonly DIR_ESQUEMAS=/home/felix/ute/proyectos/saihebro_intranet/views/elements/esquemas/datos
readonly DB=CHEINTR
readonly TABLA=lista_senales

IFS=$'\n'

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	nombre=$(basename $0)
	cat <<HELP
* $nombre
	* Uso
		> $nombre tabla
		> $nombre -h
	* Descripción
		Genera una cadena SQL para poder buscar elementos de la tabla tabla.
	* Opciones
		* -h
			Muestra esta ayuda.
	* Autor
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
comprueba() {
#-------------------------------------------------------------------------------
	comprueba_ids $*
	comprueba_senales $*
	comprueba_conflictos $*
}
#-------------------------------------------------------------------------------
comprueba_ids() {
#-------------------------------------------------------------------------------
	for i in $*; do
		hay_repes=$(grep --text -i 'id *=' $i \
					| iconv -f ISO-8859-15 -t UTF-8 \
					| sed "s/^.*id *= *[\"']//i;s/['\"].*//" \
					| sort \
					| uniq -c \
					| grep --text -v '      1')
		if [ -n "$hay_repes" ]; then
			echo "Error: Id repetido $i ($hay_repes)" >&2
		fi
	done
}
#-------------------------------------------------------------------------------
existe_en_lista_senales() {
#-------------------------------------------------------------------------------
	c=$( echo "select count(LS_TAG_TXT) from $TABLA where LS_TAG_TXT='$1'"  \
		| isql -b -d: $DB cheintr cheintr )
	if [ $c = 1 ]; then
		return 0
	else 
		return 1
	fi
}
#-------------------------------------------------------------------------------
comprueba_senales() {
#-------------------------------------------------------------------------------
	declare -A senales
	for i in $*; do
		for t in $(grep --text -i 'TAG *=' $i \
					| iconv -f ISO-8859-15 -t UTF-8 \
					| sed "s/^.*TAG *= *[\"']//i;s/['\"].*//" ); do 
			if [ ${senales[$t]}+abc ]; then
				senales[$t]="${senales[$t]} $i"
			else
				senales[$t]="$i"
			fi
		done
	done
	for s in "${!senales[@]}"; do
		if ! existe_en_lista_senales $s; then
			echo "Error. La señal no existe en lista senales. $s: ${senales[$s]}" >&2 
		fi
	done
}
#-------------------------------------------------------------------------------
comprueba_conflictos() {
#-------------------------------------------------------------------------------
	grep --text '>>>>' $*
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
if [ "x$1" = "x-h" ];then
	help
	exit
fi

tabla=$1; shift;

echo "SELECT * FROM $tabla;";

#-------------------------------------------------------------------------------
