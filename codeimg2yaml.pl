#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
sub help{
#-------------------------------------------------------------------------------
	print "* codeimg2yaml.pl [opciones] [fichero]
	Convierte la entrada estándar o fichero, que tiene que ser el código 
	fuente de picasa google a texto yaml o sec para el fichero libros.yaml.

	* Opciones
		* -h
			Muestra esta ayuda.
		* -s
			Saca el resultado en formato *.sec
		* -y
			Saca el resultado en formato yaml

			Es la opción por defecto

	\n";
}
#-------------------------------------------------------------------------------
if( @ARGV >0 && $ARGV[0] eq "-h"){ help; exit 0; }
#-------------------------------------------------------------------------------

my $formato='yaml';
if( @ARGV >0 && $ARGV[0] eq "-s"){ $formato='sec'; shift; }
if( @ARGV >0 && $ARGV[0] eq "-y"){ $formato='yaml'; shift; }

#
# main
#
if ($formato eq 'yaml' ) {
	print "        imágenes: \n";
}
if ($formato eq 'sec' ) {
	print "* imágenes\n";
}
my $contador=0;
my @imgs=<>;
foreach(@imgs) {
	chomp;s/\r//;
	s/[ \t]*$//;
	s/^[ \t]*//;
	$maxi=$_;
	$mini=$_;
	my $dim=$_;
	$dim=~s/.*[=\-]w([0-9]*)-h([0-9]*)-no$/$1,$2/;
	my ($width, $height) =split(",", $dim);
	my $x=288;
	if ($width eq 0) {
		die "Error: Anchura es 0 en la línea \"$_\".";
	}
	#warn "$height x $width\n";
	my $y=int($height*288/$width);

	$mini=~s/=w$width*-h$height-no$/=w$x-h$y-no/;

	if ($formato eq 'yaml' ) {
		print "          - título: xxx imagen $contador\n";
		print "            texto: xxx imagen $contador\n";
		print "            mini: $mini\n";
		print "            maxi: $maxi\n";
	}
	if ($formato eq 'sec' ) {
		print "	- {{$mini|xxx imagen $contador|$maxi}}\n";
	}
	$contador++;
}
#-------------------------------------------------------------------------------
