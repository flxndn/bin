#!/usr/bin/env bash

set -Eeuo pipefail
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
		> $script_name [-h] [-v] [-f] -p param_value arg1 [arg2...]

	* Descipción
		Script description here.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -s, --lista-senales :: Busca en la tabla lista_senales. :: Es la opción por defecto.
		- -r, --lista-remotas :: Busca en la tabla lista_remotas.
		- -c, --campos		:: Campo buscado. :: El valor de campos por defecto es '*'.
		- -t, --titulos		:: Muestra el título de las columnas.
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
	# default values of variables set from params
	flag=0
	tabla=lista_senales
	campos='*'
	opcion_cabecera=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-s | --lista-senales) tabla=lista_senales;;
		-r | --lista-remotas) tabla=lista_remotas;;
		-t | --tiulos) opcion_cabecera="-c";;
		-c | --campos) campos="${2-}"; shift;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	#[[ -z "${param-}" ]] && die "Missing required parameter: param"
	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

case $tabla in 
	lista_senales) campo_id=ls_tag_txt;;
	lista_remotas) campo_id=lr_codigo_txt;;
esac

echo "SELECT $campos FROM $tabla WHERE $campo_id ='${args[0]}'" \
| isql $opcion_cabecera -b -d$'\t' CHEINTR cheintr cheintr
