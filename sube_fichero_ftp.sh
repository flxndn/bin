#!/bin/bash

#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	nombre=$(basename $0)
	echo "* $nombre
	* Uso
		> $nombre -h|--help
		> $nombre [-v] -H|--host ftp_server [-d|--directory directory] [-u|--user user] -p|--port port [-a|--password password] file [file2 ... ]
	* Descripción
		Envía uno mo más ficheros al servidor ftp_server.

		Los datos de usuario/clave para el servidor ftp tienen que estar en 
		el fichero de credenciales:
		> \$HOME/.netrc
	* Opciones
		* -v
			Verbose. Muestra qué es lo que hace.
	* Dependencias
		- Usa los credenciales \$HOME/.netrc
		- Usa el programa de envío de ficheros lftp
	* Notas
		Copiado de 
		[[http://www.linuxquestions.org/questions/linux-networking-3/lftp-upload-637376/|lftp upload]].
	* Bugs
		- No funciona para enviar ficheros que contengan espacios.
		- No está implementado el password. Usa el del .netrc.
		- No está implementado el usuario. Usa el del .netrc.
		- No está implementado el puerto. Usa el estándar.
"
}
#-------------------------------------------------------------------------------

verbose=''

while [ "x$1" != "x" ];do
	case "$1" in 
	-h|--help) help; exit 0;;
	-v|--verbose) verbose=1; shift;;
	-H|--host) host=$2; shift;shift;;
	-d|--directory) directory=$2; shift;shift;;
	-u|--user) user=$2; shift;shift;;
	-p|--port) port="-p $2"; shift;shift;;
	-a|--password) password=$2; shift;shift;;
	*) ficheros="$ficheros $1"; shift;;
	esac
done

id=""
if [ "x$user" != "x" ]; then
	id="-u $user";
	if [ "x$password" != "x" ]; then
		id="$id,$password"
	fi
fi

ordenes=$(
if [ $verbose ];then
	echo "debug"
fi

echo "open $port $id $host"

if [ "x$directory" != "x" ]; then 
	echo "cd $directory"
fi

for fichero in $ficheros; do
	echo "put $fichero"
done

echo "quit" 
)

if [ $verbose ];then
	echo "$ordenes"
fi

echo "$ordenes" | /usr/bin/lftp
