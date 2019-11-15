#!/usr/bin/perl -w
use POSIX qw(strftime);


#-------------------------------------------------------------------------------
sub help{
#-------------------------------------------------------------------------------
	print "* wp_enlace2citaweb.pl
	Convierte 

	[<url>] en \\{\\{cita web | url=<url> | fachaacceso=<fecha actual> | campos adicionales vacíos\\}\\}

	[<url> <título>] en \\{\\{cita web | url=<url> | título=<título> | fachaacceso=<fecha actual> | campos adicionales vacíos\\}\\}

	* Uso 
		> wp_enlace2citaweb.pl -h 
		> wp_enlace2citaweb.pl [opciones]

	* Opciones
		* -h
			Muestra esta ayuda.
		* -n
			La plantilla generada es Cita noticia
		* -w
			La plantilla generada es Cita web

			Es la opción por defecto
		* -e 
			Salida expandida: los campos están en diferentes líneas.
";
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

$sep=" ";

if ($#ARGV != -1 && $ARGV[0] eq '-h') {
	help();
	exit;
}

my $tipo="web";
while ($#ARGV > -1) {
	if ($ARGV[0] eq '-n') { $tipo="noticia";}
	elsif ($ARGV[0] eq '-e') { $sep="\n\t";}
	shift;
}

my $date = strftime "%e de %B de %Y", localtime;
$date=~s/^ //;
my $extras_comun = "fecha =$sep| fechaacceso = $date$sep| nombre =$sep| apellidos =";
my $extras;

if($tipo eq "web") {
	$extras= "$extras_comun$sep| obra = ";
}
if($tipo eq "noticia") {
	$extras= "$extras_comun$sep| periódico =$sep| agencia = ";
}

while(<>) {
	s/\[([^ \]]*) ([^]]*)\]/{{cita $tipo$sep| url = $1$sep| título = $2$sep| $extras }}/g;
	s/\[([^ \]]*)\]/{{cita $tipo$sep| url = $1$sep| título =$sep| $extras }}/g;
	print;
}
#-------------------------------------------------------------------------------
