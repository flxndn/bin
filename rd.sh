#!/usr/bin/env bash

set -Eeuo pipefail
#[[http://redsymbol.net/articles/unofficial-bash-strict-mode/ Use Bash Strict Mode]]
IFS=$'\n\t'

trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
script_name=$(basename "${BASH_SOURCE[0]}")

#for app in pon_aqui_las_dependencias_y_descomenta; do
	 #which $app >/dev/null || die "$script_name depende de $app, instálela.";
#done
#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $script_name
	* Uso
		> $PROGNAME [-f|--full] [-g geometry] [-8] [id]
		> $PROGNAME [-f|--full] [-g geometry] [-8] [ -h|--help|-e|--edit|-s|--show ]

	* Descipción
		Se conecta con los parámetros que hay en el fichero $CONFFILE a la conexión con el identificador id.

		Si no se especifica conexión aparece un menú con las conexiones disponibles.  

		''id'' es el identificador de la conexión.

	* Opciones
		* -h | --help :: Muestra esta ayuda
		* -e | --edit	:: Edita el fichero $CONFFILE
		* -s | --show	:: Muestra el fichero $CONFFILE
		* -f | --full :: Tamaño a pantalla completa.
		* -g geometry | --geometry geometry :: Usa como tamaño de pantalla el especificado por geometry: wxh
		* -0 :: Se conecta a la consola del ordenador, no como una sesión.
		* -v | --verbose :: Muestra qué es lo que hace.
		* -8 :: Profundidad de color: 8 bits
EOF
	exit
}
#-------------------------------------------------------------------------------
cleanup() {
#-------------------------------------------------------------------------------
	trap - SIGINT SIGTERM ERR EXIT
	# script cleanup here
}
#-------------------------------------------------------------------------------
setup_colors() {
#-------------------------------------------------------------------------------
	if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
		NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
	else
		NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
	fi
}
#-------------------------------------------------------------------------------
msg() {
#-------------------------------------------------------------------------------
	echo >&2 -e "$script_name. ${1-}"
}
#-------------------------------------------------------------------------------
die() {
#-------------------------------------------------------------------------------
	local msg=$1
	local code=${2-1} # default exit status 1
	msg "$msg"
	exit "$code"
}
#-------------------------------------------------------------------------------
parse_params() {
#-------------------------------------------------------------------------------
	NO_COLOR=0
	GEOMETRY=''
	OPCION_CONSOLA=''
	COLORES=''
	readonly CONFFILE=~/.rd.rt
	# default values of variables set from params
	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-g | --geometry) GEOMETRY=1 ;;
		-f | --full) GEOMETRY="-g ${2-}"; shift ;;
		-0 ) OPCION_CONSOLA="-0";;
		-8 ) COLORES="-a 8";;
		-a ) COLORES="-a ${2-}"; shift;;
		-e ) vi $CONFFILE; exit ;;
		-s ) cat $CONFFILE; exit ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	return 0
}
#-------------------------------------------------------------------------------
main(){
#------------------------------------------------------------------------------- 
<<<<<<< HEAD
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
		id=$(cut -f1 $CONFFILE| grep -v '^#' | fzf)
		[ -n "$id" ] && $PROGNAME $COLORES $GEOMETRY $OPCION_CONSOLA $id
		#select id in $(cut -f1 $CONFFILE); do
			#if [ "x$VERBOSE" = "x1" ]; then
				#echo "$PROGNAME $COLORES $GEOMETRY $OPCION_CONSOLA $id" | hexdump -C;
			#fi
			#$PROGNAME $COLORES $GEOMETRY $OPCION_CONSOLA $id;
			#break;
		#done
	else
		rdesktop $COLORES $GEOMETRY -x 0x80 $OPCION_CONSOLA $(grep "^$1	" $CONFFILE|cut -f2-)
	fi 
=======
	if [ ${#args[@]} -eq 0 ] ; then
		id=$(cut -f1 $CONFFILE| grep -v '^#' | fzf)
	else
		id=${args[0]}
	fi
	declare -a opcioneshost=($(grep "^$id	" $CONFFILE|cut -f2))
	rdesktop $COLORES $GEOMETRY -x 0x80 $OPCION_CONSOLA "${opcioneshost[@]}" $id
>>>>>>> 1ac9f5794680a676afa1ac3e3612fe34af00ce2b
}
#------------------------------------------------------------------------------- 
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

# script logic here

main 
