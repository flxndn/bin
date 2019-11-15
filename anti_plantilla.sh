#!/bin/bash

#-------------------------------------------------------------------------------
function test_in() {
#-------------------------------------------------------------------------------
	cat <<TEST_IN
set L=location
set D=date
set N=name
set NN=names

my %N, %L and %D is...
%NN=names
%N=name
%NN=names
TEST_IN
}
#-------------------------------------------------------------------------------
function test_out() {
#-------------------------------------------------------------------------------
	cat <<TEST_OUT
my name, location and date is...
names=names
name=name
names=names
TEST_OUT
}
#-------------------------------------------------------------------------------
function test() {
#-------------------------------------------------------------------------------
	in=$(mktemp)
	out=$(mktemp)

	anti_plantilla.sh --test_in | anti_plantilla.sh > $in
	anti_plantilla.sh --test_out > $out
	diff $in $out

	rm $in $out
}
#-------------------------------------------------------------------------------
function help() {
#-------------------------------------------------------------------------------
	nombre=`basename $0`
	cat <<HELP
* $nombre
	* Uso
		> $nombre [fichero]
		> $nombre -h|--help
		> $nombre -t|--test
		> $nombre -i|--test_in
		> $nombre -o|--test_out

	* Descripción
		Lee la entrada estándar o el fichero pasado como parámetro.

		Lee las variables de las líneas que empiecen por:
		> set nombre_variable=valor_variable
		y los sustituye en la líneas que tengan el nombre de la variable 
		precedido por el símbolo del tanto por ciento.

		Es secuencial. Para poder usar una variable tiene que estar definida 
		previamente.

	* Ejemplo
		Para una entrada como esta:
$(test_in | sed "s/^/\t\t> /")

		Debería producir un resultado como este:
$(test_out| sed "s/^/\t\t> /")

	* Opciones
		* -h | --help
			Muestra esta ayuda
		* -t | --test
			Comprueba que para la entrada de ejemplo produce la salida de ejemplo.
		* -i | --test_in
			Saca por salida estándar el texto que se utiliza para realizar el test.
		* -o | --test_out
			Saca por salida estándar el resultado que se debería obtener al realizar el test.
	* AUTOR
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
while echo $1 | grep -q '^-' ;do
	case "$1" in 
	-h|--help) help; exit;;
	-i|--test_in) test_in; exit;;
	-o|--test_out) test_out; exit;;
	-t|--test) test; exit;;
	esac
done

IFS=$'\n'
declare -A variables

for i in $(cat $*); do
	if $(echo $i | grep -q '^set ');then
		nombre=$(echo $i| cut -f2- -d' '|cut -f1 -d'=') 
		valor=$(echo $i| sed "s/\r//" | cut -f2- -d' '|cut -f2- -d'='|sed "s/\//\\\\\//g") 
		variables[$nombre]=$valor
	else
		ii="$i"
		for k in "${!variables[@]}";do
			aux=$(echo $ii| sed "s/%$k/${variables[$k]}/g")
			ii="$aux"
		done
		echo $ii
	fi
done
