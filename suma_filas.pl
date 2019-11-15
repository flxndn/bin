#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
sub help{
#-------------------------------------------------------------------------------
	my $nombre="suma_filas.pl";
	print "* suma_filas.pl
	Suma las filas que vengan poor entrada estándar (o fichero).

	Está pensado sumar matrices de números separados con un delimitador.

	El separador

	El separador de decimales es el punto.
	* Uso
		> suma_filas.pl -h
		> suma_filas.pl [-d delimitador] [fichero]
	* Opciones
		* -h
			Muestra esta ayuda.

	\n";
}
#-------------------------------------------------------------------------------
if( @ARGV >0 && $ARGV[0] eq "-h"){ help; exit 0; }
my $delimitador="\t";

if( @ARGV >0 && $ARGV[0] eq "-d"){ 
	$delimitador=$ARGV[1];
	shift;
	shift;
}

my $formato='yaml';
#
# main
#
my $inicio=1;
my @suma;
while(<>) {
	chomp;s/\r//;
	my @valores=split($delimitador);

	if ($inicio) {
		@suma=@valores;
		$inicio=0;
	} else {
		for($i=0;$i<=$#valores;$i++) {
			$suma[$i]+=$valores[$i];
		}
	}
}
print join($delimitador,@suma)."\n";
#-------------------------------------------------------------------------------
