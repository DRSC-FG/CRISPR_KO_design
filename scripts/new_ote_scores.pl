#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;

# GLOBALS.
my $DATA_PATH;
my $usage = "Usage:
  $0 -in input_species [-len kmer_length]

Quick Help:
  -in	'aegypti', 'albopictus', or 'gambiae'";

# Check flags; use default values if none given.
GetOptions(
	'in=s' => \$DATA_PATH,
	help   => sub { pod2usage( $usage ) }
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_PATH;
$DATA_PATH =~ s/\///;

print "\n+Reading:".$DATA_PATH . '/output/blast_report.txt';
print "\n+Writing:".$DATA_PATH . '/output/ote_numbers.txt';


# Create temp file of ot scores pre-processed.

my $cmd = 'tail -n +2 ' . $DATA_PATH . '/output/blast_report.txt | cut -f6,11-12,14 >  ' . $DATA_PATH .'/output/ote_numbers.txt';
`$cmd`;

# this doesn't seem to work.   pushed up to the calling slurm  job.
#$cmd = 'cut -f1,4  '. $DATA_PATH. "/output/ote_numbers.txt |sort |uniq -c |  tr -s ' ' '\t' > ". $DATA_PATH ."/output/ote_numbers_count.txt";
#`$cmd`;



# There is a case where 

my $otes;
my %offt_score_counts=();
my %ont_score_counts=();

print "\n+Reading:".$DATA_PATH . '/output/ote_numbers.txt';
open( OT, '<', $DATA_PATH . '/output/ote_numbers.txt' ) or die $!;
while (<OT>) {
	chomp;
	my ( $crispr, $ot1, $ot2, $type ) = split /\t/;

	# count how many times ('On-target and off target')
        # https://www.perlmonks.org/?node_id=11111061
        #if (! exists $score_counts{$crispr} ){
	#    $score_counts{$crispr}={'ont'=>0,'offt'=>0};
	#}

	if ($type eq 'On-Target') {
	    # create and add one to the count hash based on crispr seq
	    $ont_score_counts{$crispr}++;
	    print ("On-Target-Count". $ont_score_counts{$crispr} ."\n" );
	}
	
	
	next if $type eq 'On-Target';

	# create and add one to the count hash based on crispr seq
	$offt_score_counts{$crispr} ++;
	
	print ("offt-Target-Count:".$crispr." ". $offt_score_counts{$crispr} ."\n" );


	my $total = $ot1 + $ot2;
	if ( $total != 0 and $total < 3 ) {
		$total = 3;
	}
	$otes->{$crispr}{$total}++;
}
close OT;
while ((my $first, my $last) = each (%offt_score_counts)){
    print "OFF first +". $first ." ". $last ."\n";
}


while ((my $mycrispr, my $mycount) = each (%ont_score_counts)){
    print "ONT first +". $mycrispr ." ". $mycount ."\n";
    if (! exists $offt_score_counts{$mycrispr}){
	print "ONLY *** in ON TARGET.. No OFF Target \n";
    } 
}

my $total = keys %$otes; 



say "\n".$total . ' CRISPRs with OTE scores';

# print "\n+Removing(temp):".$DATA_PATH . '/output/ote_numbers.txt';
#g Remove temp file. Don't remove..
#`rm $DATA_PATH/output/ote_numbers.txt`;

print "\n+Writing: ".$DATA_PATH . '/output/ote_scores.txt';

open( SUMMARY, '>', $DATA_PATH . '/output/ote_scores.txt' ) or die $!;
foreach my $crispr ( keys %$otes ) {
	my $ote3 = $otes->{$crispr}{3} // 0;
	my $ote4 = $otes->{$crispr}{4} // 0;
	my $ote5 = $otes->{$crispr}{5} // 0;
	my $score = $ote3 + ( $ote4 / 10 ) + ( $ote5 / 100 );
	say SUMMARY $crispr, "\t", $score;
}


# Add Zero scores, where a score is only "On-Target" with no off Target..  
#
# Score these zero

while ((my $mycrispr, my $mycount) = each (%ont_score_counts)){
    print "ONT first +". $mycrispr ." ". $mycount ."\n";
    if (! exists $offt_score_counts{$mycrispr}){
	say SUMMARY $mycrispr, "\t0";
    } 
}



close SUMMARY;
