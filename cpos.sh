#!/bin/bash

# cpos.sh Console Position
function ayuda {
	cat <<AYUDA
* cpos.sh
	Console position

	* Descripción
		Coloca la consola en una posición y con un tamaño predefinidos.

	* Opciones
		- -h :: Muestra esta ayuda
		- -m :: Posición predefinida principal
		- -l :: Posición predefinida de logs
AYUDA
}	

x=2500;
y=0;
h=81;
w=170;

if [ "x$1" = "x-h" ]; then
	ayuda
	exit
elif [ "x$1" = "x-m" ]; then
	x=2500; y=0; h=81; w=170;
elif [ "x$1" = "x-l" ]; then
	x=0; y=118; h=51; w=160;
fi

xdotool getactivewindow windowmove $x $y 
echo "\e[8;$h;${w}t"
printf "\e[8;$h;${w}t"
