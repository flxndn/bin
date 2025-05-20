#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
script_name=$(basename "${BASH_SOURCE[0]}")

segundos=60
#for app in pon_aqui_las_dependencias_y_descomenta; do
	 #which $app >/dev/null || die "$script_name depende de $app, instálela.";
#done
#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $script_name
	* Uso
		> $script_name [-h] [-v] [ -t seconds ] orden

	* Descipción
		Si la orden se encuentra en cache y tiene menos de ''seconds'' de antigüedad se devuelve el resultado de la caché.

		Si no se cumplen los requisitos se ejecuta el comando y se almacena el resultado en cache.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -s, --seconds ''seconds''		:: Segundos de validez de los resultados guardados en caché. :: El valor por defecto es 60.
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

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-s | --seconds) segundos="${2-}"; shift ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

dircache=~/tmp/.bash-cache

[ -d $dircache ] || mkdir -p $dircache

comando="${args[*]}"
filecache=$dircache/$(echo "$comando"| md5sum| cut -f1 -d' ')

if [ -e $filecache ] && [ $(( $(date +%s) - $(date -r $filecache +%s) )) -lt $segundos ]; then
	cat $filecache
else
	eval "$comando" | tee $filecache
fi
