#!/usr/bin/perl -w

if ($#ARGV >-1 && $ARGV[0] eq "-h") {
	$programa=$0;
	$programa=~s/.*\///;
print <<HELP;
* $programa
	* Uso
		> $0 -g <anchura>x<altura> [lista_de_coordenadas]
		> $0 -h
	
	* Descripción
		Para una lista de coordenadas con las x en la primera columna y las y 
		en la segunda con tabuladores como separadores las reescala para que 
		quepan en el recuadro anchura x altura.

		* Fichero de entrada
			La lista de coordenadas es un fichero de texto de tres columnas 
			separadas por tabuladores.

			Columnas: 
			# identificador de grupo de coordenadas
			# coordenadas x
			# coordenadas y

		* Salida
			Fichero de columnas separadas por tabuladores.

			Columnas:
			# identificador. Igual que el fichero de entrada
			# coordenada x. Igual que el fichero de entrada
			# coordenada y. Igual que el fichero de entrada
			# coordenada x escalada
			# coordenada y escalada
			# d=distancia desde el punto anterior 
			# v=vector desde el punto anterior
HELP
	exit;
} 
#-------------------------------------------------------------------------------
sub extremos  {
#-------------------------------------------------------------------------------
	my ($min, $max) = ($_[0], $_[0]);
	foreach(@_) {
		$min = $_ if $_ < $min;
		$max = $_ if $_ > $max;
	}
	return ($min, $max, $max-$min);
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
my ($anchura, $altura)=(0,0);

if ($ARGV[0] eq '-g') {
	($anchura, $altura) = split('x', $ARGV[1]);
	shift;shift;
} else {
	die "Error: hay que indicar la geometría en pixels. Ejemplo: -g 300x200";
}
my @ids;
while(<>) {
	chomp;s/\r//;
	my ($id, $x,$y) = split("\t");
	push @x, $x;
	push @y, $y;
	push @ids, $id;
}
my ($minx, $maxx, $rx) = extremos @x;
my $escalax=$rx/$anchura;

my ($miny, $maxy, $ry) = extremos @y;
my $escalay=$ry/$altura;

my $escala = $escalax > $escalay ? $escalax : $escalay;

$inicio=1;
foreach(@x) {
	$nx=int(($_-$minx)/$escala);
	$y=shift @y;
	$ny=int(($y-$miny)/$escala);
	$id=shift @ids;

	my ($d, $vector);
	if($inicio == 0) {
		$dx = $xant-$nx;
		$dy = $yant-$ny;
		$d = sqrt($dx*$dx + $dy*$dy);
		if ($d == 0) {
			$vector=0;
		} else {
			$vector=($dx/$d).",".($dy/$d);
		}
	} else {
		$vector="-";
		$d='-';
	}

	print join("\t", ($id, $_, $y, $nx, $ny, "d=$d", "v=$vector"))."\n";

	$xant=$nx;
	$yant=$ny;
	$inicio=0;
}
