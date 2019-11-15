#!/usr/bin/perl -w

my $posicion=1;

while($#ARGV >-1 && $ARGV[0]=~/^-/) {
	if ($ARGV[0] eq "-h") {
		$programa=$0;
		$programa=~s/.*\///;
	print <<HELP;
	* $programa
		* Uso
			> $0 [-k posicion] [fichero]
			> $0 -h
		
		* Descripción
			Saca por pantalla el fichero de entrada sustituyendo en la columna ''posicion'' el formato de fecha dd/mm/aaaa hh:mm:ss por aaaa-mm-dd hh:mm:ss.

		* Opciones
			* -h
				Muestra esta ayuda.
			* -k posicion
				Posición en lq que se encuentra el campo a traducir. Comenzando en 1.

				Si no se especifica se usa el primero (1).

HELP
		exit;
	} elsif($ARGV[0] eq '-k') {
		shift;
		$posicion=shift @ARGV;
	}
}

$posicion--;

while(<>) {
	chomp; s/\r//;
	my @valores =split("\t");
	$fecha_sin_traducir = $valores[$posicion];
	my ($d,$m,$a,$tiempo)=split(/[\/ ]+/,$fecha_sin_traducir);
	$fecha_traducida="$a-$m-$d $tiempo";

	$valores[$posicion] = $fecha_traducida;
	print join("\t", @valores)."\n";
}
