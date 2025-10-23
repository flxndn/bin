#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
while($#ARGV >-1 && $ARGV[0]=~/^-/) {
	if ($ARGV[0] eq "-h") {
		$programa=$0;
		$programa=~s/.*\///;
	print <<HELP;
	* $programa
		* Uso
			> $0 
			> $0 -h
		
		* Descripción
			Para una lista de números que entran por entrada estándar saca su media y varianza.

			Basado en [[https://blog.demofox.org/2020/03/10/how-do-i-calculate-variance-in-1-pass/ How Do I Calculate Variance in 1 Pass?]]

			Saca por salida estándar la cantidad de elementos, su media y su 
			varianza en una sola línea, separadas por tabuladores.
		* Opciones
			* -h
				Muestra esta ayuda.

HELP
		exit;
	}
#	elsif($ARGV[0] eq '-t') {
#		shift;
#		$diccionario=shift @ARGV; 
#		open FILE, $diccionario or die $!;
#
#		while(<FILE>) {
#			chomp; s/\r//;
#			my ($clave, $valor) = split("\t");
#			$diccionario{$clave} = $valor;
#		}
#	} elsif($ARGV[0] eq '-k') {
#		shift;
#		$posicion=shift @ARGV;
#		$posicion--;
#	}
}
my @lines=<>;
chomp @lines;

my $lines=join("\n", @lines);
$lines=~s/\n      */ /smg;
$lines=~s/\n    }/ }/smg;

print $lines;
