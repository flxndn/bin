#!/bin/bash
### * ,video_utils.sh
###     * Descripción
###         Realiza operaciones simples en videos mediante el programa ffmpeg
###     * Uso
###         > ,video_utils.sh -h
###         > ,video_utils.sh [opciones] comando -i video_entrada [-o fichero_salida]
###     * Opciones
###         - -t ''segundo'' :: Se indica un segundo
###         - -ti ''segundo'' :: Se indica el segundo inicial
###         - -tf ''segundo'' :: Se indica el segundo final
###         - -g ''rectangulo'' :: Márgenes que hay que usar para recortar en formato ''anchura'':''altura'':''x'':''y''
###         - -a ''angulo'' :: Ángulo de rotación. :: El ''angulo'' puedes ser 90, 180 o 270. :: Se utiliza el sentido positivo, el opuesto a las manecillas del reloj.
###     * Comando
###         - crop :: Recorta márgenmes en el vídeo. :: Es necesaria lo opción -g
###         - trim :: Recorta la duración del vídeo. :: Es necesario una o dos de las opciones -ti o -tf :: Si se omite -ti se supone el inicio del vídeo. :: Si se omite -tf se supone el final del vídeo.
###         - foto :: Extrae un fotograma del segundo indicado por la opción -t. :: Si no se indica se usará el fotograma inicial.
###         - info :: Muestra la información del ''video_entrada''. 
###         - rota :: Rota un vídeo.

#-------------------------------------------------------------------------------
ayuda() {
#-------------------------------------------------------------------------------
	sed -rn 's/^### ?//;T;p' "$0"'
}
#-------------------------------------------------------------------------------
function _info() {
#-------------------------------------------------------------------------------
	input=$1
	ffprobe -i $input -show_entries format=duration -v quiet -of csv="p=0"
}
#-------------------------------------------------------------------------------
function _foto() {
#-------------------------------------------------------------------------------
	input="$1"
	t="$2"
	output="$3"
	ffmpeg -i "$input" -ss $t -vframes 1 "$output"
}
#-------------------------------------------------------------------------------
function _crop() {
#-------------------------------------------------------------------------------
	input="$1"
	rectangulo="$2"
	output="$3"
	ffmpeg -i "$input" -filter:v "crop=$rectangulo" "$output"
}
#-------------------------------------------------------------------------------
function _rota() {
#-------------------------------------------------------------------------------
	input="$1"
	angulo="$2"
	output="$3"
	case $angulo in
		'90') filtro="transpose=2";;
		'180') filtro="transpose=2,transpose=2";;
		'270') filtro="transpose=1";;
	esac;
	ffmpeg -i "$input" -vf "$filtro" "$output"
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main 
#-------------------------------------------------------------------------------
if [ "x$1" = "x-h" ] ; then
    ayuda
    exit 0
fi
t=0

while [ ! -z "$1" ] ; do
	if [ "x$1" = "x-i" ] ; then
		input="$2";
		shift; shift;
	elif [ "x$1" = "x-o" ] ; then
		output="$2";
		shift; shift;
	elif [ "x$1" = "x-t" ] ; then
		t="$2";
		shift; shift;
	elif [ "x$1" = "x-g" ] ; then
		rectangulo="$2";
		shift; shift;
	elif [ "x$1" = "x-a" ] ; then
		angulo="$2";
		shift; shift;
	else
		orden="$1";
		shift;
	fi
done

case $orden in 
	'info') 
		_info "$input";;
	'foto') 
		_foto "$input" $t "$output";;
	'crop') 
		_crop "$input" $rectangulo "$output";;
	'rota') 
		_rota "$input" $angulo "$output";;
	'trim') 
		echo "Error. función sin implementar" >&2
		exit 1;;
	*)
		echo "Error. no se ha indicado ninguna orden válida." >&2
		ayuda >&2
		exit 2;;
esac
