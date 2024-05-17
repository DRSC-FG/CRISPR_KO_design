#!/usr/bin/perl
use strict;
use warnings;
use lib './modules';
use JbrowseUtils;
use Getopt::Long;
use Pod::Usage;  


# GLOBALS.    
my $DATA_DIR; 
my $usage = "Usage:
  $0 -path input_species

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
# Creates gene and transcript (RNA) tracks for JBrowse.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

chdir 'JBrowse-1.13.0';

# Build tracks with JBrowse's flatfile-to-json.pl script, where:
# 	1 - gff3 input
# 	2 - trackLabel
# 	3 - subfeatureClass
# 	4 - cssClass
# 	5 - autocomplete
# 	6 - arrowheadClass

print "-------------------------------------\n";
print "-step 1\n\n";

JbrowseUtils::formatTrack( 
	''.$DATA_DIR.'/jbrowse/genes.gff3', 'Genes', 
	'generic_part_a', 'feature5', 
	'label', 'transcript-arrowhead' , $DATA_DIR.'/output_jbrowse' 
);

print "-------------------------------------\n";
print "-step 2 \n\n";


JbrowseUtils::formatTrack2( 
	''.$DATA_DIR.'/jbrowse/transcripts.gff3', 'RNA', 
	'generic_part_a', 'generic_parent', 
	'label', 'none' , $DATA_DIR.'/output_jbrowse/'
);


print "done";

chdir '../';
