#!/usr/bin/perl -w

if ($#ARGV >-1 && $ARGV[0] eq "-h") {
print <<HELP;
* $0
	Convierte los ficheros de datos separados por tabuladores (tsv) en sql 
	para actualizar sql.

	La primera línea del fichero tsv tiene que contener los nombres de los 
	campos.

	La primera columna tiene que contener el índice de la tabla.

	* Uso
		> $0 -i cadena_interpolacion numero

	* Opciones
		* -h :: Muestra esta ayuda.
		* -i cadena_interpolacion :: cadena de valores de interpolación, separados los puntos por punto y coma y los valores x de y por comas. :: Ejemplo: "1,3;5,15;10,22"
		* numero :: Número a interpolar

		El símbolo decimal es el punto.
HELP
	exit;
}

# Bucle para que las opciones puean ir en cualquier orden
my %dict_interpolacion;
if($ARGV[0] eq '-i') {
	my $cadena_interpolacion=$ARGV[1];
	shift;shift;
	foreach(split(";", $cadena_interpolacion)) {
		my ($x, $y) = split(",");	
		$dict_interpolacion{$x}=$y;
	}	
}
foreach(@ARGV) {
	my $x=$_;
	my $x0=$y0='';
	foreach(sort {$a<=>$b} (keys(%dict_interpolacion))) {
		if($x0 eq '') {
			$x0=$_;
			$y0=$dict_interpolacion{$_};
		} else {
			$x1=$_;
			$y1=$dict_interpolacion{$_};
			#print "$x0, $x, $x1\n";
			if($x0<=$x && $x<=$x1) {
				my $y = $y0 + ($y1-$y0)/($x1-$x0)*($x-$x0);
				#print "x=$x\n";
				#print "x0=$x0\n";
				#print "y0=$y0\n";
				#print "x1=$x1\n";
				#print "y1=$y1\n";
				print "$y\n";
				last;
			}
			$x0=$x1;
			$y0=$y1;
		} 
	}
}
