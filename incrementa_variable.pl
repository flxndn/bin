#!/usr/bin/perl -w

#my $cadena_busqueda='- id: 2';
#my $cadena_sustitucion='- id: ';
#my $inicio=17;

#-------------------------------------------------------------------------------
sub help {
#-------------------------------------------------------------------------------
	print <<HELP;
* incrementa_variable.pl
	* Uso
		> incrementa_variable.pl cadena_busqueda cadena_sustitucion valor_inicial
		> incrementa_variable.pl -h
	* Descripción
		En cada línea de la entrada estándar busca cadena_busqueda y la 
		sustituye por la cadena_sustitucion y un contador que inicialmente 
		vale valor_inicial y se va incrementando con cada ocurrencia.

		Las líneas que no cumplen la condición no las modifica.
HELP
}
#-------------------------------------------------------------------------------

if ($#ARGV == -1 ) {
	help;
	die "Error. Sin argumentos.";
}

if ($ARGV[0] eq "-h" ) {
	help;
	exit;
}

my $cadena_busqueda=$ARGV[0];
my $cadena_sustitucion=$ARGV[1];
my $inicio=$ARGV[2];
shift; shift; shift;

my $contador=$inicio;
while(<>) {
	if ($_=~/$cadena_busqueda/) {
		$_=~s/$cadena_busqueda/$cadena_sustitucion$contador/;
		$contador++;
	}
	print $_;
}
