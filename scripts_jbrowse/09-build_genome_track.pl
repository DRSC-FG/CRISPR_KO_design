#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;  


#perl scripts_jbrowse/09-build_genome_track.pl -path=data


# GLOBALS.    
my $DATA_DIR; 
my $usage = "Usage:
  $0 -path input_spieces_data_dir

Quick Help:
  -path  <data dir>   ";



# Check flags.
GetOptions(
	'path=s'  => \$DATA_DIR,
	help    => sub { pod2usage( $usage ) }
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_DIR;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#   Developed by Chuck Roesel, 2012-2013
# Notes added by Verena Chung, 2016-2018
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# Creates genome track (as reference) for JBrowse.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# for multiple ref seqs use diff data folders: https://github.com/GMOD/jbrowse/issues/528

chdir 'JBrowse-1.13.0';



#my $command = 'bin/prepare-refseqs.pl --fasta ../gambiae/fasta_files/sequences.fa --out data/';
#my $command = 'JBrowse-1.13.0/bin/prepare-refseqs.pl --fasta '.$DATA_DIR.'/input/genomic.fa --out JBrowse-1.13.0/data/';
my $command = 'bin/prepare-refseqs.pl --fasta '.$DATA_DIR.'/input/genomic.fa --out '.$DATA_DIR.'/output_jbrowse/';
say "command:\n";
say $command;
say "\n";
for (`$command`) {
	print;
}

chdir '../';
