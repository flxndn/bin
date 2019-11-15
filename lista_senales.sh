#!/bin/bash

readonly db=CHE
readonly db_user=chesys
readonly db_password=chesys
readonly table=LISTA_SENALES
readonly id_field=LS_TAG

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
	* $PROGNAME
		Lista las señales de $db/$table con el $id_field indicado como parámetro.
		* Uso
			> $PROGNAME [-f campos ] id [id2 ... id_n]
			> $PROGNAME [ -h ]
		* Opciones
			* -h 
				Muestra esta ayuda
			* -f  fields
				Lista de campos que se van a mostrar.

				Si no se especifica se muestran todos.  
HELP
}
#-------------------------------------------------------------------------------
main(){
#------------------------------------------------------------------------------- 
	campos="*"

	if [ "x$1" = "x-h" ]; then
		help
		exit 0
	fi
	if [ "x$1" = "x-f" ]; then
		campos=$2
		shift;shift;
	fi
	ids=$(echo "$*" | sed "s/ /,/g")

	echo "select $campos from $table where $id_field in ($ids)"

	echo "select $campos from $table where $id_field in ($ids)" \
	| isql -v -b -d$'\t' -c $db $db_user $db_password
}
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
main $*
