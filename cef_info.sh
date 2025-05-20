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
		- -f, --fichero fichero.dat		:: Fichero dónde están los datos
		- -t, --tag	tagsaih	:: Tag de la señal a examinar.
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
	tag=''
	fichero=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-f | --fichero) fichero="${2-}"; shift ;;
		-t | --tag) tag="${2-}"; shift ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ -z "${fichero-}" ]] && die "Missing required parameter: fichero"
	[[ -z "${tag-}" ]] && tag=$(cat $fichero | cut -f2 -d\; | sort | uniq -c | fzf| cut -c9-)
	[[ -z "${tag-}" ]] && die "Missing required parameter: tag"
	#[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
informe() {
#-------------------------------------------------------------------------------
	t=$1
	grep $t cef_aca_piezometros/ACA_Piezometros.rel || echo "Error. $t no está en el directorio rel"
	grep $t $fichero| cut -f4 -d\; | youplot line 2>&1 
	grep $t $fichero| cut -f3,4 -d\; 
}
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

# script logic here
if [ $tag = "0" ]; then
	for t in $(cat $fichero | cut -f2 -d\; | sort| uniq); do
		echo "# tag=$t"
		informe $t
	done
else
	informe $tag
fi

