#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use POSIX 'log10';
use Getopt::Long;
use Pod::Usage;

# GLOBALS.
my $DATA_DIR;
my $usage = "Usage:
  $0 -in input_species

Quick Help:
  -path  <base of data dir>'";

# Check flags.
GetOptions(
    'path=s'  => \$DATA_DIR,
	help    => sub { pod2usage( $usage ) } 
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_DIR;
$DATA_DIR =~ s/\///;

print  "+Reading: constants/p_values.txt\n";
my $pvalues = load_pssm( 'constants/p_values.txt' );

# Create temp file of unique CRISPR designs from seed_scores.txt.

print  "+Writing (temp) uniq_guides.txt \n";
`cut -f2 $DATA_DIR/output/seed_scores.txt | sort | uniq > $DATA_DIR/output/uniq_guides.txt`;

# Open files for reading and writing:
#	1 - (r) text file with CRISPR sequences to score
#	2 - (w) text file with CRISPR sequences and their efficiency scores
print  "+Writing  ". $DATA_DIR . "/output/eff_scores.txt\n";
open( SCORES, '>', $DATA_DIR . '/output/eff_scores.txt' ) or die $!;
local $, = "\t";

print  "+Reading (temp) uniq_guides.txt \n";
open( CRISPRS, '<', $DATA_DIR.'/output/uniq_guides.txt' ) or die $!;
while (my $crispr = <CRISPRS>) {
	chomp $crispr;
	say SCORES $crispr, score_match( $crispr, $pvalues );
}
close SCORES;
close CRISPRS;

# Remove temp file.
#print  "+not Removing (temp) uniq_guides.txt \n";
#`rm uniq_guides.txt`;

# Returns matrix values from given file.
sub load_pssm {
	my ( $file ) = @_;
	my $matrix;
	
	open( SCORES, "<", $file ) or die $!;
	while (<SCORES>) {
		chomp;
		my @columns = split "\t";
		my $base = $columns[0];
		
		for ( my $position = 1; $position < scalar @columns; $position++ ) {
			$matrix->{$base}{$position} = $columns[$position];
		} 
	}
	close SCORES;

	return $matrix;
}

# Score given CRISPR ($match) against the given PSSM ($matrix). 
sub score_match {
	my ( $match, $matrix ) = @_;

	my $score = 1;
	my @bases = split( '', $match );
	my $position = 1;

	foreach my $base ( @bases ) {
		my $pos_score = $matrix->{$base}{$position++};
		$score *= $pos_score if defined $pos_score;
	}

	# Format score to 2 sigfigs after decimal point.
	return sprintf( '%.2f', log10( $score ) * -1 );
}
