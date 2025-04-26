#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	nombre=$(basename "${BASH_SOURCE[0]}") 
	cat << HELPEND
* $nombre
	* Uso
		> $nombre [opciones] -d ''fichero_descripcion.txt'' img1 [img2 ... imgn]
		> $nombre -h|--help

	* Opciones
		* -h | --help :: Muestra esta ayuda.
		* -d | --descripcion ''fichero_descripcion.txt'' :: Usa la descripción de las imágenes que hay en el 
		* -v | --verbose :: Saca la información de depuración por la salida de error estándar.
		* -a | --autororate :: Rota automticamente las imágenes según la información exif.
		* -n | --dry-run :: Simula el proceso pero sin enviar los archivo.
		* -f | --folder ''carpeta'' :: Subcarpeta donde se guarda en cloudlinary.
	
	* Descripción
		Las imágenes se guardan en cloudinary en el directorio ''carpeta''.

		Como entrada tiene un fichero en el que la primera columna están los 
		nombres de las imágenes y en la segunda columna está la descripción 
		de la imagen.

HELPEND
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
	dryrun=0
	autororate=0
	fichero_descripcion=''
	folder=

	while :; do
		case "${1-}" in
		-h | --help) usage; exit 0 ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-a | --autororate) autororate=1 ;; 
		-f | --folder) folder="${2-}"; shift ;;
		-n | --dry-run) dryrun=1 ;; 
		-d | --descripcion) fichero_descripcion="${2-}"; shift ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ -z "${fichero_descripcion-}" ]] && die "Missing required parameter: fichero_descripcion"
	[[ -z "${folder-}" ]] && die "Missing required parameter: folder"
	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

# script logic here

for img in ${args[@]}; do
	[ $autororate -eq 1 ] && exiftool -q -Orientation= -overwrite_original $img
	#[ $folder = "" ] && folder=$(basename $(dirname $(realpath $img)))
	basename="$(basename $img)"
	titulo="$(grep '^'"$basename"$'\t' "$fichero_descripcion" | cut -f2-)"
	if [ $dryrun -eq 0 ]; then
		cloudinary_upload.sh \
			--folder $folder \
			--public_id "${basename%.*}" \
			--title "$titulo" \
			--miniature \
			"$basename" > "$basename.json";
	else
		echo cloudinary_upload.sh \
			--folder $folder \
			--public_id "${basename%.*}" \
			--title "$titulo" \
			--miniature \
			"$basename";
	fi
done 
