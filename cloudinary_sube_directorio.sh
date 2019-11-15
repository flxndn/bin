#!/bin/bash
if [ "x$1" = "x-h" ]; then
	cat <<HELPEND
* cloudinary_sube_directorio.sh
	* Uso
		> cloudinary_sube_directorio.sh -h
		> cloudinary_sube_directorio.sh ''file.txt'' img1 [img2 ... imgn]
	
	* Descripción
		Las imágenes se guardan en cloudinary en el directorio que tiene el 
		mismo nombre que el directorio en el que se encuentran las imágenes.

		Como entrada tiene un fichero en el que las líneas impares son el 
		nombre de las imágenes y en la segunda línea está la descripción de 
		la imagen.

HELPEND
	exit 0
fi 

fichero_descripcion="$1"; shift;

for img in $*; do
	exiftool -q -Orientation= -overwrite_original $img
	folder=$(basename $(dirname $(realpath $img)))
	basename="$(basename $img)"
	titulo="$(grep '^'"$basename" "$fichero_descripcion" | cut -f2-)"
	cloudinary_upload.sh \
		--folder $folder \
		--public_id "${basename%.*}" \
		--title "$titulo" \
		--miniature \
		"$basename";
done 
