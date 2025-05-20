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
		> $script_name [-h] [-v] [parametros] ORDEN

	* Descipción
		Utilidades para tratar ficheros CEF.

	* ORDEN
		- i, insert :: Inserta una línea en el fichero CEF. :: Son obligatorias las opciones -T, -V, [-f|-F]
		- n, nombre :: Devuelve el nombre de un fichero CEF basado en el prefijo y la fecha.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -p, --prefijo		:: Prefijo del fichero CEF. :: Lo ficheros generados tienen el prefijo + _ + fecha + .txt
		- -d, --directorio	:: Directorio del fichero CEF
		- -f, --fecha		:: Fecha de la medida. :: Tiene que venir en un formato compatible con el comando date.
		- -F, --fecha-europea		:: Fecha dei la medida. :: Formato dd/mm/AAAATHH:MM:SS :: La T puede ser un espacio.
		- -t, --tipo		:: Tipo de la señal. :: Puede ser A o D (analógica o digital) :: Por defecto es A
		- -T, --tag			:: Tag de la señal.
		- -V, --valor		:: Valor de la señal.
		- --h2q				:: Horario a quinceminuta, inserta el valor de la fecha y los tres quiceminutales siguientes. :: Para cuando se dan valores horarios y hay que convertir a quinceminutal.
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
	prefijo=''
	directorio='.'
	fecha=''
	tipo='A'
	tag=''
	valor=''
	h2q=0

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-p | --prefijo) prefijo="${2-}"; shift ;;
		-d | --directorio) directorio="${2-}"; shift ;;
		-f | --fecha) fecha="${2-}"; shift ;;
		-F | --fecha-europea) 
			f="${2-}"; 
			f=$(echo $f | sed "s/[\/T\-]/ /g");
			d=$(echo $f| cut -f1 -d' ');
			m=$(echo $f| cut -f2 -d' ');
			a=$(echo $f| cut -f3 -d' ');
			t=$(echo $f| cut -f4 -d' ');
			fecha="$a-$m-$d $t";
			shift ;;
		-t | --tipo) tipo="${2-}"; shift ;;
		-T | --tag) tag="${2-}"; shift ;;
		-V | --valor) valor="${2-}"; shift ;;
		--h2q) h2q=1 ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")
	[[ ${#args[@]} -eq 0 ]] && die "Missing script ordenes"
	orden=${args[0]}

	# check required params and arguments
	case $orden in
		i|insert)
			[[ -z "${prefijo-}" ]] && die "Missing required parameter: prefijo"
			[[ -z "${fecha-}" ]] && die "Missing required parameter: fecha"
			[[ -z "${tag-}" ]] && die "Missing required parameter: tag"
			[[ -z "${valor-}" ]] && die "Missing required parameter: valor" :: Si tiene punto decimal se convertirá en coma.
		;;
		n|nombre)
			[[ -z "${prefijo-}" ]] && die "Missing required parameter: prefijo"
			[[ -z "${fecha-}" ]] && die "Missing required parameter: fecha"
		;;
		*) die "Órden $orden no reconocida."
		;;
	esac

	return 0
}
#-------------------------------------------------------------------------------
f_nombre() {
#-------------------------------------------------------------------------------
	fecha_iso=$(date -d "$fecha" +"%Y%m%d")
	echo "$directorio/${prefijo}_$fecha_iso.txt"
}
#-------------------------------------------------------------------------------
f_insert() {
#-------------------------------------------------------------------------------
	dirlog=~/var/log/cef
	[ -d $dirlog ] || mkdir -p $dirlog || die "No puedo crear el directorio $dirlog"
	dia_iso=$(date -d "$fecha" +"%Y-%m-%d")
	fichero_log=$dirlog/$dia_iso.txt

	fichero=$(f_nombre)
	fecha_europea=$(date -d "$fecha" +"%d/%m/%Y %H:%M:%S")
	if [ "${valor:0:1}" = "." ]; then valor="0$valor"; fi
	valor_con_coma=$(echo $valor | sed "s/\./,/")
	echo "$tipo;$tag;$fecha_europea;$valor_con_coma;BUENA" >> "$fichero"
	if [ $h2q -eq 1 ]; then
		for i in 1 2 3; do
			fecha=$(date -d "$fecha 15 minutes" --iso-8601=seconds)
			fecha_europea=$(date -d "$fecha" +"%d/%m/%Y %H:%M:%S")
			echo "$tipo;$tag;$fecha_europea;$valor_con_coma;BUENA" >> "$fichero"
			echo "$prefijo;$tipo;$tag;$fecha_europea;$valor_con_coma;BUENA" >> "$fichero_log"
		done
	fi
	unix2dos "$fichero" 2>/dev/null
}
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

for app in unix2dos; do
	 which $app >/dev/null || die "$script_name depende de $app, instálela.";
done
# script logic here
	case $orden in
		i|insert)
			f_insert
		;;
		n|nombre)
			f_nombre
		;;
		*) die "Órden $orden no reconocida."
		;;
	esac
