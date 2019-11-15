#!/usr/bin/perl -w

if (@ARGV && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help'))
{
	my $nombre="gtdtxt2sec.pl";

	print <<HELP;
NOMBRE:		$nombre

USO:		$nombre -h
			$nombre [fichero(s)]

DESCRIPCIÓN:
			Saca por la salida estándar la entrada estándar (o el (los) 
			fichero(s) convertido a formato *.sec (secciones).	


			La entrada debe ser del tipo sec2txt.
HELP
	exit 0;
}
while(<>) {
	chomp;s/\r//;
	if($_!~/^[ \t]*$/) {
		if( $_=~/TODO:/ 
			|| $_=~/WAIT.*:/ 
			|| $_=~/INFO:/
			|| $_=~/DONE:/) {
			print "$_\n\n";
		} else {
			$_=~s/^(\t*)/$1* /;
			print "$_\n";
		}
	}
}
