#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;

# GLOBALS.
my $DATA_DIR;
my $count;
my $usage = "Usage:
  $0 -in input_species

Quick Help:
  -path  <data dir>   ";


$count=0;
# Check flags.
GetOptions(
	'path=s'  => \$DATA_DIR,
	help    => sub { pod2usage( $usage ) }
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_DIR;
$DATA_DIR =~ s/\///;


my $genome  = $DATA_DIR . '/input/genomic.fa';
my $crisprs = $DATA_DIR . '/output/crispr_designs.txt';

# Tally up kmers from $genome, ranging from length 12 to 15.
my $kmers_12 = count_kmers( $genome, 12 );
my $kmers_13 = count_kmers( $genome, 13 );
my $kmers_14 = count_kmers( $genome, 14 );
my $kmers_15 = count_kmers( $genome, 15 );

my $unique = get_unique_crisprs( $crisprs );
print_fasta( $unique );

#------------------------------------------------------------------------------
# Returns list of kmers of length $kmer_len -> counts (number of occurrences).

sub count_kmers {
	my ( $input, $kmer_len ) = @_;
	my %crisprs;

	my $counta = 0;

	# Add 3 to account for PAM sequence.
	$kmer_len += 3;
	
	# Open FASTA file, change EOL to ">", then throw away first line (which is
	# just ">"). 
	print ("+ Reading :". $input);
	open( FASTA, '<', $input ) or die $!; 
	local $/ = '>';
	my $useless = <FASTA>;
	
	

	while (<FASTA>) {
	    chomp;
	    
		if ( /.*?$(.*)/ms ) {
			my $seq = $1;
			$seq =~ s/\s//g;
			$counta = 0;
			for ( my $i = 0; $i + $kmer_len <= length $seq; $i++ ) {
			        $counta = $counta +1;

				my $kmer = uc substr( $seq, $i, $kmer_len );
				my $revcom = reverse $kmer;
				$revcom =~ tr/ACGT/TGCA/;
				
				if ($counta < 40){
				print "($counta) $kmer_len => $kmer\n";
				}
				$crisprs{$kmer}++ if $kmer =~ /GG$/;
				$crisprs{$revcom}++ if $revcom =~ /GG$/;
			}
			
		}
	}
	close FASTA;
	return \%crisprs;
}

# Traverses through sequences to find kmers (and complement reverse kmers) with 
# unique ends.
sub get_unique_crisprs {
	my ( $input ) = @_;
	my $unique;
	print ("+Reading : ".$input."\n");
	open( KMERS, '<', $input ) or die $!;
	while (<KMERS>) {
		chomp;
		my ( $gene, $crispr ) = split /\t/;
		my $score = check_uniqueness( $crispr );
		if ( $score ) {
			if ( exists $unique->{ $crispr } ) {
				push @{ $unique->{$crispr}{genes} }, $gene;
			}
			else {
				$unique->{$crispr} = {'genes' => [ $gene ], 'seed' => $score };
			}
		}
	}
	close KMERS;
	return $unique;
}

# Check if given CRISPR is unique (has count of 1), starting with seed region of 12,
# followed by 13, then 14, and finally 15; if it is, print kmer to files.
sub check_uniqueness {
	my ( $input ) = @_;
	my $score;

	if ( $input =~ /[ATCG]{5}([ACGT]([ATCG]([ATCG]([ATCG]{12}[ATCG]GG))))/ ) {
		if ( defined $kmers_12->{$4} && $kmers_12->{$4} == 1 ) {
			$score = 12;
		}
		elsif ( defined $kmers_13->{$3} && $kmers_13->{$3} == 1 ) {
			$score = 13;
		}
		elsif ( defined $kmers_14->{$2} && $kmers_14->{$2} == 1 ) {
			$score = 14;
		}
		elsif ( defined $kmers_15->{$1} && $kmers_15->{$1} == 1 ) {
			$score = 15;
		}
		else {
			return;
		}
	}	
}

# Open two files for writing:
#   1 - list of unique CRISPR designs in FASTA format
#   2 - seed scores text file
# then print results.
sub print_fasta {
	my ( $unique ) = @_;

	print ("+Writing : ".  $DATA_DIR . '/output/unique_kmers.fasta' );
	print ("+Writing : ".  $DATA_DIR . '/output/seed_scores.txt' );
	open( CRISPR, '>', $DATA_DIR . '/output/unique_kmers.fasta' ) or die $!;
	open( SEED, '>', $DATA_DIR . '/output/seed_scores.txt' ) or die $!;
	while ( my ( $crispr, $info ) = each %$unique ) {
		my $genes = $info->{genes};
		my $score = $info->{seed};
		foreach my $gene ( @$genes ) {
			say SEED join( "\t", $gene, $crispr, $score );
		}
		say CRISPR '>' . $crispr .' sequence ';
		say CRISPR $crispr;
	}
	close CRISPR;
	close SEED;
}

