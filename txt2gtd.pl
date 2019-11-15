#!/usr/bin/perl -w

if (@ARGV && $ARGV[0] eq '-h') {
	my $nombre="txt2gtd.pl";

	print <<HELP;
* $nombre

	* Uso		
		- $nombre -h
		- $nombre [archivo]

	* Descripción
		Las líneas en blanco y los comentarios los deja igual.

		Las que no contienen ':' las considera títulos.

		El resto son registros.
HELP
	exit 0;
}

my @proyectos=();
while(<>) {
	chomp;s/\r//;

	if($_=~/^#/ || $_=~/^$/) {
		print "$_\n";
	} else {
		my $nivel = tabuladores($_) - ($_=~/^\t*[A-Z 0-9\-]*: /);
		my $ultimo=$#proyectos;
		for(my $i=$nivel; $i<$ultimo; $i++) {
			pop(@proyectos);
		}
		if($_=~/^\t*[A-Z 0-9\-]*: /) {
			# es un registro
			s/^\t*//;
			print join("\/",@proyectos) . "\t$_\n";
		} else {
			# es un título
			s/^\t*//;
			$proyectos[$nivel]=$_;
		}
	}
}
#-------------------------------------------------------------------------------
sub tabuladores {
#-------------------------------------------------------------------------------
	my $linea = shift;
	my @letras = split('',$linea);
	my $posicion=0;
	while($letras[$posicion] eq "\t") {
		$posicion++;
	}
	return $posicion;
}
#-------------------------------------------------------------------------------
