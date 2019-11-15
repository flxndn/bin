#!/usr/bin/perl -w
use utf8;

#-------------------------------------------------------------------------------
sub fhelp {
#-------------------------------------------------------------------------------
	my $nombre="wp_bibtext2cita_libro.pl";
	print "* $nombre
	* Uso
		> $nombre [fichero_bibtext]
	* Descripción
		Convierte el formato bibtext de la entrada estándar 
		[ o de fichero_bibtext ] y saca por salida estándar en formato 
		[[https://es.wikipedia.org/wiki/Plantilla:Cita_libro Plantilla:Cita libro]].
	* Opciones
		* -h
			Muestra esta ayuda.
	* Errores
		No funciona para eñes o ues con diéresis.
	\n";
}
#-------------------------------------------------------------------------------
sub traduce{
#-------------------------------------------------------------------------------

# Ejemplo bibtext
#@book{luna2005lugar,
#  title={El Lugar de La Mancha es --: el Quijote como un sistema de distancias/tiempos},
#  author={Luna, F.P. and Nieto, M.F. and Verdaguer, S.P. and Bravo, G. and Alfonso, J.M.},
#  isbn={9788474917802},
#  series={sin colecci{\'o}n},
#  url={https://books.google.es/books?id=W4YPqvPAIFEC},
#  year={2005},
#  publisher={Editorial Complutense}
#}
}
#-------------------------------------------------------------------------------
if( @ARGV >0 && $ARGV[0] eq "-h"){ fhelp(); exit 0; }

my @secciones;

my %tildes=('a' => 'á',
			'e' => 'é',
			'i' => 'í',
			'o' => 'ó',
			'u' => 'ú',
			'A' => 'Á',
			'E' => 'É',
			'I' => 'Í',
			'O' => 'Ó',
			'U' => 'Ú' );

my %dic= ( 'title' => 'título',
			'series' => 'serie',
			'year' => 'año',
			'number' => 'número',
			'author' => 'autor',
			'publisher' => 'editorial');

while(<>) {
	chomp;s/\r//;
	if(/=/) {
		my ($campo, $valor) = split("=", $_, 2);
		$campo=~s/^ *//;
		
		$campo = exists $dic{$campo} ? $dic{$campo} : $campo;

		for my $letra (keys %tildes) {
			$valor=~s/{\\'$letra}/$tildes{$letra}/g;
		}
		$valor=~s/{\\~n}/ñ/g;

		$valor=~s/{//;
		$valor=~s/},*//;

		if($campo eq 'autor'){
			my $contador=1;
			@autores=split(' and ', $valor);
			foreach(@autores) {
				my ($apellidos, $nombre)=split(", ");
				my $num=$contador==1 ? '' : $contador;

				push @secciones, "apellidos$num=$apellidos";
				push @secciones, "nombre$num=$nombre";
				$contador++;
			}
		} else {
			push @secciones, "$campo = $valor";
		}
	}
}
print "{{ cita libro | ". join(" | ", @secciones). " }}\n";

