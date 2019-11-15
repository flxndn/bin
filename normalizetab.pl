#!/usr/bin/perl

my @min;
my @maximos;

my @lineas=<>;
chomp @lineas;

my $principio=1;

foreach my $linea( @lineas) {
	my @datos=split("\t",$linea);
	for (my $i=0;$i<=$#datos;$i++) { 
		if ($principio or $datos[$i]<$min[$i]) {
			$min[$i]=$datos[$i];
		}
		if ($principio or $datos[$i]>$max[$i]){
			$max[$i]=$datos[$i];
		}
	}
	$principio=0;
}
#print "min: ".join(", ", @min)."\n";
#print "max: ".join(", ", @max)."\n";
foreach my $linea( @lineas) {
	my @datos=split("\t",$linea);
	my @out;
	for (my $i=0;$i<=$#datos;$i++) { 
		@out[$i]=($datos[$i]-$min[$i])/($max[$i]-$min[$i]);
	}
	print join("\t", @out)."\n";
}
