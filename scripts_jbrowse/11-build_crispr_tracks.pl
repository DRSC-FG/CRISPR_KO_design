#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use lib './modules';
use JbrowseUtils;



# GLOBALS.    
my $DATA_DIRR; 
my $usage = "Usage:
  $0 -path input_species

Quick Help:
  -path  <data dir>   ";



# Check flags.
GetOptions(
	'path=s'  => \$DATA_DIRR,
	help    => sub { pod2usage( $usage ) }
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_DIRR;

print "Input Path:".$DATA_DIRR.'\n';


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Developed by Chuck Roesel, 2012-2013
#   Updated by Verena Chung, 2016-2018
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# Creates CRISPR tracks for JBrowse.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

chdir 'JBrowse-1.13.0';
# Currently only using one crispr track. Add more to this list if necessary
my @gff3s = qw/
	designs
/;

# For each gff3 file of given stringency and PAM, build tracks with JBrowse's
# flatfile-to-json.pl script.
for my $gff3 ( @gff3s ) {

	# Params:
	# 	1 - gff3_file
	# 	2 - trackLabel
	# 	3 - subfeatureClass
	# 	4 - cssClass 
	# 	5 - autocomplete
	# 	6 - arrowheadClass
	JbrowseUtils::formatTrackCrispr( 
		''.$DATA_DIRR.'/jbrowse/designs.gff3', 
        $gff3, 'generic_part_a', 'generic_part_a', 
		'none', 'none' , $DATA_DIRR.'/output_jbrowse' 
	);
}

chdir '../';
