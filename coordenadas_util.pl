#!/usr/bin/perl -w

if ($#ARGV >-1 && $ARGV[0] eq "-h") {
	$programa=$0;
	$programa=~s/.*\///;
print <<HELP;
* $programa
	* Uso
		> $0  ''orden'' [''opciones''] [''fichero_coordenadas'']
		> $0 -h
	
	* Descripción
		Lee de fichero_coordenadas'' o de la entrada estándar y aplica la orden correspondiente.

	* Formato coordenadas
		Cada coordenada x,y en una nueva línea. Separadas por un tabulador.
		Los decimales se indican con puntos.

	* Órdenes
		 - suma 'vx','vy' :: Realiza una suma vectorial del vector ('vx','vy') a cada coordenada.
		 - escala ''valor'' :: Realiza un escalado de las coordenadas multiplicando por ''valor''.
		 - distancia ''minimo'' :: Elimina los puntos que se encuentran a menos de ''minimo'' de la anterior coordenada.
		 - yinversa ''altura_imagen'' :: Las coordenadas verticales en internet van de arriba a abajo, mientras que las geográficas van de abajo hacia arriba. Para convertirlas hay que hacer una resta a la altura de la imagen en pixels.

	* Opciones
		* -h
			Muestra esta ayuda.
HELP
	exit;
}
my $escala=1;
my $xv=0;
my $yv=0;
my $minimo=0;
my $altura_imagen=0;

my $orden=$ARGV[0];shift;


if ($orden eq 'suma') {
	($xv,$yv)=split(',', $ARGV[0]);
	shift;
} elsif ($orden eq 'escala') {
	$escala=$ARGV[0]; 
	shift;
} elsif ($orden eq 'distancia') {
	$minimo=$ARGV[0]; 
	$minimo2 = $minimo**2;
	#warn "minimo2=$minimo2\n";
	shift;
} elsif ($orden eq 'yinversa') {
	$altura_imagen=$ARGV[0]; 
	shift;
} else {
	die "Error. La orden ($orden) no se reconoce.";
}

my $inicio=1;
my $x0=0;
my $y0=0;

while(<>) {
	chomp;s/\r//;
	my ($x,$y) = split(/\t/);

	$mostrar=1;
	if ($orden eq 'suma') {
		$x += $xv;
		$y += $yv;
	} elsif ($orden eq 'escala') {
		$x *= $escala;
		$y *= $escala;
	} elsif ($orden eq 'yinversa') {
		$y = $altura_imagen - $y;
	} elsif ($orden eq 'distancia') {
		if ($inicio) {
			$inicio=0;
			$x0=$x;
			$y0=$y; 
		} else {
			$d2 = ($x-$x0)**2 + ($y-$y0)**2;
			#warn "d2=$d2\n";
			if($d2 < $minimo2) {
				$mostrar=0;
			} else {
				$x0=$x;
				$y0=$y; 
			}
		}
	}
	
	if ($mostrar) {
		print "$x\t$y\n";
	}
}
