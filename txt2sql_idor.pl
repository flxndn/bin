#!/usr/bin/perl -w

if ($#ARGV >-1 && $ARGV[0] eq "-h") {
	$programa=$0;
	$programa=~s/.*\///;
print <<HELP;
* $programa
	* Uso
		> $0 [fichero]
		> $0 -h
	
	* Descripción
		Para un fichero con formato
		> A;tag_txt;fecha hora;valor;MANUAL 
		genera una sentencia sql para su inserción en Datos<año>

		Fecha tiene que estar en formato dd/mm/AAAA HH:MM:SS.

	* Opciones
		* -h
			Muestra esta ayuda.
		* -t. --tag
			Convierte los tag de texto en tag numéricos que usa Idor.

HELP
	exit;
}
my $flagtag=0;

while(@ARGV) {
	if ($ARGV[0] eq '-t' or $ARGV[0] eq '-tag') {
		$flagtag=1;
	}
	shift;
}

my $calidad = 103;
while(<>) {
	chomp; s/\r//;
	my($kk, $tag, $fecha, $valor, $kk2) = split(";");

	my ($ano, $outfecha);

	if ($fecha =~ /^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$/) {
		$ano=substr $fecha, 0, 4;
		$outfecha = $fecha;
	} elsif  ($fecha =~ /^\d\d\/\d\d\/\d{4} \d\d:\d\d:\d\d/) {
		$ano=substr $fecha, 6, 4;
		my $dia=substr $fecha, 0, 2;
		my $mes=substr $fecha, 3, 2;
		my $time=substr $fecha, 11, 8;
		$outfecha = "$ano-$mes-$dia $time";
	} else {
		die "Formato de fecha ($fecha) no reconocido.";
	}

	$valor=~s/,/./;

	if($flagtag == 1 ) {
		$idtag = `tag2id.sh $tag`;
		chomp $idtag;
	} else {
		$idtag = $tag;
	}

	print "INSERT INTO Datos$ano (IdTag,Fecha,Valor,NumCalidad) values ($idtag, '$outfecha', $valor, $calidad)\n";
}
