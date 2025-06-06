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
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

	* Descipción
		Lee los ficheros json generados al subir las imágenes y las convierte a formato sectxt o yaml.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -s, --sectxt		:: Salida en formato sectxt. :: Es la opción por defecto
		- -y, --yaml		:: Salida en formato yaml.
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
	formato=sectxt

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-s | --sectxt) formato=sectxt ;; # example flag
		-y | --yaml) formato=yaml ;; # example flag
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	#[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

# script logic here

for i in $(find . -name \*.json | grep -v thumb|sort); do 
	t=${i%.json}.thumb.json;  
	cloudinary_get_image_info.py --$formato $i $t; 
done 
