#!/usr/bin/env bash
# https://betterdev.blog/minimal-safe-bash-script-template/

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
  cat <<EOF
* $(basename "${BASH_SOURCE[0]}")
	* Uso
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-s] [-m] time

	* Descripción
		Realiza una cuentaatrás desde time hasta cero.

	* Opciones
		- -h, --help	:: Print this help and exit
		- -v, --verbose	:: Print script debug info
		- -v, --verbose	:: Print script debug info
		- -t, --text	:: Saca el resultado como texto. :: Es la opción por defecto.
		- -g, --gauge	:: Saca el resultado con dialog guge.
		- -m, --minutes	:: El tiempo se expresa en minutos. :: Es la opción por defecto.
		- -s, --seconds	:: El tiempo se expresa en segundos.
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
  units=minutes
  unitsa=m
  method=text
  notify=0
  titulo=Timer

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -m | --minutes) units=minutes; unitsa=m ;;
    -s | --seconds) units=seconds unitsa=s;;
    -g | --gauge) method=gauge ;;
    -t | --text) method=text ;;
    -n | --notify) notify=1 ;;
    -u | --titulo) titulo="${2-}"; shift;;
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
#-------------------------------------------------------------------------------

parse_params "$@"
setup_colors

total=${args[0]}
for i in $(seq $total -1 0); do 
	if [ $method = 'text' ]; then
		echo -n "$i	$units";
		date
	else
		# dialog gauge
		percentage=$((100-i*100/total))
		echo $percentage | dialog --title "$titulo" --gauge "Please wait $i $units" 10 60 0
		#echo $percentage | dialog --title "$titulo" --gauge "Please wait $i $units" 10 60 0
	fi
	sleep 1$unitsa
done

if [ "$notify" = "1" ] ; then
	notify-send timer.sh "Tiempo cumplido: $titulo $total $units"
fi
