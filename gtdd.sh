#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
script_name=$(basename "${BASH_SOURCE[0]}")
DIR=~/.gtdd

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
		Trabaja con los ficheros de tareas que están en $DIR.

		Por defecto trabaja de forma interactiva.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
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
	param=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-f | --flag) flag=1 ;; # example flag
		-p | --param) param="${2-}"; shift ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments

	return 0
}
#-------------------------------------------------------------------------------
interactivo() {
#-------------------------------------------------------------------------------
	ordenes=("ls - Listado de tareas" "mv - Cambia es estado de las tareas" "ex - Salir")

	while true; do
		orden=$(printf '%s\n' "${ordenes[@]}" | fzf --no-sort| cut -f1 -d' ')

		case $orden in 
		ls)
			dir1=$(find $DIR -maxdepth 1 -mindepth 1 -type d|fzf)
			vi -O $dir1/*.sec
			;;
		mv)
			dir1=$(find $DIR -maxdepth 1 -mindepth 1 -type d|fzf)
			file=$(find $dir1 -maxdepth 1 -mindepth 1 -type f|fzf)
			dir2=$(find $DIR -maxdepth 1 -mindepth 1 -type d|fzf)
			mv "$file" "$dir2"
			;;
		ex)
			exit 0
			;;
		*) die "Orden $orden no reconocida.";
			;;
		esac
	done
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

interactivo
