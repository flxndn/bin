#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
cache=~/.elremate_info.cache
url=https://www.elremate.es
id=rotulo

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $(basename "${BASH_SOURCE[0]}") 
	* Uso
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

	* Descipción
		Saca información sobre la subasta en curso de el remate.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -n, --numero		:: Número de subasta en la web.
		- -f, --fecha		:: Fecha de la subasta en la web.
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
	accion='completa'

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-n | --numero) accion='numero' ;; # example flag
		-f | --fecha) accion='fecha' ;; # example flag
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

# script logic here

if [ -z "$(find $(dirname $cache) -maxdepth 1 -name $(basename $cache) -ctime -1)" ]; then
	wget --quiet --no-verbose -O $cache "$url"
fi
linea=$(grep $id $cache | sed "s/<[^>]*>//g;s/^ //;s/  \+/ /g");
case $accion in
	completa) echo $linea;;
	numero)
		echo $linea | cut -f2 -d' ';
	;;
	fecha)
		d=$(echo $linea | cut -f4 -d' ');
		mn=$(echo $linea | cut -f5 -d' ');
		meses=('ENERO' 'FEBRERO' 'MARZO' 'ABRIL' 'MAYO' 'JUNIO' 'JULIO' 'AGOSTO' 'SEPTIEMBRE' 'OCTUBRE' 'NOVIEMBRE' 'DICIEMBRE');
		for i in "${!meses[@]}"; do
			if [[ "${meses[$i]}" = $mn ]]; then
				m=$((i+1))
				break;
			fi
		done
		[ $m -lt 10 ] && m="0$m"
		a=$(echo $linea | cut -f6 -d' ');
		h=$(echo $linea | cut -f7 -d' '|sed "s/h//");
		echo "$a-$m-$d $h";
	;;
	*) die "Acción ($accion) no reconocida."
esac
grep rotulo /tmp/kk.html  | sed "s/.*SUBASTA \(.*\)h<.*/\1/"
