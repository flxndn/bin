#!/usr/bin/perl

my $indice;

while(<>) {
	chomp;s/\r//;
	my @campos=split("\t");

	if (!defined $indice or $indice ne $campos[0]) {
		$indice = $campos[0];
		print "* $indice\n";
	}	
	shift(@campos);
	print "\t- ".join(" :: ", @campos)."\n";
}
