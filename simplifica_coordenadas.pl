#!/usr/bin/perl -w

if ($#ARGV >-1 && $ARGV[0] eq "-h") {
	$programa=$0;
	$programa=~s/.*\///;
print <<HELP;
* $programa
	* Uso
		> $0 [lista_de_coordenadas]
		> $0 -h
	
	* Descripción
		Para cada línea de la entrada si no está formado por dos números 
		separados por coma la saca igual.

		Si está formado por dos números separados por coma realiza una 
		simplificación, eliminando los puntos intermedios en líneas 
		horizontales y verticales.

		Si recibe esta entrada: 
			> 1, 3
			> 1, 5
			> 1, 6
			> 1, 10

		sólo saca
			> 1, 3
			> 1, 10

		Lo mismo sucede para la coordenada y.

	* Opciones
		* -h
			Muestra esta ayuda.

HELP
	exit;
} 
#-------------------------------------------------------------------------------
sub simplifica_n  {
#-------------------------------------------------------------------------------
	@resultado = ();
	my $primero=[];
	my $segundo=[];
	my $indice = $_[1];
	foreach $c (@{$_[0]}){
		if (not @$primero) {
			$primero = $c;
		} elsif (not @$segundo) {
			if ($$primero[$indice] eq $$c[$indice]) {
				$segundo = $c;
			} else {
				push @resultado, $primero;
				$primero = $c;
			}
		} else {
			if ($$primero[$indice] eq $$c[$indice]) {
				$segundo = $c;
			} else {
				push @resultado, ($primero, $segundo);
				$primero = $c;
				$segundo = [];
			}
		}
	}
	if (@$primero) { 
		push @resultado, $primero; 
	}
	if (@$segundo) { 
		push @resultado, $segundo; 
	} 
	return @resultado;
}
#-------------------------------------------------------------------------------
sub simplifica  {
#-------------------------------------------------------------------------------
	my @coordenadas = @{$_[0]};
	@coordenadas = simplifica_n(\@coordenadas, 0);
	@coordenadas = simplifica_n(\@coordenadas, 1);

	my @textos=();
	foreach my $e (@coordenadas) {
		push @textos, "$$e[0],$$e[1]";
	}
	print join(",\n", @textos);
}
#-------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------- 
my $dentro=0;
my @coordenadas;

while(<>) {
	chomp;s/\r//;
	if ($_=~/^[0-9]+, *[0-9]+,*/) {
		if(not $dentro) {
			$dentro=1;
			@coordenadas=()
		}
		$_=~s/, *$//;
		my ($x, $y) = split(", *");
		push @coordenadas, [$x, $y];
	} else {
		if($dentro) {
			simplifica(\@coordenadas);
			print "\n";
			$dentro=0;
		}
		print $_."\n";
	}
}
