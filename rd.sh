#!/bin/bash

readonly ARGS="$@"
readonly PROGNAME=$(basename $0)
readonly CONFFILE=~/.rd.rt

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
cat <<HELP
	* $PROGNAME
		Conexión mediante rdesktop con las conexiones guardadas en el fichero $CONFFILE
		* Uso
			> $PROGNAME [-f|--full] [-g geometry] [-8] [id]
			> $PROGNAME [-f|--full] [-g geometry] [-8] [ -h|--help|-e|--edit|-s|--show ]
		* Opciones
			* id
				Se conecta a la conexión que tiene el identificador id.
			* -h | --help
				Muestra esta ayuda
			* -e | --edit
				Edita el fichero $CONFFILE
			* -s | --show
				Muestra el fichero $CONFFILE
			* -f | --full
				Tamaño a pantalla completa.
			* -g geometry | --geometry geometry
				Usa como tamaño de pantalla el especificado por geometry: wxh
			* -0 
				Se conecta a la consola del ordenador, no como una sesión.
			* -v | --verbose
				Muestra qué es lo que hace.
			* -8 
				Profundidad de color: 8 bits

		* Funcionamiento
			Se conecta con los parámetros que hay en el fichero $CONFFILE a la conexión con el identificador id.

			Si no se especifica conexión aparece un menú con las conexiones disponibles.  
HELP
}
#-------------------------------------------------------------------------------
main(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)			args="${args}-h ";;
			--edit)			args="${args}-e ";;
			--show)			args="${args}-s ";;
			--console)		args="${args}-0 ";;
			--full)			args="${args}-f ";;
			--geometry)		args="${args}-g ";;
			--verbose)		args="${args}-v ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "hfg:0sev8a:" OPTION; do
		case $OPTION in
			h) help; exit;;
			f) readonly GEOMETRY="-f";;
			g) readonly GEOMETRY="-g $OPTARG";;
			0) readonly OPCION_CONSOLA="-0";;
			s) cat $CONFFILE;exit;;
			e) vi $CONFFILE;exit;;
			v) readonly VERBOSE="1";;
			8) readonly COLORES="-a 8";;
			a) readonly COLORES="-a $OPTARG";;
		esac
	done

	shift $(( $OPTIND -1 ))

	if [ -z "$1" ] ; then
		select id in $(cut -f1 $CONFFILE); do
			if [ "x$VERBOSE" = "x1" ]; then
				echo "$PROGNAME $COLORES $GEOMETRY $OPCION_CONSOLA $id" | hexdump -C;
			fi
			$PROGNAME $COLORES $GEOMETRY $OPCION_CONSOLA $id;
			break;
		done
	else
		rdesktop $COLORES $GEOMETRY -x 0x80 $OPCION_CONSOLA $(grep "^$1	" $CONFFILE|cut -f2-) &
	fi 
}
#------------------------------------------------------------------------------- 
#------------------------------------------------------------------------------- 
main $ARGS
