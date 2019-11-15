#!/bin/bash
home=$HOME
base=dotfiles

cd $home

#-------------------------------------------------------------------------------
function help {
#-------------------------------------------------------------------------------
	echo "* dotfiles.sh
	Se usa para manejar los ficheros guardados en el directorio dotfiles.sh.
	* Opciones
		* -h
			Muestra esta ayuda.
		* -c
			Comprueba el estado de los ficheros.
		* -u
			Update. 
			- Actualiza los directorios
			- Los ficheros existentes los renombra a .old.
			- Crea los enlaces.
"
}
#-------------------------------------------------------------------------------
function dotfiles {
#-------------------------------------------------------------------------------
	for f in $(find $base -type f -o -type l | grep -v svn);do 
	# Hay que añadir los enlaces
		echo $f
	done
}
#-------------------------------------------------------------------------------
function update {
#-------------------------------------------------------------------------------
	for f in $(dotfiles);do 
		s=$home${f##$base}
		if [ ! -d $(dirname $s) ]; then 
			mkdir -p $(dirname $s);
		fi
		if [ -f $s ] && [ ! -L $s ]; then 
			mv -b $s $s.old
		fi
		if [ -L $s ]; then 
			rm $s
		fi
		ln -s $home/$f $s
	done
}
#-------------------------------------------------------------------------------
function error {
#-------------------------------------------------------------------------------
	echo "Error: $1." >&2 ;
	return 1
}
#-------------------------------------------------------------------------------
function check {
#-------------------------------------------------------------------------------
	for f in $(dotfiles);do 
		s=$home${f##$base}
		if [ ! -d  $(dirname $s) ]; then error "No existe el directorio $(dirname $s)";fi
		if [ -f $s ] && [ ! -L $s ]; then error "$s es un fichero (no un enlace)";fi
		if [ ! -L $s ]; then error "$s no es un enlace";fi
	done
}
#-------------------------------------------------------------------------------
if [ "x$1" = "x-h" ]; then
	help;
	exit 0;
fi
if [ "x$1" = "x-c" ]; then
	check;
	exit 0;
fi
if [ "x$1" = "x-u" ]; then
	update;
	exit 0;
fi

