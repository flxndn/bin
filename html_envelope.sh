#!/bin/bash

# Constantes

#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre 
	* Uso
		> $nombre [-t|--title title] [-c|--charset charset] [ -f|--fichero fichero]
		> $nombre -h|--help

	* Descripción
		Añade una cabecera html, un head y un body antes del texto que entra 
		por entrada estándar.

		Saca la entrada estándar.

		Fin de body y html después.

	* Opciones
		* -h 
			Muestra esta ayuda.

		* -t|--[titulo|title] titulo
			Pone como título en el head titulo.

		* -c|--charset charset
			Indica en la cabecera el charset. 
			
			Por defecto UTF-8.

			Es muy común el 'iso-8859-15'

		* -f|--fichero fichero
			En lugar de leer la entrada estándar usa el fichero.
		
		* -s|--css url_fichero_css
			Añade un css con url url_fichero_css

		* -S|--CSS fichero_css
			Añade un css dentro de una etiqueta style

		* -i|--interactive 
			Añade un script para que documento sea navegable interactivamente.

	* AUTOR
		Félix Anadón Trigo 
HELP

}
#-------------------------------------------------------------------------------
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	help
	exit 0
fi

charset="UTF-8"
title="sin título"
fichero=""

css=""
headscript=""
documentreadyscript=''

while [ "$1" ]; do
	if [ "$1" == "-t" ] || [ "$1" == "--titulo" ] || [ "$1" == "--title" ]; then
		title="$2";
		shift 2;
	fi

	if [ "$1" == "-c" ] || [ "$1" == "--charset" ]; then
		charset="$2";
		shift 2;
	fi

	if [ "$1" == "-f" ] || [ "$1" == "--fichero" ]; then
		fichero="$2";
		shift 2;
	fi

	if [ "$1" == "-s" ] || [ "$1" == "--css" ]; then
		css="$css<link rel=\"stylesheet\" href=\"$2\" type=\"text/css\" />"
		shift 2;
	fi

	if [ "$1" == "-i" ] || [ "$1" == "--interactive" ]; then
		headscript="<script src=\"http://code.jquery.com/jquery-1.11.0.min.js\"></script>"
		documentreadyscript=' 
			<script type="text/javascript">
				$(document).ready(function() {
					$(":header").click(function() {
						$(this).parent().children(".subsections").toggle()
					});
					//$(".subsections").hide();
				});
			</script>'
		shift;
	fi

	if [ "$1" == "-S" ] || [ "$1" == "--CSS" ]; then
		css="$css
		<style>
		$(cat $2)
		</style>
		"
		shift 2;
	fi
done

cat <<HEAD
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>$title</title>
		$headscript
		<meta http-equiv="Content-Type" content="text/html; charset=$charset" />
		$css
	</head>
	<body>
HEAD
cat $fichero
cat <<END
	</body>
	$documentreadyscript
</html>
END

