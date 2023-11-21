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
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-c fichero_cache -g dir1 [dir2 ... dir_n]
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-c fichero_cache  file1 [file2 ... file_n]

	* Descipción
		Si está activada la opción -g|--generate genera un fichero de destinos para prefijos de archivo.

		Si no está activada mueve al directorio indicado en fichero_cache los ficheros file1 ... según el prefijo de su nombre.

		El prefijo es la parte entre paréntesis de la siguiente expresión regular:
		> ([a-z_])_[0-9].* a 

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -g, --generate	:: Genera el fichero de caché
		- -c, --cache_file	:: Fichero de caché que indica a dónde irán los ficheros.
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
	generate=0
	cache_file="~/.auto_clasifica"

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-g | --generate) generate=1 ;; 
		-c | --cache_file) # example named parameter
			cache_file="${2-}"
			shift
			;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ -d "$cache_file" ]] || mkdir "$cache_file"
	[[ -z "${cache_file-}" ]] && die "Missing required parameter: cache_file"
	[[ ${#args[@]} -eq 0 ]] && die "Es necesario indicar parámetros"

	return 0
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

# script logic here
if [ "$generate" -eq "1" ]; then
	# genera
	for d in "${args[@]}"; do
		[ -d "$d" ] || die "$d no es un directorio"
		for f in $(find $d -maxdepth 1 -type f); do
			basename "$f"
			prefijo=$(basename "$f" | sed "s/^\([a-z_]*\)_[0-9].*/\1/")
			if [ "$prefijo" != "$(basename "$f")" ]; then
				echo "$prefijo	$d" 
			fi
		done
	done | sort | uniq > "$cache_file"
else
	# clasifica
	for f in "${args[@]}"; do
		[ -f "$f" ] || die "$f no es un fichero"
	done
fi

msg "${RED}Read parameters:${NOFORMAT}"
msg "- generate: ${generate}"
msg "- cache_file: ${cache_file}"
msg "- arguments: ${args[*]-}"
