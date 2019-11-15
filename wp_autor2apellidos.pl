#!/usr/bin/perl -w
use utf8;

#-------------------------------------------------------------------------------
sub fhelp {
#-------------------------------------------------------------------------------
	my $nombre="wp_autor2apellidos.pl";
	print "* $nombre
	* Uso
		> $nombre -[haen]
	* Descripción
		Realiza operaciones habituales con plantillas libro con el campo «autor».

		
	* Opciones
		* -h
			Muestra esta ayuda.
		* -n
			Normalizar. Es equivalente a -e -a

			Es la opción por defecto.
		* -a
			Convierte el campo autor en nombre y apellidos, enlaces autor y otros autores si hiciera falta.

			Convierte la entrada estándar
			> | autor = APELLIDOS, NOMBRE
			a
			> | apellidos = APELLIDOS
			> | nombre = NOMBRE

			o 
			> | autor = [[ENLACE | APELLIDOS, NOMBRE]]
			a
			> | apellidos = APELLIDOS
			> | nombre = NOMBRE
			> | enlaceautor = ENLACE

			También convierte las listas de autores en elementos separados:
			> | autor = nombre, apellidos; nombre2, apellidos2; ...
			a
			> | autor = nombre, apellidos
			> | autor2 = nombre2, apellidos2
			> |  ...
		* -e 
			Convierte al editorial con ubicación en dos campos separados, ubicación y editorial

			También combierte la ubiicación y editorial combinadas en campos separados
			> | editorial = UBICACIÓN: EDITORIAL
			a
			> | ubiicación = UBICACIÓN
			> | editorial = EDITORIAL
		* -v
			Pone los apellidos en versalitas.

			TODO
		* -V
			Quita las versalitas

			TODO

	\n";
}
#-------------------------------------------------------------------------------
if( @ARGV >0 && $ARGV[0] eq "-h"){ fhelp(); exit 0; }

my $opcion_autor=0;
my $opcion_editorial=0;
my $opcion_versalitas=0;
my $opcion_antiversalitas=0;

while(@ARGV) {
	if ($ARGV[0] eq "-n") {
		$opcion_autor = 1;
		$opcion_editorial = 1;
	}
	if ($ARGV[0] eq "-a") { $opcion_autor = 1; }
	if ($ARGV[0] eq "-e") { $opcion_editorial = 1; }
	if ($ARGV[0] eq "-v") { $opcion_versalitas = 1; }
	if ($ARGV[0] eq "-V") { $opcion_antiversalitas = 1; }
	shift;
}
if ($opcion_autor +$opcion_editorial + $opcion_versalitas + $opcion_antiversalitas == 0) {
	$opcion_autor = 1;
	$opcion_editorial = 1;
}
while(<>) {
	chomp;s/\r//;
	if($opcion_autor) {
		s/\[([^|]*)\|([^\]]*)]/[$1 __escape_de_linea__ $2]/g;
		if ($_=~/\| *autor *= *[^|]*;/) {
			my $autores=$_;
			$autores=~s/.*\| *autor *= *//;
			my @autores=split(" *; *", $autores);
			my @res;
			$contador='';
			foreach $autor (@autores) {
				push @res, "| autor$contador = $autor ";
				$contador = $contador eq '' ? 2 : $contador+1;
			}
			my $res=join("\n", @res);
			s/\| *autor *= *[^|]*/$res/;
		}
		s/ __escape_de_linea__ /|/g;
		s/\| *autor([0-9]*) *= *\[ *([^\|]*) *\| *([^,]*) *, *([^\]]*) *\] */| apellidos$1 = $3\n| nombre$1 = $4\n| enlaceautor$1 = $2/g;
		s/\| *autor([0-9]*) *= *([^,]*) *, *([^\|]*)/| apellidos$1 = $2\n| nombre$1 = $3/g;
	}
	if($opcion_versalitas) {
		s/\| *(apellidos[0-9]*) *= *([^|\n]*)/| $1 = {{versalitas|$2}}/g;
	}
	if($opcion_antiversalitas) {
		s/\{\{versalitas|([^}]*)\}\}/$1/g;
	}
	if($opcion_editorial) {
		s/\| *editorial *= *([^:]*) *: *([^\|]*)/| ubicación = $1\n| editorial = $2/g;
	}
	print "$_\n";
}

