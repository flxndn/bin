#!/usr/bin/perl -w


#-------------------------------------------------------------------------------
sub lerp{
#-------------------------------------------------------------------------------
	my ($anterior, $nuevo, $cantidad)=@_;

	return ($anterior*($cantidad-1)+$nuevo)/$cantidad;
}
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

my $media=0;
my $media_cuadrado=0;
my $cantidad=0;

while(<>) {
	chomp;s/\r//;
	$cantidad++;
	my $valor = $_;
	$media = lerp($media, $valor, $cantidad);
	$media_cuadrado = lerp($media_cuadrado, $valor*$valor, $cantidad);
}
my $varianza=abs($media_cuadrado - ($media*$media));

print "$cantidad\t$media\t$varianza\n";
