#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
script_name=$(basename "${BASH_SOURCE[0]}")

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $script_name
	* Uso
		> $script_name [-h] [-v] [-f] -p param_value arg1 [arg2...]

	* Descipción
		Utilidades para fechas relacionadas con el año hidrológico.

		La salida es la denominación (año inicia-año final, separados por un guión); fecha de inicio, en formato japonés; fecha final, en el mismo formato. Estos tres campos están separados por tabuladores.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -f, --fecha fecha	:: Fecha para la que se quiere saber el año hidrológico. :: Tiene que ser compatible con gnu date -d . :: Si se omite se usa la fecha actual.
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
	fecha=$(date +"%Y-%m-%d")

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-f | --fecha) 
			fecha="${2-}"
			shift
			;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	return 0
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

ano=$(date -d "$fecha" +"%Y")
if [ $(date -d "$fecha" +"%m") -lt 10 ]; then
	ano=$((ano-1))
fi
anof=$((ano+1))


echo "$ano-$anof	$ano-10-01	$anof-09-30"
