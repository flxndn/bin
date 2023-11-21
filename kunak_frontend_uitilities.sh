#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
basename=$(basename "${BASH_SOURCE[0]}") 
ksdf=~/.kunak_selected_device
ksef=~/.kunak_selected_element
ktagsf=~/.kunak_tags

#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
	cat <<EOF
* $basename
	* Uso
		> $basename [-h] [-v] [-f] [ -e element ] [ -d device ] orden

	* Descipción
		Script description here.

	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
		- -D, --dry-run		:: No ejecuta las sentencias sql, solo las saca por salida estándar.
		- -d, --device ''device'' :: Indica el device_serial_number del dispositivo.
		- -e, --element ''id'' :: Indica el identificador ''id'' del elemento.
	
	* Órdenes
		- lsd | ls_devices		:: Saca un listado de todos los ''devices
		- lse | ls_elements		:: Saca un listado de los ''elements'' del ''device'' seleccionado
		- lstd | ls_traspasos_device	:: Saca un listado de los traspasos asociados a un ''device''
		- lste | ls_traspasos_element	:: Saca un listado de los traspasos asociados a un ''device'' y a un ''element''.
		- v | valores :: Saca los últimos valores leídos
		- i | info_selected				:: Saca la información de los elementos seleccionados (en los ficheros $ksdf y $ksef), así como sus traspasos asociados.
		- u | unselect					:: Borra los ficheros de selección de ''device'' y ''element''.
		- sd | select_device			:: Selecciona interactivamente un dispositivo de entre todos los que hay en la base de datos. :: Lo guarda en el fichero $ksdf.
		- se | select_element			::  Selecciona interactivamente un elemento del dispositivo elegidoe. :: Lo guarda en el fichero $ksef.

	* Ficheros 
		-  fichero de device :: $ksdf
		-  fichero de element :: $ksef
EOF
	exit
}
#------------------------------------------------------------------------------- 
# SQL comu
# UPDATE `kunak_on_premises`.`device` SET `remota_tag` = 'A373', `comm_tag_saih` = 'A373KD01COMU', `prefijo` = 'Kunak' WHERE (`serial_number` = '0523240017');
# sql senales
# INSERT INTO `kunak_on_premises`.`traspasos` (`device_serial_number`, `element_id`, `traspasar`, `tag_saih`, `date`, `prefijo`, `tipo`, `periodo`) VALUES ('523240017', 'nivel rio', '1', 'A373K01NRIO1', '2023-07-12 12:59:20', 'Kunak', 'A', '15');
# INSERT INTO `kunak_on_premises`.`traspasos` (`device_serial_number`, `element_id`, `traspasar`, `tag_saih`, `date`, `prefijo`, `tipo`, `periodo`) VALUES ('523240017', 'Battery', '1', 'A373K02VOLTI', '2023-07-12 12:59:20', 'Kunak', 'A', '15');
# INSERT INTO `kunak_on_premises`.`traspasos` (`device_serial_number`, `element_id`, `traspasar`, `tag_saih`, `date`, `prefijo`, `tipo`, `periodo`) VALUES ('523240017', 'Temp', '1', 'A373K03TEMPI', '2023-07-12 12:59:20', 'Kunak', 'A', '15');
# INSERT INTO `kunak_on_premises`.`traspasos` (`device_serial_number`, `element_id`, `traspasar`, `tag_saih`, `date`, `prefijo`, `tipo`, `tipo_calculo`, `tag_saih_calculado`, `periodo`) VALUES ('523240017', 'PLUVIO 01', '1', 'A373K61PCINC', '2023-07-12 12:59:20', 'Kunak', 'A', 'cinc_a_quin', 'A373K85PQUIN', '5');


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
	device=''
	element=''
	dryrun=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-D | --dry-run) dryrun=1;;
		-d | --device) device="${2-}"; shift ;;
		-e | --element) element="${2-}"; shift ;;
		-S | --selected) 
			[ -e $ksdf ] && device=$(cut -f1 $ksdf);
			[ -e $ksef ] && element=$(cut -f2 $ksef);
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
executesql() {
#-------------------------------------------------------------------------------
	sql="$1"
	if [ -z $dryrun ]; then
		echo "$sql" | mysql --login-path=Kunak --batch kunak_on_premises
	else
		echo "$sql";
	fi
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

# script logic here
for orden in "${args[@]}"; do
	case "$orden" in
		lsd|ls_devices) 
			where='';
			[ -z $device ] || where="WHERE serial_number=$device"
			sql="SELECT * from device $where order by registration_date DESC";
			executesql "$sql"
			;;
		lse|ls_elements) 
			where='';
			[ -z $device ] || where="WHERE device_serial_number=$device"
			sql="SELECT * from element $where";
			executesql "$sql"
			;;
		lstd|ls_traspasos_device)
			sql="SELECT * FROM traspasos where device_serial_number='$device'";
			executesql "$sql"
			;;
		lste|ls_traspasos_element)
			sql="SELECT * FROM traspasos where device_serial_number='$device' AND element_id='$element'";
			executesql "$sql"
			;;
		v|valores)
			sql="SELECT * from \`read\` where device_serial_number='$device' and element_id='$element' order by date desc limit 10";
			executesql "$sql"
			;;
		i|info_selected)
			for i in $ksdf $ksef $ktagsf; do
				[ -e $i ] && (echo === $i ===; cat $i) || echo "No esiste $i";
			done
			for i in ls_traspasos_device ls_traspasos_element valores; do
				echo "=== $i ===";
				$basename --selected $i
			done
			;;
		u|unselect)
			for i in $ksdf $ksef; do
				[ -e $i ] && rm -f $i; 
			done
			;;
		sd|select_device)
			$basename ls_devices | fzf > $ksdf
			;;
		se|select_element)
			$basename --selected ls_elements | fzf > $ksef
			;;
		et| edit_tags) 
			vi $ktagsf; 
			;;
		it|insert_traspaso)
			tag=$(cat $ktagsf| fzf);
			fecha=$(d=$(date +"%Y-%m-%d");for i in $(seq 10); do d=$(date +"%Y-%m-%d" -d "$d -1 days"); echo "$d 00:00:00"; done | fzf); 
			tipo=$( (echo A; echo D) | fzf);
			sql="INSERT INTO traspasos (device_serial_number, element_id, traspasar, tag_saih, date, prefijo, tipo) VALUES ('$device', '$element', 1, '$tag', '$fecha', 'Kunak', '$tipo')";
			executesql "$sql"
			;;
		*) echo "Orden ($orden) desconocida" >&2; exit 2;;
	esac;
done

