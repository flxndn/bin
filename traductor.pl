#!/usr/bin/perl -w

my $posicion=0;
my %diccionario;
my $diccionario='';

while($#ARGV >-1 && $ARGV[0]=~/^-/) {
	if ($ARGV[0] eq "-h") {
		$programa=$0;
		$programa=~s/.*\///;
	print <<HELP;
	* $programa
		* Uso
			> $0 [-k posicion] -t fichero_diccionario [fichero]
			> $0 -h
		
		* Descripción
			Saca por salida estándar la entrada estándar [o de fichero] 
			sustituyendo todas las ocurrencias de la columna posicion del 
			fichero_diccionario por la segunda columna.

			Las columnas de fichero_diccionario están separadas por 
			tabuladores.

		* Opciones
			* -h
				Muestra esta ayuda.
			* -k posicion
				Posición en lq que se encuentra el campo a traducir. Comenzando en 1.

				Si no se especifica se usa el primero (1).
			* -t fichero_diccionario
				Fichero que se usa para traducir.

HELP
		exit;
	}
	elsif($ARGV[0] eq '-t') {
		shift;
		$diccionario=shift @ARGV; 
		open FILE, $diccionario or die $!;

		while(<FILE>) {
			chomp; s/\r//;
			my ($clave, $valor) = split("\t");
			$diccionario{$clave} = $valor;
		}
	} elsif($ARGV[0] eq '-k') {
		shift;
		$posicion=shift @ARGV;
		$posicion--;
	}
}


while(<>) {
	chomp; s/\r//;
	my @valores =split("\t");
	$valor_sin_traducir = $valores[$posicion];
	if(exists $diccionario{$valor_sin_traducir}) {
		$valor_traducido = $diccionario{$valor_sin_traducir};
		$valores[$posicion] = $valor_traducido;
		print join("\t", @valores)."\n";
	} else {
		warn "No existe la palabra \"$valor_sin_traducir\" en la primera columna del diccionario $diccionario.";
	}
}
