#!/bin/bash 
readonly HERE_BEGIN=__HERE_SEC_BEGIN__
readonly HERE_END=__HERE_SEC_END__
readonly HERE_TITLE=__HERE_SEC_TITLE__
readonly tab=$'\t'
readonly ret=$'\n' 

IFS=$'\n'

#-------------------------------------------------------------------------------
help() {
#-------------------------------------------------------------------------------
	nombre=$(basename $0)
	cat <<HELP
* $nombre

	* Uso
		> $nombre [-l level] [-C directorio_cache] [archivo]
		> $nombre -[ioh]

	* Descripción
		Procesa mediante sectxt.py los fragmentos de texto que están entre las etiquetas
		$HERE_BEGIN y $HERE_END.

		No tiene que tener título.

	* Opciones
		* -i:: Saca un texto para probar si funciona
		* -o:: Saca el resultado que debería generar al alimientarlo con la opción -i.  
		* -t:: Comprueba el $nombre -i | $nombre es igual que $nombre -o
		* -h:: Muestra esta ayuda
		* -l level:: Nivel que añade para los títulos.:: Por defecto es 1.
		* -C directorio_cache:: Se utiliza como caché el directorio_cache para realizar menos conversiones de formato sec a html. :: Los ficheros cache se guardan en el directorio especificado y tienen el nombre: here_sec_<md5>.html

	* Autor
		Félix Anadón Trigo

HELP
}
#-------------------------------------------------------------------------------
test() {
#-------------------------------------------------------------------------------
	out=$(mktemp)
	bien=$(mktemp)

	$0 -o > $out
	$0 -i | $0 > $bien
	diff $out $bien || echo "Error. El resultado no es el esperado." >&2

	rm $out $bien
}
#-------------------------------------------------------------------------------
test_in() {
#-------------------------------------------------------------------------------
	cat <<TEST_IN
- nombre: Caperucita
  fecha: 2015-04-15 21:13:09 
  descripción: |
    $HERE_BEGIN
    Es una historia que se divide en dos partes
    bien diferenciadas.

	Párrafo seguido de lista
	- primer elemento
	- segundo elemento

    * Casa y camino
        - Consejo
        - desobedencia
    * Casa de la abuela
        - redención
    $HERE_END
TEST_IN
}
#-------------------------------------------------------------------------------
test_out() {
#-------------------------------------------------------------------------------
	cat <<TEST_OUT
- nombre: Caperucita
  fecha: 2015-04-15 21:13:09 
  descripción: |
    	<p>Es una historia que se divide en dos partes
    bien diferenciadas.</p>
    	<p>Párrafo seguido de lista</p>
    		<ul>
    		<li> primer elemento</li>
    		<li> segundo elemento</li>
    		</ul>
    <h2>Casa y camino</h2>
    		<ul>
    		<li> Consejo</li>
    		<li> desobedencia</li>
    		</ul>
    <h2>Casa de la abuela</h2>
    		<ul>
    		<li> redención</li>
    		</ul>
    
TEST_OUT
}
#-------------------------------------------------------------------------------
if [ "x$1" = "x-h" ]; then help; exit 0; fi 
if [ "x$1" = "x-i" ]; then test_in; exit 0; fi
if [ "x$1" = "x-o" ]; then test_out; exit 0; fi
if [ "x$1" = "x-t" ]; then test; exit 0; fi
# else...


level=1
directorio_cache=''

if [ "x$1" = "x-l" ]; then
	shift
	level=$1
	shift
fi

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

header=''
tabs=''

for i in $(seq $level); do
	header="$header$tabs* $HERE_TITLE$ret";
	tabs="$tabs$tab";
done

ini=1
dentro=''

tmpfile=$(mktemp /tmp/here_sec.XXXXX)
cat $* > $tmpfile

for i in $( cat -n $tmpfile | grep '__HERE_SEC_\(BEGIN\|END\)__'  | cut -f1 | sed "s/^ *//"); do
	fin=$i
	if [ $dentro ]; then
		fin=$((fin+1))
		offset=$(tail -n +$ini $tmpfile| head -n1 |sed "s/__HERE_SEC_BEGIN__.*//")
		inisec=$((ini+1))
		finsec=$((fin-1))
        # delante de sectxt.py se puede poner el comando cache.sh  y el timepo pasa de 17 a 14 segundos
		#| cache.sh -i -e sectxt.py --html --no_extra_divs \
		( 
			echo "$header"; 
			cat $tmpfile | tail -n +$inisec | head -n $((finsec-inisec)) 
		) \
		| sed "s/    /\t/g" \
		| sed "s/\t */\t/g" \
		| sed "s/^ $//" \
		| sectxt.py --html --no_extra_divs \
		| sed "s/<a name=\"[^\"]*\"><\/a>//" \
		| grep -v "__HERE_SEC_TITLE__" \
		| sed "s/^/$offset/"
		dentro='';
	else
		cat $tmpfile | tail -n +$ini | head -n $((fin-ini)) 
		dentro=1;
	fi
	ini=$fin
done 
tail -n +$ini $tmpfile

rm $tmpfile
