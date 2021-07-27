#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<HELPEND
	nombre=$(basename "${BASH_SOURCE[0]}") 
* $nombre
	* Uso
		> * $nombre -h
		> $nombre ''file.txt'' img1 [img2 ... imgn]
	
	* Descripción
		Las imágenes se guardan en cloudinary en el directorio que tiene el 
		mismo nombre que el directorio en el que se encuentran las imágenes.

		Como entrada tiene un fichero en el que las líneas impares son el 
		nombre de las imágenes y en la segunda línea está la descripción de 
		la imagen.

HELPEND
	exit 0
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
	flag=0
	param=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-f | --flag) flag=1 ;; # example flag
		-p | --param) # example named parameter
			param="${2-}"
			shift
			;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ -z "${param-}" ]] && die "Missing required parameter: param"
	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

# script logic here

fichero_descripcion="$1"; shift;

for img in $*; do
	exiftool -q -Orientation= -overwrite_original $img
	folder=$(basename $(dirname $(realpath $img)))
	basename="$(basename $img)"
	titulo="$(grep '^'"$basename" "$fichero_descripcion" | cut -f2-)"
	cloudinary_upload.sh \
		--folder $folder \
		--public_id "${basename%.*}" \
		--title "$titulo" \
		--miniature \
		"$basename";
done 
