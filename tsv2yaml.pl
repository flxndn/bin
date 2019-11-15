#!/usr/bin/perl -w

use List::Util qw[min max];

#-------------------------------------------------------------------------------
sub help {
#-------------------------------------------------------------------------------
	print <<HELP;
* tsv2yaml.pl
	* Uso
		> tsv2yaml.pl [-d delimiter] [-f|--fields fields] [fichero]
		> tsv2yaml.pl -h
	* Options
		* -h:: Show this help
		* -f|--fields fields::Use the list fields as the name or fields.::Name of the fields are sepparated with commas.
		* -d delimiter::Specifies de delimiter.::If none is used tab is used.
	* Descripción
		Para la entrada estándar o fichero de tipo tsv (tab separated value) 
		donde la primera línea es el nombre de los campos, saca por salida 
		estándar los datos en formato yaml.
HELP
}
#-------------------------------------------------------------------------------

my $campos="";
my $delimiter="\t";

if ($#ARGV != -1 && $ARGV[0] eq "-h" ) {
	help;
	exit;
}

if ($#ARGV != -1 && $ARGV[0] eq "-d") {
	$delimiter=$ARGV[1];
	shift;shift;
}

if ($#ARGV != -1 
	&& ($ARGV[0] eq "-f" || $ARGV[0] eq "--fields")) {

	$campos=$ARGV[1];
	$campos=~s/,/$delimiter/g;
	shift;shift;
}

if(! $campos) {
	$campos=<>;
	chomp $campos;
	$campos=~s/\r//; 
}

my @campos=split($delimiter,$campos);

while(<>) {
	chomp;s/\r//;
	my $datos=$_;
	my @datos=split($delimiter,$datos);
	
	my $i=0;
	for ($i=0;$i<=min($#datos,$#campos);$i++ ) {
		my $pre = $i==0 ? "- " : "  ";
		print $pre.$campos[$i].": ".$datos[$i]."\n";
	}
}
