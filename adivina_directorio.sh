#!/usr/bin/env bash
# https://betterdev.blog/minimal-safe-bash-script-template/

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
dir='.'
caracteres=12
#-------------------------------------------------------------------------------
usage() {
#-------------------------------------------------------------------------------
  cat <<EOF
* $(basename "${BASH_SOURCE[0]}")
	* Uso
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

	* Descripción
		Script description here.

	* Opciones
		- -h, --help      :: Print this help and exit
		- -v, --verbose   :: Print script debug info
		- -d, --dir ''directorio''    :: Directorio base en el que se empieza a buscar.
		- -c, --caracteres ''numero_de_caracteres''    :: Número de letras que se van a utilizar. :: Por defecto es $caracteres. :: Si es cero se usa la cadena entera.
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
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -d | --dir) dir="${2-}"; shift ;;
    -c | --caracteres) caracteres="${2-}"; shift ;;
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

# script logic here
digest="$dir/.adivinar_directorio.digest"

[ -e "$digest" ] || find "$dir" -type f > $digest

if [ "$caracteres" = 0 ] ; then
	aguja="${args[0]}"
else
	aguja=$(echo "${args[0]}"|cut -c-$caracteres)
fi

grep "$aguja" "$digest" | xargs dirname | uniq -c | sort -nr
