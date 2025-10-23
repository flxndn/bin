#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $(basename "${BASH_SOURCE[0]}") 
	* Uso
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-j|--formato-japonés|-e|--fecha-europeo] [fecha1] [fecha2...]

	* Descipción
		Devuelve el quinceminutal cercano a las fechas indicadas.

		Las fechas tienen que estar en un formato entendible por el comando ''date''.

		Si no se especifica ninguna fecha usa la actual.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -j, --formato-japones :: Saca las fechas en formato japonés (YYYY-MM-DD HH:mm:ss). :: Es la opción por defecto.
		- -e, --formato-europeo :: Saca las fechas en formato europeo (DD/MM/YYYY HH:mm:ss). :: Es la opción por defecto.
		- -c, --cercano :: Obtiene el quinceminital más cercano, tanto por exceso como por defecto. :: Es la opción por defecto.
		- -i, --inferior :: Obtiene el quinceminital menor o igual a la fecha indicada.
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
	echo >&2 -e "${1-}"
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
	formato="%d/%m/%Y %H:%M:%S";
	metodo='cercano'

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-j | --formato-japones) formato="%Y-%m-%d %H:%M:%S";;
		-e | --formato-europeo) formato="%d/%m/%Y %H:%M:%S";;
		-c | --cercano) metodo="cercano";;
		-i | --inferior) metodo="inferior";;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ ${#args[@]} -eq 0 ]] && args+="$(date +"%Y-%m-%d %H:%M:%S")"

	return 0
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

IFS=$'\n'
for d in "${args[@]}"; do
	seconds=$(date -d "$d" +%s)
	if [ $metodo = 'cercano' ]; then delta=450; fi # 900 segundos / 2
	if [ $metodo = 'inferior' ]; then delta=0; fi
	secondsqm=$(( 900 *((seconds + delta) / 900) ))
	date -d @$secondsqm +"$formato"
done
