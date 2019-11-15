#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
sub help {
	print <<'EOHELP';
* print_r_prepara.pl 
	* Descripción
		Genera las sentencias necesarias para que un programa en php saque el valor de una lista de variables.
		
		De esta manera es más sencillo depurar un programa.		
	* Uso	
		Dentro de vim se escriben las variables una por línea, se seleccionan visualmente y se invoca el progama mediante
		> :!print_r_prepara [-e|p]
	* Opciones
		- -h :: Muestra esta ayuda.
		- -e :: Saca las variables en el log de error del servidor de páginas web.
		- -p :: Saca las variables con el código del documento. :: Es la opción por defecto.
		- -o :: Saca las variables usando la función otros/globales.php::pr();
EOHELP
}
#-------------------------------------------------------------------------------
sub lista_variables {
#-------------------------------------------------------------------------------
	my @variables;
	while(<>) {
		chomp;s/\r//;
		chomp;
		s/^[ \t]*//;
		$nombre=$_;
		$nombre=~s/['"]//g;
		push @variables,"'$nombre' => \$$_"; 
	}
	return join(", ", @variables);
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------

if ($#ARGV > -1 && $ARGV[0] eq '-h') {
	help;
} elsif ($#ARGV > -1 && $ARGV[0] eq '-e') {
	shift;
	print "error_log(print_r(array(".lista_variables()."), true));\n";
} elsif ($#ARGV > -1 && $ARGV[0] eq '-o') {
	shift;
	print "pr(array(".lista_variables()."), 'xxx_nombre', 'xxx_funcion');\n";
} else { # opción -p
	print "echo \"<pre>\".print_r(array(".lista_variables()."), true).\"</pre>\";\n";
}
