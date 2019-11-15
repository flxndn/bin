#!/usr/bin/perl -w
use Getopt::Mixed;

Getopt::Mixed::init('h t c i o help>h no-titulos>t no-categorias>c input-test>i output-test>o');

$accion='procesar';
$procesa_titulos=1;
$procesa_categorias=1;

while(my($option, $value, $pretty)=Getopt::Mixed::nextOption()) {
	OPTION: {
		$option eq 'h' and do {
			$accion='ayuda';
			last OPTION;
		};
		$option eq 'i' and do {
			$accion='saca_input';
			last OPTION;
		};
		$option eq 'o' and do {
			$accion='saca_output';
			last OPTION;
		};
		$option eq 't' and do {
			$procesa_titulos=0;
			last OPTION;
		};
		$option eq 'c' and do {
			$procesa_categorias=0;
			last OPTION;
		};
	}
}
Getopt::Mixed::cleanup();

if ($accion eq 'ayuda') {
	$name=$0;
	$name=~s/^.*\///;
print <<HELP;
* $name
	Se pretende que sirva para poner la [[https://es.wikipedia.org/wiki/Plantilla:SIGLO Plantilla:SIGLO]] a la mayor parte del código wikipedia

	Las líneas entran por entrada estándar, y salen por salida estándar.

	* Opciones
		* -h, --help
			Muestra esta ayuda.
		* -t, --ignora_titulos
			Omite las líneas que contienen títulos
		* -c, --ignora_categorias
			Omite las líneas que contienen categorías
		* -i, --input-test
			Cadenas para hacer el test
		* -o, --output-test
			Resultado esperado del test

	* Test
		Se puede comprobar su funcionamiento con el script bash
		> plantilla_siglo_test.sh

	* Dependencias
		- libgetopt-mixed-perl
			
	* Bugs
		- No funciona para siglos antes de Cristo
		- No funciona cuando no hay wikienlace
		- Funciona hasta el siglo XXIX

	* Solucionado
		- También cambia cuando las versalitas no son aplicables: títulos de secciones y categorías
		- Cambia las plantillas versalita con siglo en minúsculas por el siglo en mayúsculas
HELP
	exit;
}

if ($accion eq 'saca_input') {
	print <<TEST_IN;
# Simples
siglo XI
Siglo XI
# abreviados
s. XI
S. XI
# Con enlace
[[siglo XI]]
[[Siglo XI]]
# abreviados con enlace
[[siglo XI|s. XI]]
[[Siglo XI|S. XI]]
# enlace sin texto de siglo
[[Siglo XI|XI]]
[[S. XI|XI]]
# siglo en título
= Siglo XI =
# siglo en categoría
[[Categoría:Siglo XI]]
# Versalita
Siglo {{Versalita|xi}}
[[Siglo XI|S. {{versalita|xi}}]]
TEST_IN
	exit;
}

if ($accion eq 'saca_output') {
	$titulo = $procesa_titulos ?  "= {{SIGLO|XI|d|S|0}} =" : "= Siglo XI =" ;
	$categoria = $procesa_categorias ? "[[Categoría:{{SIGLO|XI|d|S|0}}]]" : "[[Categoría:Siglo XI]]";
	print <<TEST_OUT;
# Simples
{{SIGLO|XI|d|s|0}}
{{SIGLO|XI|d|S|0}}
# abreviados
{{SIGLO|XI|d|a|0}}
{{SIGLO|XI|d|A|0}}
# Con enlace
{{SIGLO|XI|d|s|1}}
{{SIGLO|XI|d|S|1}}
# abreviados con enlace
{{SIGLO|XI|d|a|1}}
{{SIGLO|XI|d|A|1}}
# enlace sin texto de siglo
{{SIGLO|XI|d||1}}
{{SIGLO|XI|d||1}}
# siglo en título
$titulo
# siglo en categoría
$categoria
# Versalita
{{SIGLO|XI|d|S|0}}
{{SIGLO|XI|d|A|1}}
TEST_OUT

	exit;
}

## accion es igual a procesar
my @siglos = ( 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX', 'XXI', 'XXII', 'XXIII', 'XXIV', 'XXV', 'XXVI', 'XXVII', 'XXVIII', 'XXIX' );

my @palabras = (['siglo ',	's'],
				['Siglo ',	'S'],
				['s. ',	'a'],
				['S. ',	'A']
				);

my $vacio=['', ''];

my @palabras_extra=@palabras;
push (@palabras_extra, $vacio);


my @cadenas = ( ['\[\[', '\]\]', '1'],
				['\b', '\b', '0' ] );

LINE: while(<>) {
	if(	($procesa_titulos || $_!~/^=/) 
		&& 
		($procesa_categorias || $_!~/^\[\[Categoría:/) )
	{
		foreach $siglo (@siglos) {
			s/\{\{[vV]ersalita\|$siglo}}/$siglo/gi;
		}
		foreach $siglo (@siglos) {
			foreach $cadena (@cadenas) {
				if($$cadena[2] eq "1") {
					# Para los enlaces complejos abreviados
					foreach $palabra (@palabras_extra) {
						foreach $palabra2 (@palabras) {
							$buscar=$$cadena[0].$$palabra2[0].$siglo."\\|".$$palabra[0].$siglo.$$cadena[1];
							#print "i:$_\t";
							$sustituir="{{SIGLO|$siglo|d|".$$palabra[1]."|".$$cadena[2]."}}";
							s/$buscar/$sustituir/g;
							#print "f:$_\tb:$buscar\ts:$sustituir\n";
						}
						$buscar=$$cadena[0].$$palabra[0].$siglo.$$cadena[1];
						$sustituir="{{SIGLO|$siglo|d|".$$palabra[1]."|".$$cadena[2]."}}";
						s/$buscar/$sustituir/g;
					}
				} else {
					foreach $palabra (@palabras) {
						$buscar=$$cadena[0].$$palabra[0].$siglo.$$cadena[1];
						$sustituir="{{SIGLO|$siglo|d|".$$palabra[1]."|".$$cadena[2]."}}";
						s/$buscar/$sustituir/g;
					}
				}
			}
		}
	}
	print;
}
