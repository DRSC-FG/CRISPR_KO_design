#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;
use lib './modules';
use JbrowseUtils;


# GLOBALS.    
my $DATA_DIR; 
my $usage = "Usage:
  $0 -path=input_species

Quick Help:
  -path  <data dir>   ";


# Check flags.
GetOptions(
	'path=s'  => \$DATA_DIR,
	help    => sub { pod2usage( $usage ) }
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_DIR;





# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Developed by Chuck Roesel, 2012-2013
#   Updated by Verena Chung, 2016-2018
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# Generate annotation labels for each track in JBrowse.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

chdir 'JBrowse-1.13.0';

# Generate names with JBrowse's generate-names.pl script. hashBits has been set
# to 16 to fix "Error reading from name store" error.
my $command = 'bin/generate-names.pl --hashBits 16 --out --tracks RNA '. $DATA_DIR.'/output_jbrowse/';
say $command;
for (`$command`) {
	print;
}

chdir '../';
