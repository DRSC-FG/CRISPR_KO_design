#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Pod::Usage;

# GLOBALS.
my $DATA_PATH;
my $fastafile='';
my $species='tick';

my $usage = "Usage:
  $0 -in data directory


Quick Help:
  -in	'aegypti', 'albopictus', or 'gambiae'";

# Check flags; use default values if none given.
GetOptions(
	'-in=s' => \$DATA_PATH,
	'-fasta=s' => \$fastafile,
	'-species=s' => \$species,
	help    => sub { pod2usage($usage) }
) or pod2usage(2);
pod2usage($usage) and exit unless $DATA_PATH;
$DATA_PATH =~ s/\///;

#my $sequences = read_fasta( $DATA_PATH . '/input/GCF_016920785.2_ASM1692078v2_genomic.fna' );
my $sequences = read_fasta( $fastafile );

# Set up parameters for BLAST command.
my $db     = $DATA_PATH . '/blast_dbs/' . $species .'/'.$species;
;
my $query  = $DATA_PATH . '/output/unique_kmers.fasta';
my $format = 6;
my $size   = 10;

print "db:".$db;
print "\n";

blast_crispr({
	db 			=> $db, 
	query 		=> $query,
	format 		=> $format,
	word_size 	=> $size
});

# Returns list of sequences from given file, assuming it's in FASTA format.
sub read_fasta {
	my ( $file ) = @_;
	my %sequences;
	say ("+ Reading :" . $file ."\n");
	# Open file, change EOL, then throw away first line, which is just ">".
	open( FASTA, '<', $file ) or die $!;
	local $/ = '>';
	my $useless = <FASTA>;
	while (<FASTA>) {
		chomp;
		if ( /(.*?)\s.*?$(.*)/ms ) {
			my $chrom = $1;
			my $sequence = $2;
			$sequence =~ s/\s//g;
			$sequences{$chrom} = uc $sequence;
		}
	}
	close FASTA;
	return \%sequences;
}

# BLAST CRISPR and print results to report file; also returns list of off-targets.
sub blast_crispr {
	my ( $args ) = @_;

	my $cmd = 'blastn -db ' . $args->{db}
		. ' -query ' . $args->{query}
		. ' -outfmt ' . $args->{format}
		. ' -word_size ' . $args->{word_size}
		. ' -num_threads 4 -evalue 100 -gapopen 5 -gapextend 2 -dust yes -task megablast';
	say $cmd;
	
	say ("+ Writing :" . $DATA_PATH . "/output/blast_report.txt \n" );
	say ("+ Command :" . $cmd . " \n" );
	open( REPORT, '>', $DATA_PATH . '/output/blast_report.txt' ) or die $!;
	say REPORT join( "\t", 'subject_chrom', 'start', 'end', 'q_start', 'q_end',
		'query_seq', 'strand', '1-nt_upsteam', 'subject_seq', 'alignment',
		'OT1', 'OT2', 'OT_pam', 'OT_type' );	

	open( BLAST, "$cmd |" );
	while (<BLAST>) {
		chomp;
		next if /^#/;

		my (
			$query_seq, $chrom, $pident, $len, $mismatches, 
			$gaps, $q_start, $q_end, $s_start, $s_end
		) = split;
		my ( $eight, $unique, $pam, $strand ) = ( 0, 0, 0, '+' );
		$chrom =~ s/lcl\|//g;

		my $padded_start = sprintf( '%08d', $s_start - $q_start + 1 );
		my $padded_end   = sprintf( '%08d', $s_end + 23 - $q_end );
		if ( $s_start > $s_end ) {
			$strand = '-';
			$padded_start = sprintf( '%08d', $s_start + $q_start - 1 );
			$padded_end   = sprintf( '%08d', $s_end - ( 23 - $q_end ) );
		}
		my $padded_qs = sprintf( '%02d', $q_start );
		my $padded_qe = sprintf( '%02d', $q_end );
		
		my ( $subject_seq, $prev_base ) = 
			get_subject_seq( $padded_end, $chrom, $padded_start );

		if ( $subject_seq =~ /[ATGC]{21}GG/ ) {
			my $alignment = '';
			my @subject_pos = split( '', $subject_seq );
			my @query_pos   = split( '', $query_seq );
			for ( my $i = 0; $i < scalar @subject_pos; $i++ ) {
				$alignment .= $subject_pos[$i] eq $query_pos[$i] ? '|' : 'X';
				
				if ( $subject_pos[$i] ne $query_pos[$i] ) {
					$eight++ if $i < 8;
					$unique++ if ( $i >= 8 and $i < 20 );
					$pam++ if $i >= 20;
				}
			}
			
			my $ot_type = 'Off-Target';
			if ( $eight + $unique <= 5 ) {
				if ( $eight + $unique + $pam == 0 ) {
					$ot_type = 'On-Target';
				}
				say REPORT join( "\t", 
					$chrom, $padded_start, $padded_end, $padded_qs, $padded_qe, 
					$query_seq, $strand, $prev_base, $subject_seq, $alignment,
					$eight, $unique, $pam, $ot_type 
				);
			}
		}
	}
	close BLAST;
	close REPORT;
}

# Returns alignment sequence ($subject) and base 1-nt upsteam ($prev_base) from DB.
sub get_subject_seq {
	my ( $end, $id, $start ) = @_;
	
	my ( $subject, $prev_base );
	if ( exists $sequences->{$id} ) {
		if ( $start < $end ) {
			$subject = substr( $sequences->{$id}, $start - 2, 24 );
		}
		else {
			$subject = substr( $sequences->{$id}, $end - 1, 24 );
			$subject = reverse $subject;
			$subject =~ tr/ACGT/TGCA/;
		}
		$prev_base = substr( $subject, 0, 1 );
		$subject   = substr( $subject, 1, 23 ); 
	}
	return ( $subject, $prev_base );
}
