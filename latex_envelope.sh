#!/bin/bash

# Constantes

#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre 
	* Uso
		> $nombre [ -f|--fichero fichero]
		> $nombre -h|--help

	* Descripción
		Añade una cabecera Latex de un artículo a la
		entrada estándar.

		Saca la entrada estándar.

	* Opciones
		* -h 
			Muestra esta ayuda.

		* -f|--fichero fichero
			En lugar de leer la entrada estándar usa el fichero.
		
	* AUTOR
		Félix Anadón Trigo 
HELP

}
#-------------------------------------------------------------------------------
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	help
	exit 0
fi

fichero=""


while [ "$1" ]; do 
	if [ "$1" == "-f" ] || [ "$1" == "--fichero" ]; then
		fichero="$2";
		shift 2;
	fi 
done

cat <<HEAD
\documentclass[a4paper,11pt]{article}
\usepackage[utf8]{inputenc}
% define the title
\title{Sin título}
\author{H.~Partl}
\begin{document}
% generates the title
\maketitle
% insert the table of contents
\tableofcontents
HEAD
cat $fichero
cat <<END
\end{document}
END

