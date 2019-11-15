#!/usr/bin/perl -w

my $entrada="{{cita libro|título=Caos|apellidos=Gleick|nombre=James|año=1990|página=34|isbn=3q344}}";
my $salida= "{{Harvnp|Gleick|1990|p=34}}";

#-------------------------------------------------------------------------------
sub help{
	my $in=$entrada;
	my $out=$salida;
	$in=~s/([{}])/\\$1/g;
	$out=~s/([{}])/\\$1/g;
#-------------------------------------------------------------------------------
	print "* wp_libro2harvard.txt
	Si en la entrada estándar hay un elemento de la wikipedia como cita libro, cita web y otros, como

	> $in

	genera una Ficha:Harvnp como

	> $out

	* Opciones
		* -h
			Muestra esta ayuda.
		* -t
			Muestra ejemplos de cadena de entrada y salida.
		* -T
			Traduce nombres de campos del inglés al español.
		* -p
			Genera la plantilla Harvnp.

			Es la opción por defecto.
	
			Elimina el texto anterior y posterior a la plantilla.

			Debe usarse para una sóla plantilla.
		* -c
			Compacta los espacios entre los nombres, los iguales y los separadores de campos.
		* -e 
			Expande los espacios entre los nombres, los iguales y los separadores de campos.
		* -E 
			Expande con un campo en cada línea.
		* -j 
			Une los libros en una única línea.
		* -v 
			Pone los apellidos en versalita.
		* -V
			Quita las plantillas versalita de los apellidos.
	* Errores
		- Si no hay apellidos pero sí apellidoseditor debería utilizar éste, pero no lo hace.
		- Si hay espacio tras el año lo mantiene.
	\n";
}
#-------------------------------------------------------------------------------
sub traduce{
#-------------------------------------------------------------------------------

my %dic = (
		'cite book' => 'cita libro',
		'cite journal' => 'cita publicación',
		'\| *authorlink *=' => '|enlaceautor=',
		'\| *authorlink1 *=' => '|enlaceautor=',
		'\| *date *=' => '|fecha=',
		'\| *edition *=' => '|edición=',
		'\| *editor-first *=' => '|nombre-editor=',
		'\| *editor-last *=' => '|apellidos-editor=',
		'\| *editor2-first *=' => '|nombre-editor2=',
		'\| *editor2-last *=' => '|apellidos-editor2=',
		'\| *editor3-first *=' => '|nombre-editor3=',
		'\| *editor3-last *=' => '|apellidos-editor3=',
		'\| *editor4-first *=' => '|nombre-editor4=',
		'\| *editor4-last *=' => '|apellidos-editor4=',
		'\| *editor5-first *=' => '|nombre-editor5=',
		'\| *editor5-last *=' => '|apellidos-editor5=',
		'\| *editor6-first *=' => '|nombre-editor6=',
		'\| *editor6-last *=' => '|apellidos-editor6=',
		'\| *editor7-first *=' => '|nombre-editor7=',
		'\| *editor7-last *=' => '|apellidos-editor7=',
		'\| *editor8-first *=' => '|nombre-editor8=',
		'\| *editor8-last *=' => '|apellidos-editor8=',
		'\| *editor9-first *=' => '|nombre-editor9=',
		'\| *editor9-last *=' => '|apellidos-editor9=',
		'\| *editor-link *=' => '|enlace-editor=',
		'\| *first *=' => '|nombre=',
		'\| *first1 *=' => '|nombre=',
		'\| *first2 *=' => '|nombre2=',
		'\| *first3 *=' => '|nombre3=',
		'\| *issue *=' => '|número=',
		'\| *journal *=' => '|publicación=',
		'\| *last *=' => '|apellidos=',
		'\| *last1 *=' => '|apellidos=',
		'\| *last2 *=' => '|apellidos2=',
		'\| *last3 *=' => '|apellidos3=',
		'\| *location *=' => '|ubicación=',
		'\| *page *=' => '|página=',
		'\| *pages *=' => '|páginas=',
		'\| *publisher *=' => '|editorial=',
		'\| *series *=' => '|serie=',
		'\| *title *=' => '|título=',
		'\| *volume *=' => '|volumen=',
		'\| *accessdate *=' => '|fechaacceso=',
		'\| *year *=' => '|año='
		);
	while(<>) {
		foreach $key (keys %dic) {
			s/$key/$dic{$key}/g;
		}
		print; 
	}
}
#-------------------------------------------------------------------------------
sub compacta{
#-------------------------------------------------------------------------------
	while(<>){
		s/\{\{ */{{/g;
		s/ *}}/}}/g;
		s/ *\|/|/g;
		s/\| */|/g;
		s/ *\=/=/g;
		s/\= */=/g;
		print;
	}
}
#-------------------------------------------------------------------------------
sub expande{
#-------------------------------------------------------------------------------
	while(<>){
		s/\{\{/{{ /g;
		s/}}/ }}/g;
		s/\|/ | /g;
		s/(\| [a-z\-]*)=/$1 = /g;
		print;
	}
}
#-------------------------------------------------------------------------------
sub expande_lineas{
#-------------------------------------------------------------------------------
	while(<>){
		s/\| */\n\t| /g;
		print;
	}
}
#-------------------------------------------------------------------------------
sub junta_lineas{
#-------------------------------------------------------------------------------
	@lineas=<>;
	chomp(@lineas);
	$l=join("",@lineas);
	$l=~s/\n//gs;
	$l=~s/\t//gs;
	$l=~s/\*/\n\*/gs;
	print "$l\n";;
}
#-------------------------------------------------------------------------------
sub apellidos_en_versalitas{
#-------------------------------------------------------------------------------
	while(<>) {
		s/apellidos([^=]*)=( *)([^|}]*)( *)/apellidos$1=$2\{\{versalita\|$3\}\}$4/g;
		print;
	}
}
#-------------------------------------------------------------------------------
sub quita_versalitas{
#-------------------------------------------------------------------------------
	while(<>) {
		s/\{\{versalita\|([^}]*)}}/$1/gi;
		print;
	}
}
#-------------------------------------------------------------------------------
if( @ARGV >0 && $ARGV[0] eq "-h"){ help; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-t"){ print "$entrada\n"; print "$salida\n"; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-T"){ shift;traduce; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-c"){ shift;compacta; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-e"){ shift;expande; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-E"){ shift;expande_lineas; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-j"){ shift;junta_lineas; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-v"){ shift;apellidos_en_versalitas; exit 0; }
if( @ARGV >0 && $ARGV[0] eq "-V"){ shift;quita_versalitas; exit 0; }

my @lineas=<>; 
chomp(@lineas);

my $lineas=join("", @lineas);
$lineas=~s/[^{]*\{\{//;
$lineas=~s/}}[^}]*//;
my @campos=split(/[ \t]*\|[ \t]*/,$lineas);
shift(@campos);
my %datos;
my @autores;
my $posicion;
my $ano;
for(@campos) {
	my ($key,$value)=split(/[ \t]*=[ \t]*/,$_);
	$value=~s/^ *//;
	$value=~s/ *$//;
	if ($key=~/^autor$/)		{$autores[0]=$value;}
	if ($key=~/^apellidos?$/)	{$autores[0]=$value;}
	if ($key=~/^apellidos?2$/)	{$autores[1]=$value;}
	if ($key=~/^apellidos?3$/)	{$autores[2]=$value;}
	if ($key=~/^apellidos?4$/)	{$autores[3]=$value;}
	if ($key=~/^capítulo$/ 
		and !defined $posicion)		{$posicion="loc=«$value»";}
	if ($key=~/^páginas$/)		{$posicion="pp=$value";}
	if ($key=~/^página$/)		{$posicion="p=$value";}
	if ($key=~/^año$/)			{$ano="$value";}
}
print "{{Harvnp|".join("|",@autores)."|$ano";
if ($posicion){ print "|$posicion";}
print "}}\n";

