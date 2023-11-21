#!/usr/bin/perl -w

use strict;
use warnings;


my $posicion=0;
my %diccionario;

while($#ARGV >-1 && $ARGV[0]=~/^-/) {
	if ($ARGV[0] eq "-h") {
		my $programa=$0;
		$programa=~s/.*\///;
	print <<HELP;
	* $programa
		* Uso
			> $0 [fichero_sec]
			> $0 -h
		
		* Descripción
			Convierte un fichero *.sec a un fichero csv de dos columnas, en la primera está el path y en la segunda el texto del párrafo.

		* Opciones
			* -h
				Muestra esta ayuda.

HELP
		exit;
	}
}

my @path;
while(<>) {
	chomp; s/\r//;
	if ($_=~/^	*\* /) {
		my $tabs=$_;
		$tabs=~s/\* .*//;
		my $nivel=length($tabs);
		my $title=$_;
		$title=~s/^	*\* //;

		$path[$nivel]=$title;
		while(scalar @path > $nivel + 1 ) {
			pop(@path);
		}
	} else {
		(length($_) > 0 ) && print join("/", @path)."\t$_\n";
	}
}
