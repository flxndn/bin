#!/usr/bin/perl -w

#------------------------------------------------------------------------------
if (@ARGV && $ARGV[0] eq '-h') {
	print <<HELP;
* wait2todo.pl

	* Uso
		> wait2todo.pl -h
		> wait2todo.pl [archivo]

	* Descripción
		Convierte las líneas que contengan la cadena:
		> WAIT YYYY-MM-DD
		con 
		> YYYY-MM-DD 
		la fecha en formato
		japonés, en los que esta fecha sea menor o igual a la
		fecha actual a la cadena
		> TODO: YYYY-MM-DD

		Las líneas que no encajan las saca igual.
HELP
	exit 0;
}

while(<>) {
	chomp;s/\r//;
	if(/WAIT [0-9]{4}-[0-9]{2}-[0-9]{2}/) {
		$l=$_;
		$l=~s/.*WAIT ([0-9]{4}-[0-9]{2}-[0-9]{2}).*/$1/;
		my($ano,$mes,$dia)=split("-",$l);
		
		my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
			=localtime(time);	
		
		if( 372*($ano-(1900+$year)) + 31*($mes-(1+$mon)) + ($dia - $mday) <= 0 ) {
			s/WAIT /TODO: /;
		}
	}
	print "$_\n";
}
