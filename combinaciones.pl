#!/usr/bin/perl -w
use utf8;

#-------------------------------------------------------------------------------
sub combinaciones {
#-------------------------------------------------------------------------------
	my $n = scalar(@_);
	my @parejas=@_;
	my $primero = shift(@parejas);
	foreach(@parejas) {
		print "$primero:$_\n";
	}
	if(scalar(@parejas) >1) {
		combinaciones(@parejas);
	}
}
#-------------------------------------------------------------------------------
if (scalar(@ARGV) == 1) {
	@grupo = split(/ /, $ARGV[0]);
} else {
	@grupo = @ARGV;
}
combinaciones(@grupo);
