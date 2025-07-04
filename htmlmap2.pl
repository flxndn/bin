#!/usr/bin/perl -w
use Data::Dumper qw(Dumper);

my $formato='svg';

while($#ARGV >-1 && $ARGV[0]=~/^-/) {
	if ($ARGV[0] eq "-h") {
		$programa=$0;
		$programa=~s/.*\///;
	print <<HELP;
	* $programa
		* Uso
			> $0 [ -f formato ] [fichero]
			> $0 -h
		
		* Descripción
			Convierte el [[https://developer.mozilla.org/es/docs/Web/HTML/Element/map mapa html]] al formato indicado.

			Tanto el fichero como la salida estándar es solo la parte del documento que contiene el elemento map con sus areas.
		* Opciones
			* -h :: Muestra esta ayuda.
			* -f formato :: Formato en el que se quiere la salida. :: Por defecto es svg.

HELP
		exit;
	} elsif($ARGV[0] eq '-f') {
		shift;
		$formato=shift @ARGV;
	}
}


# Parseado 
my @lineas=<>;
chomp @lineas;
my $lineas=join('', @lineas);

$lineas=~s/\t/ /g;
$lineas=~s/  */ /g;
$lineas=~s/> </></g;
# Elimino las etiquetas map
$lineas=~s/.*<map [^>]*>//;
$lineas=~s/<\/map>.*//;


my @mapa;
my @areas=split(/<area /, $lineas);

foreach (@areas) {
	$_=~s/ *\/>//;
	if($_ eq ""){
		next;
	}
	my @atributos=split(/" /);
	my %area;
	foreach(@atributos) {
		my ($nombre, $valor) = split("=", $_, 2);
		$valor=~s/"//;
		$area{$nombre}=$valor;
	}
	push(@mapa, \%area);
}

# saco en el formato adecuado

if ($formato eq 'svg') {
	print '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   width="1200"
   height="1024"
   viewBox="0 0 1200 1024"
   version="1.1"
   id="svg5"
   inkscape:version="1.2.2 (b0a8486541, 2022-12-01)"
   sodipodi:docname="kk.svg"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg">
  <sodipodi:namedview
     id="namedview7"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:showpageshadow="2"
     inkscape:pageopacity="0.0"
     inkscape:pagecheckerboard="0"
     inkscape:deskcolor="#d1d1d1"
     inkscape:document-units="px"
     showgrid="false"
     inkscape:zoom="0.67526655"
     inkscape:cx="375.40731"
     inkscape:cy="562.00029"
     inkscape:window-width="1280"
     inkscape:window-height="955"
     inkscape:window-x="0"
     inkscape:window-y="32"
     inkscape:window-maximized="1"
     inkscape:current-layer="layer1" />
  <defs
     id="defs2" />
  <g
     inkscape:label="Capa 1"
     inkscape:groupmode="layer"
     id="layer1">';
	foreach(@mapa) {
		my %area=%{$_};
			if($area{shape} eq 'poly') {
				@coords=split(/, */, $area{coords});
				my @c;
				for(my $i=0; $i<=$#coords;$i=$i+2) {
					push(@c, "$coords[$i],$coords[$i+1]");
				}
				print ' <path
       style="fill:none;stroke:#000000;stroke-width:0.264583px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"'."\n";
			   print "d=\"M ".join(" ", @c)." z\"\n";
			   if (exists($mapa{id})) {
				   print "id=\"${mapa{id}}\"\n";
			   }
			   print " />\n";
			}
		}
	print '</g>
</svg>';

} elsif ($formato eq 'html') {
	print "<map><!--FIXME: se han perdido los atributos del mapa-->\n";
	foreach(@mapa) {
		print "\t<area \n";
		my %area=%{$_};
		foreach(keys(%area)){
			print "\t\t$_=\"$area{$_}\"\n";
		}
	}
	print "</map>\n";
} elsif ($formato eq 'txt') {
	print Dumper @mapa;
}
