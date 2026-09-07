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
		> $script_name [-h] [-v] [-r] [ -d directorio] fichero1 [fichero2 ...]

	* Descipción
		Realiza una copia backup del fichero o ficheros seleccionados.

		Con la opción -r realiza un restore de la última copia existente..

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -d | --directory directorio :: Directorio en el que se hacen las copias de seguridad. :: Por defecto es el directorio actual.
		- -r, --restore		:: Restaura la última copia realizada.
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
	directorio=$(pwd)
	orden=backup

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-r | --restore) orden=restore ;;
		-d | --directory) # example named parameter
			directorio="${2-}"
			shift
			;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
nombre_backup() {
#-------------------------------------------------------------------------------
	nombre="$1"
	numero=$2

	echo "$directorio/.$nombre.$numero.back"
}
#-------------------------------------------------------------------------------
ultima_backup(){
#-------------------------------------------------------------------------------
	fichero="$1"
	dir=$(dirname "$fichero")
	nombre=$(basename "$fichero")
	find "$dir" -maxdepth 1 -name .$nombre.\*.back -printf "%T@\t%p\n" \
	| sort -rn | cut -f2 | head -n1 
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

# script logic here
for f in "${args[@]}"; do
	dir=$(dirname "$f")
	nombre=$(basename "$f")
	case $orden in
		backup)
			if ! cmp --silent "$f" "$(ultima_backup "$f")"; then
				cp "$f" "$dir/.$nombre.$(date +%s).back"
			fi
		;;
		restore)
			copia=$(ultima_backup "$f")
			if [ -e "$copia" ]; then
				mv "$copia" "$f"
			else
				die "No hay copia guardada de $f."
			fi
		;;
		*) die "Órden \"$orden\" no encontrada.";;
	esac
done

