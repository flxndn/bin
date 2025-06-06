#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

readonly prefijo_defecto="-";
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $(basename "${BASH_SOURCE[0]}") 
	* Uso
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -e elegidos arg1 [arg2...]

	* Descipción
		Script description here.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -e, --elegidos	:: Lista de etiquetas elegidas separadas por comas (sin espacios).
		- -f, --prefijo	''prefijo'' :: Prefijo que se añade a los seleccionados en el listado de fzf. :: Por defecto es ''$prefijo_defecto''.
		- -p, --preview ''comando'' :: Comando que se usará para previsualizar la opción elegida.
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
	elegidos=''
	prefijo=$prefijo_defecto
	opcion_comando=''
	opcion_preview=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-e | --elegidos) # example named parameter
			set -x
			elegidos="${2-}"
			set +x
			shift
			;;
		-f | --prefijo) 
			prefijo="${2-}"
			shift
			;;
		-p | --preview) 
			opcion_comando="--preview"
			opcion_preview='echo {} | sed "s/'$prefijo'//" | '"${2-}"
			shift
			;;
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
IFS=","
elegidos_arr=($elegidos)
opciones=("${args[@]}")
# Me quedo con los argumentos que no estén elegidos
for elegido in ${elegidos_arr[@]}; do
	declare -a tmp=()
	for opcion in ${opciones[@]}; do
		if [ $opcion != $elegido ]; then
			tmp+=($opcion)
		fi
	done
	opciones=("${tmp[@]}")
done
opciones_totales=$( (for i in ${elegidos_arr[@]} ; do echo $prefijo$i; done; for i in ${opciones[@]}; do echo $i; done ) | fzf --multi $opcion_comando $opcion_preview )

declare -a a_eliminar=()
IFS=$'\n'
for fzflegido in $opciones_totales ; do 
	if [[ "$fzflegido" =~ ^$prefijo.* ]]; then
		a_eliminar+=($fzflegido)
	else
		echo $fzflegido
	fi
done
for i in "${elegidos_arr[@]}"; do
	encontrado=''
	for j in "${a_eliminar[@]}";do
		j=$(echo $j | sed "s/^$prefijo//");
		if [ $i == $j ]; then
			encontrado=1;
		fi
	done
	if [ ! "$encontrado" ]; then
		echo $i; 
	fi
done
