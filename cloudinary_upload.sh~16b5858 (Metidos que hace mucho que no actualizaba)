#!/bin/bash

#-------------------------------------------------------------------------------
function ayuda {
#-------------------------------------------------------------------------------
	cat << HELP
* cloudinary_upload.sh imagen
	Sube una imagen a cloudinary.

	* Uso
		> cloudinary_upload.sh -h
		> cloudinary_upload.sh [-f folder] [-m|--miniature] [-T titulo] [-t tags] -i identificador imagen

	* Opciones
		- -h | --help :: Muestra esta ayuda.
		- -i | --public_id identificador :: Nombre por el que se accederá a esta imagen
		- -t | --tags tags :: Tags asociados a esta imagen. :: Separadas por comas.
		- -T | --title título :: Título de la imagen
		- -d | --description descripcion :: Descripción de la imagen
		- -f | --folder folder :: Carpeta de cloudinary donde se guardará.
		- -m | --miniature :: Crea y sube una miniatura de la imagen.
		- -o | --output_filename output_filename :: Nombre del fichero de salida que se obtiene. :: Si no se especifica el nombre es la fecha actual en formato folder_identificador_yyyy-mm-dd-hh-ii-ss.json

	* Referencias
		- [[https://support.cloudinary.com/hc/en-us/community/posts/360000183051-File-upload-using-curl- File upload using curl]]
HELP

}
#-------------------------------------------------------------------------------
function sendfile {
#-------------------------------------------------------------------------------

	url_image="$1"
	public_id="$2"
	tags="$3"
	context="$4"
	output="$5"

	cloud_name='bibliotranstornado';
	timestamp=$(date +%s)
	api_key='634952764425349';
	api_secret_key='y9w-ytqtCwNscDyE_T48lcqMyKY';
	transformation=''

	plain_signature="context=$context&folder=$FOLDER&public_id=$public_id";
	[ ! -z $tags ] && plain_signature="$plain_signature&tags=$tags";
	plain_signature="$plain_signature&timestamp=$timestamp$api_secret_key";

	signature=$(echo -n $plain_signature| sha1sum| cut -f1 -d' ');
	curl https://api.cloudinary.com/v1_1/$cloud_name/image/upload \
		-X POST \
		-F "file=@$url_image" \
		-F "timestamp=$timestamp" \
		-F "public_id=$public_id" \
		-F "tags=$tags" \
		-F "context=$context" \
		-F "folder=$FOLDER" \
		-F "transformation=" \
		-F "api_key=$api_key" \
		-F "signature=$signature" 
}
#-------------------------------------------------------------------------------
parsearg(){
#------------------------------------------------------------------------------- 
	local arg=

	for arg; do
		local delim=""
		case "$arg" in
			--help)				args="${args}-h ";;
			--public_id)		args="${args}-i ";;
			--tags)				args="${args}-t ";;
			--title)			args="${args}-T ";;
			--folder)			args="${args}-f ";;
			--description)		args="${args}-d ";;
			--miniature)		args="${args}-m ";;
			--output_filename)	args="${args}-o ";;
			*) [[ "${arg:0:1}" == "-" ]]  || delim="\""
				args="${args}${delim}${arg}${delim} ";;
		esac
	done

	eval set --  $args
	while getopts "hi:t:T:f:d:mo:" OPTION; do
		case $OPTION in
			h) ayuda; exit;;
			i) readonly PUBLIC_ID="$OPTARG";;
			t) readonly TAGS="$OPTARG";;
			T) readonly TITLE="$OPTARG";;
			f) readonly FOLDER="$OPTARG";;
			d) readonly DESCRIPTION="$OPTARG";;
			m) readonly MINIATURE=1;;
			o) readonly OUTPUT_FILENAME="$OPTARG";;
		esac
	done 
	shift $(($OPTIND - 1))

	readonly PARAMS=$*
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
parsearg "$@"

url_image="$PARAMS";

if [ ! -e "$url_image" ]; then
	echo "Error al leer la imagen \"$url_image\"" >&2
	ayuda >&2 
	exit 1
fi
if [  -z $PUBLIC_ID ]; then
	echo "Error. No se ha especificado el identificador de la imagen." >&2
	ayuda >&2 
	exit 2
fi 

if [ ! -e "$OUTPUT_FILENAME" ]; then
	readonly OUTPUT_FILENAME="${FOLDER}_${PUBLIC_ID}_$(date +%Y-%m-%d-%H-%M-%S)"
fi

context="alt=$DESCRIPTION|caption=$TITLE"
sendfile "$url_image" "$PUBLIC_ID" "$TAGS" "$context" > "$OUTPUT_FILENAME.json"

if [ ! -z $MINIATURE ]; then
	url_image_miniatura=$(mktemp --suffix=.${url_image##*.})
	convert $url_image -resize 240x240 $url_image_miniatura
	public_id_miniatura=${public_id}_miniatura
	if [ -z "$TAGS" ]; then
		tags_miniatura='miniatura';
	else
		tags_miniatura="$TAGS,miniatura";
	fi

	sendfile "$url_image_miniatura" "$public_id_miniatura" "$tags_miniatura" "$context" > "${OUTPUT_FILENAME}.thumb.json"
fi
