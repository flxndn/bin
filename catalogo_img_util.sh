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
		> $(basename "${BASH_SOURCE[0]}") [-h] [-v] orden [''fichero de campos imagen'']

	* Descipción
		Alimentado con las líneas de las imágnes del catálogo de libros 
		realiza a acciones con esos campos dependiendo de la orden elegida

		El resultado sale por salida estándar.
	* Opciones
		- -h, --help		:: Print this help and exit
		- -v, --verbose		:: Print script debug info
        - --lugar           :: Lugar al que se sube. :: Por defecto es cloudinary. :: Es la única opción válida por ahora.

	* Órdenes
		- -t, --textos		:: Muestra la imagen con qiv y pide interactivamente un título y texto.
		- -q, --visualizador		:: Envía las imágenes del campo ''local'' a un visualizador de imágenes. :: Por defecto es ''qiv''
		- -l, --ls-locales		:: Saca por pantalla los archivos locales. :: No vuelve a generar la salidad estándar.
        - -u, --upload ''carpeta''      :: Sube la imagen al lugar indicado por la opción --lugar.
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
	orden='textos'
    lugar_subida="cloudinary"
    carpeta=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
        --lugar) lugar_subida="${2-}"; shift;;
		--no-color) NO_COLOR=1 ;;
		-t | --textos) orden="textos" ;;
		-q | --visualizador) orden="visualizador" ;;
		-l | --ls-locales) orden="ls_locales" ;;
        -u | --upload) orden="upload"; carpeta="${2-}"; shift ;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	#[[ -z "${param-}" ]] && die "Missing required parameter: param"
	#[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}
#-------------------------------------------------------------------------------
saca() {
#-------------------------------------------------------------------------------
	titulo="$1"
	texto="$2"
	mini="$3"
	maxi="$4"
	local="$5"

	echo "          - título: $titulo"
	echo "            texto: $texto"
	echo "            mini: $mini"
	echo "            maxi: $maxi"
	echo "            local: $local"
}
#-------------------------------------------------------------------------------
mete_textos() {
#-------------------------------------------------------------------------------
	titulo="$1"
	texto="$2"
	mini="$3"
	maxi="$4"
	local="$5"

	qiv -mf "$local"
	read -p "título? [$titulo]: " input </dev/tty
	titulo=${input:-$titulo}
	read -p "texto? [$texto]: " input </dev/tty
	texto=${input:-$texto}
}
#-------------------------------------------------------------------------------
ver_locales() {
#-------------------------------------------------------------------------------
	titulo="$1"
	texto="$2"
	mini="$3"
	maxi="$4"
	local="$5"

    qiv -mf "$local"
}
#-------------------------------------------------------------------------------
ls_locales() {
#-------------------------------------------------------------------------------
	titulo="$1"
	texto="$2"
	mini="$3"
	maxi="$4"
	local="$5"

    echo "$local"
}
#-------------------------------------------------------------------------------
upload() {
#-------------------------------------------------------------------------------
	titulo="$1"
	texto="$2"
	mini="$3"
	maxi="$4"
	local="$5"

    basename=$(basename "$local")

    case $lugar_subida in 
    cloudinary)
        cloudinary_upload.sh \
        --folder "$carpeta" \
        --public_id "${basename%.jpg}" \
        --title "$titulo" \
        --description "$texto" \
        --miniature \
        $local \
        | tee /tmp/debug$(date +%s).json \
        | cloudinary_get_image_info.py
    echo "            local: $local"

    ;;
    *) die "Lugar de subida \"$lugar_subida\" no reconocido."
    ;;
    esac

}
#-------------------------------------------------------------------------------
procesa() {
#-------------------------------------------------------------------------------
    standar=1
	case $orden in 
		textos) mete_textos "$1" "$2" "$3" "$4" "$5" ;;
		visualizador) ver_locales "$1" "$2" "$3" "$4" "$5";;
		ls_locales) ls_locales "$1" "$2" "$3" "$4" "$5"; standar=0;;
		upload) upload "$1" "$2" "$3" "$4" "$5"; standar=0;;
		*) die "órden $orden no reconocida";;
	esac
	[ $standar -eq 1 ] && saca "$1" "$2" "$3" "$4" "$5" || true
}
#-------------------------------------------------------------------------------
#------------------------------------------------------------------------------- 
parse_params "$@"
setup_colors

primero=1
IFS=$'\n';
for i in $( [ ${#args[@]} -eq 0 ] && cat || cat "${args[@]}" ); do 
	i=${i#          [- ] }
	key=$(echo "$i" | cut -f1 -d:)
	value=$(echo "$i" | cut -f2- -d:|sed "s/^ *//")
	case "$key" in
		título) 
			if [ -z $primero ]; then
				procesa "$titulo" "$texto" "$mini" "$maxi" "$local"
			fi
			primero=''
			titulo=$value ;;
		texto) texto=$value ;;
		mini) mini=$value ;;
		maxi) maxi=$value ;;
		local) local=$value ;;
		*)
	esac
done
# procesar el último
if [ -z $primero ]; then
	procesa "$titulo" "$texto" "$mini" "$maxi" "$local"
fi
