#!/usr/bin/perl -w


#-------------------------------------------------------------------------------
sub help {
#-------------------------------------------------------------------------------
	print <<HELP;
* buffer_historicos_sql.pl
	* Uso
		> buffer_historicos_sql -t tag -i fecha_inicio -f fecha_final
		
		El formato de las fechas es "dia/mes/año hora:minuto:segundo" con dos 
		dígitos por campo.
	* Descripción
		Genera una cadena sql para buscar un tag entre dos fechas.
	* Opciones
		- -h :: Muestra esta ayuda
HELP
}
#-------------------------------------------------------------------------------

if ($#ARGV == -1 ) {
	help;
	die "Error. Sin argumentos.";
}

if ($ARGV[0] eq "-h" ) {
	help;
	exit;
}

my ($tag, $ini, $fin);

if ($ARGV[0] eq "-t" ) { $tag=$ARGV[1]; shift;shift; }
if ($ARGV[0] eq "-i" ) { $ini=$ARGV[1]; shift;shift; }
if ($ARGV[0] eq "-f" ) { $fin=$ARGV[1]; shift;shift; }

print "SELECT * FROM buffer_historicos WHERE tag='$tag' AND fechahora >= to_date('$ini', 'DD/MM/YY HH24/MI/SS') AND fechahora <= to_date('$fin', 'DD/MM/YY HH24/MI/SS')\n";

