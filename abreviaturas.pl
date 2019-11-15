#!/usr/bin/perl -w

$fichero="$ENV{'HOME'}/bin/abreviaturas.tsv";

my %abreviaturas;

open FILE, $fichero or die $!;
while(<FILE>) {
	    chomp;s/\r//;
		my ($abreviatura,$significado)=split("\t");
		$abreviaturas{$abreviatura}=$significado;
}
close(FILE);

while(<>) {
	for my $abreviatura (keys %abreviaturas) {
		$_=~s/\b$abreviatura\b/<acronym title="$abreviaturas{$abreviatura}">$abreviatura<\/acronym>/g;
	}
	print $_;
}

