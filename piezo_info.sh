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
		> $script_name [-h] [-v] tag_piezometro [tag2...]

	* Descipción
		Mira en qué directorio hay datos de configuración de los piezómetros que se
		indican como argumentos.

		ESTÁ INCOMPLETO

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

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
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
check(){
#-------------------------------------------------------------------------------
	piezo="$1"
	file="$2"
	rel="$3"
	CEF=/mnt/scada/SAIHEBRO/Wapl/CEF
	echo "#	$file"
	grep -F "$piezo" "$file" || true
	echo "#	$rel"
	grep -F "$piezo" "$CEF/$rel" || true
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
parse_params "$@"
setup_colors

for piezo in "${args[@]}"; do
	echo "#* $piezo"
		d=/home/felix/ute/proyectos/repos/2022-06-piezo_miteco
		f=vega_cotas_y_multiplicativos.csv
		rel=PIEZO_MITECO/ott-vega.rel
		check "$piezo" "$d/$f" "$rel"

		d=/home/felix/ute/proyectos/repos/2023-06-piezo_mtx_vega
		f=mtx.conf
		rel=PIEZO_MTX_VEGA/mtx-vega.rel
		check "$piezo" "$d/$f" "$rel"

		d=/home/felix/ute/proyectos/repos/2024-01-piezo-mtx-ii
		f=doc/PiezosMSenales.txt
		rel=PIEZO_MTX_VEGA/mtxii.rel
		check "$piezo" "$d/$f" "$rel"

		d=/home/felix/ute/proyectos/repos/2024-03-conversion_aca
		f=senales.csv
		rel=ACA_Piezometros/ACA_Piezometros.rel
		check "$piezo" "$d/$f" "$rel"
done
