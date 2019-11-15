#!/usr/bin/perl -w

my $sec=0;

if (@ARGV && $ARGV[0] eq '-s') {
	$sec=1;shift;
}

my $borraInfo = 0;
if (@ARGV && $ARGV[0] eq '-b') {
	$borraInfo=1;shift;
}

if (@ARGV && $ARGV[0] eq '-h') {
	my $nombre="gtd2txt.pl";

	print <<HELP;
* $nombre
	* USO
		$nombre -h

		$nombre [-s|b] [fichero.gtd]

	* DESCRIPCIÓN
		Convierte la entrada estándar (o fichero.gtd) en un fichero de texto.

		Mantiene las líneas en blanco y los comentarios (^#.*).

		Convierte los proyectos en un esquema tabulado.

	* OPCIONES
		* -s
			La salida es compatible con el formato *.sec (secciones). Los títulos
			empiezan por "* " y los párrafos están separados por dobles retornos.

		* -b
			Borra los principios de texto 'INFO: ', 'TODO: ', 'WAIT: ' y 'DONE: '.
HELP
	exit 0;

}
my $inicio_titulo= ($sec) ? "* " : "";
my $retorno= ($sec) ? "\n\n" : "\n";

my @proyectos_anteriores=();
while(<>) {
	chomp;s/\r//;
	if($_=~/^#/ || $_ eq "") {
		print "$_\n";	
	} else {
		my($proyectos,$resto)=split("\t",$_,2);
		my @proyectos = split("\/", $proyectos);
		my $espacio = imprimeProyecto(\@proyectos_anteriores, \@proyectos);
		if($borraInfo) {
			$resto=~s/(INFO|DONE|WAIT|TODO|DELAYED): //;
		}
		print "$espacio$resto$retorno";
		@proyectos_anteriores = @proyectos;
	}
}
#-------------------------------------------------------------------------------
sub imprimeProyecto {
#-------------------------------------------------------------------------------
	my ($anterior,$actual)=@_;
	my $espacio='';

	my $diferente=0;
	my $cont=0;
	while($#$actual>=$cont) {
		my $ahora=$$actual[$cont];
		my $antes='';
		if($#$anterior>=$cont) {
			$antes=$$anterior[$cont];
		}

		if($ahora ne $antes || $diferente) {
			print "$espacio$inicio_titulo$ahora\n";
			$diferente=1;
		}
		$espacio.="\t";
		$cont++;
	} 
	return $espacio;
}
#-------------------------------------------------------------------------------
