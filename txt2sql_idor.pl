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

	* Opciones
		* -h
			Muestra esta ayuda.

HELP
	exit;
}

my $calidad = 103;
while(<>) {
	chomp; s/\r//;
	my($kk, $tag, $fecha, $valor, $kk2) = split(";");

	my $ano = $fecha;
	$ano=~s/.*\///;
	$ano=~s/ .*//;

	$valor=~s/,/./;

	$idtag = $tag; # TODO: buscar el tag numérico

	print "INSERT INTO DATOS$ano (IdTag,Fecha,Valor,NumCalidad) values ($idtag, '$fecha', $valor, $calidad)\n";
}
