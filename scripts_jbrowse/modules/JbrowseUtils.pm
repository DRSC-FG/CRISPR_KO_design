#!/usr/bin/perl
package JbrowseUtils;
use warnings;
use strict;

sub formatTrack($$$$$$$) {

	my %features;
	my ( $gffOutputFile, $trackName, $childGlyph, $parentGlyph, $autocomplete, $arrowheadClass, $outDir ) =
	  @_;
	my $command =
	    "bin/flatfile-to-json.pl "
	  . "-gff $gffOutputFile -out ". $outDir."/ "
	  . "-trackLabel \"$trackName\" "
	  . "--getSubs true "
	  . "--subfeatureClasses '{\"reagent\":\"$childGlyph\", "
	  . "\"exon\":\"exon\", "
	  . "\"cds\":\"transcript-CDS\", "
	  . "\"ncRNA\":\"transcript-exon\"}' "
	  . "--cssClass $parentGlyph "
	  . "--autocomplete $autocomplete "
	  . "--arrowheadClass $arrowheadClass "
	  . "--getLabel";
	print $command, " \n ";
	for (`$command`) {
		print;
	}
}

sub formatTrackCrispr($$$$$$$) {

	my %features;
	my ( $gffOutputFile, $trackName, $childGlyph, $parentGlyph, $autocomplete, $arrowheadClass, $outDir ) =
	  @_;
	my $command =
	    "bin/flatfile-to-json.pl "
	  . "-gff $gffOutputFile -out ". $outDir."/ " 
	  . "-trackLabel \"$trackName\" "
	  . "--getSubs true "
	  . "--cssClass $parentGlyph "
	  . "--autocomplete $autocomplete "
	  . "--arrowheadClass $arrowheadClass "
	  . "--getLabel";
	print $command, " \n ";
	for (`$command`) {
		print;
	}
}

sub formatTrack2($$$$$$$) {

	my %features;
	my ( $gffOutputFile, $trackName, $childGlyph, $parentGlyph, $autocomplete, $arrowheadClass, $outDir ) =
	  @_;
	my @commands;
	push( @commands, "bin/flatfile-to-json.pl" );
	push( @commands, "-gff $gffOutputFile" );
	push( @commands, " -out ". $outDir."/ ");
	push( @commands, "-trackLabel \"$trackName\"" );
	push( @commands, "--getSubs true" );
	push( @commands, "--subfeatureClasses" );
	my $subfeatures = "'{\"reagent\":\"$childGlyph\"";
	$subfeatures .= ', "exon":"exon"';
	$subfeatures .= ', "cds":"transcript-CDS"';
	$subfeatures .= ', "CDS":"transcript-CDS"';
	$subfeatures .= ', "miRNA":"transcript-exon"';
	$subfeatures .= ', "mRNA":"transcript-exon"';
	$subfeatures .= ', "pre_miRNA":"transcript-exon"';
	$subfeatures .= ', "miscRNA":"transcript-exon"';
	$subfeatures .= ', "snRNA":"transcript-exon"';
	$subfeatures .= ', "rRNA":"transcript-exon"';
	$subfeatures .= ', "tRNA":"transcript-exon"';
	$subfeatures .= ', "snoRNA":"transcript-exon"';
	$subfeatures .= ', "pseudogene":"transcript-exon"';
	$subfeatures .= ', "ncRNA":"transcript-exon"}\'';
	push( @commands, $subfeatures );
	push( @commands, "--cssClass $parentGlyph --autocomplete $autocomplete" );
	push( @commands, "--arrowheadClass $arrowheadClass" );
	my $command = "@commands";
	print "$command\n";

	for (`$command`) {
		print;
	}
}

sub formatTrack2Crispr($$$$$$) {
	chdir "JBrowse-1.13.0";
	my %features;
	my ( $gffOutputFile, $trackName, $childGlyph, $parentGlyph, $autocomplete, $arrowheadClass ) =
	  @_;
	my @commands;
	push( @commands, "bin/flatfile-to-json.pl" );
	push( @commands, "-gff $gffOutputFile -out crispr/ " );
	push( @commands, "-trackLabel \"$trackName\"" );
	push( @commands, "--getSubs true" );
	push( @commands, "--subfeatureClasses" );
	my $subfeatures = "'{\"reagent\":\"$childGlyph\"";
	$subfeatures .= ', "exon":"exon"';
	$subfeatures .= ', "cds":"transcript-CDS"';
	$subfeatures .= ', "miRNA":"transcript-exon"';
	$subfeatures .= ', "pre_miRNA":"transcript-exon"';
	$subfeatures .= ', "miscRNA":"transcript-exon"';
	$subfeatures .= ', "snRNA":"transcript-exon"';
	$subfeatures .= ', "rRNA":"transcript-exon"';
	$subfeatures .= ', "tRNA":"transcript-exon"';
	$subfeatures .= ', "snoRNA":"transcript-exon"';
	$subfeatures .= ', "pseudogene":"transcript-exon"';
	$subfeatures .= ', "ncRNA":"transcript-exon"}\'';
	push( @commands, $subfeatures );
	push( @commands, "--cssClass $parentGlyph --autocomplete $autocomplete" );
	push( @commands, "--arrowheadClass $arrowheadClass" );
	my $command = "@commands";
	print "$command\n";

	for (`$command`) {
		print;
	}
}

sub buildRefSeq($) {
	my ($version) = @_;
	my $command =
"jbutils/prepare-refseqs.pl --fasta fastaFiles/Fly/dmel-all-chromosome-r$version.fasta --out data/";
	print $command, " \n ";
	for (`$command`) {
		print;
	}

}

sub readFastaFile($$) {
	my ( $file, $refFeatures ) = @_;
	my $fhFastaFile;
	unless ( open( $fhFastaFile, "<", $file ) ) {
		die "unable to open $file", $!;
	}
	while ( readline($fhFastaFile) ) {
		chomp;

# >FBgn0085506 type=gene; loc=211000022278760:complement(562..879); ID=FBgn0085506; name=CG40635; dbxref=FlyBase:FBgn0085506,GB:AJ784867,FlyBase:FBan0040635,FlyBase_Annotation_IDs:CG40635,UniProt/TrEMBL:A8QIA9,INTERPRO:IPR016149,INTERPRO:IPR000704,EntrezGene:5740827,GB_protein:EDP27858,GB_protein:EDP27858,INTERPRO:IPR035991; MD5=43fce258bcee2b2f36e8b5e0607baa3b; length=318; release=r6.22; species=Dmel; 
		if (/^>([-\w]+)(\s.*loc=(.*?):.*;)/) {
			next if $3 =~ /\d{2,}/;
			my $feature = Feature->new( id => $1 );
			$feature->fastaToFeature($2);
			if ( $feature->type() eq 'gene' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'mRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'ncRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'pseudogene' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'snRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'miscRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'miRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'rRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'snoRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'tRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'pre_miRNA' ) {
				$refFeatures->{$1} = $feature;
			}
			elsif ( $feature->type() eq 'CDS' ) {
				my $parent = $feature->parent();
				if ( exists $refFeatures->{$parent} ) {
					push( @{ $refFeatures->{$parent}->children() }, $feature );
					my $parentEnd   = $refFeatures->{$parent}->end();
					my $parentStart = $refFeatures->{$parent}->start();
				}
				else {
					print "Undefined ", $parent, "\n";
				}
			}
			else {
				print "undefined type", $feature->type(), "\n";
			}
		}
	}
}

sub getHairpinXref() {
	my %hairpinXref;
	my $fileName = 'reagentFiles/Fly/hairpinXref.txt';
	if ( open( my $fhHairpinXrefFile, "<", $fileName ) ) {
		while ( readline($fhHairpinXrefFile) ) {
			chomp;
			my @columns = split();
			$hairpinXref{ $columns[0] } = $columns[1];
		}
	}
	else {
		die "unable to open $fileName", $!;
	}
	return \%hairpinXref;
}

sub addTrack($$$$$$) {
	my %features;
	my ( $blastOutputFile, $gffOutputFile, $minLength, $refHairpins, $fileFlag, $splitId ) = @_;
	readBlastOutput( $blastOutputFile, \%features, $minLength, $refHairpins, $splitId );
	my $fhOutFile;
	unless ( open( $fhOutFile, $fileFlag, $gffOutputFile ) ) {
		die "unable to open file", $!;
	}
	for my $id ( keys %features ) {
		$features{$id}->print($fhOutFile);
		print $fhOutFile "###", "\n";
	}

}

sub addTrackCrispr($$$$$$) {
	my %features;
	my ( $blastOutputFile, $gffOutputFile, $minLength, $refHairpins, $fileFlag, $splitId ) = @_;
	readBlastOutputCrispr( $blastOutputFile, \%features, $minLength, $refHairpins, $splitId );
	my $fhOutFile;
	unless ( open( $fhOutFile, $fileFlag, $gffOutputFile ) ) {
		die "unable to open file", $!;
	}
	for my $id ( keys %features ) {
		$features{$id}->print($fhOutFile);
		print $fhOutFile "###", "\n";
	}

}

sub addTrackLH($$$$$) {
	my %features;
	my ( $blastOutputFile, $gffOutputFile, $minLength, $refHairpins, $fileFlag ) = @_;
	readBlastOutputLH( $blastOutputFile, \%features, $minLength, $refHairpins );
	my $fhOutFile;
	unless ( open( $fhOutFile, $fileFlag, $gffOutputFile ) ) {
		die "unable to open file", $!;
	}
	for my $id ( keys %features ) {
		$features{$id}->print($fhOutFile);
		print $fhOutFile "###", "\n";
	}

}

sub readBlastOutput($$$$$) {
	my ( $blastFile, $refFeatures, $minLength, $refHairpins, $splitId ) = @_;
	my $fhOutFile;
	my $fhBlastFile;
	my $matches;
	my %ids;
	unless ( open( $fhBlastFile, "<", $blastFile ) ) {
		die "unable to open $blastFile", $!;
	}
	unless ( open( LOG, ">", $blastFile . '.log' ) ) {
		die "unable to open $blastFile", $!;
	}
	while ( readline($fhBlastFile) ) {
		chomp;
		my $line        = $_;
		my @blastLine   = split();
		my $columnCount = @blastLine;
		if ( $columnCount == 12 ) {
			my $idFields        = $blastLine[0];
			my $chrom           = $blastLine[1];
			my $identity        = $blastLine[2];
			my $alignmentLength = $blastLine[3];
			my $mismatches      = $blastLine[4];
			my $gaps            = $blastLine[5];
			my $queryStart      = $blastLine[6];
			my $queryEnd        = $blastLine[7];
			my $subjectStart    = $blastLine[8];
			my $subjectEnd      = $blastLine[9];
			my $eValue          = $blastLine[10];
			my $bitScore        = $blastLine[11];
			my $strand          = '+';

			$chrom =~ s/CHROMOSOME_//g;
			$chrom =~ s/C//g;
			if ( $subjectStart > $subjectEnd ) {
				( $subjectStart, $subjectEnd ) = ( $subjectEnd, $subjectStart );
				$strand = '-';
			}
			my $id      = '';
			my $name    = '';
			my @idArray = split( /_/, $idFields );
			if ($splitId) {
				my @idArray = split( /_/, $idFields );
			}
			else {
				my @idArray = split( / /, $idFields );
			}
			my $tempId = $idArray[0];
			if ( !exists $ids{$tempId} ) {
				$ids{$tempId} = 0;
			}

			#my $idChrom = $idArray[1];
			#if ( @idArray > 2 ) {
			#		$idChrom = $idArray[2];
			#}
			#if ( !defined $idChrom ) {
			#	$idChrom = $chrom;
			#}
			if ( !$splitId || $idFields =~ /(.*?$chrom.*)/ ) {

				#print $1, "\n";
				#$idChrom =~ s/C//g;
				#if ( $identity > 98 && $alignmentLength >= $minLength && ( $idChrom eq $chrom ) ) {
				if ( $identity > 98 && $alignmentLength >= $minLength ) {
					if ( exists $refHairpins->{ $idArray[0] } ) {
						$name = $refHairpins->{ $idArray[0] };
					}
					else {
						$name = $idArray[0];
					}
					$id = $idArray[0] . '-' . $chrom;
					my $seqCount = $ids{$id}++;
					if ( $name && $seqCount == 0 && !( $name eq 'DRSC20595' ) ) {
						unless ( exists $refFeatures->{$id} ) {
							my $feature = Feature->new( id => $id );
							$feature->start($subjectStart);
							$feature->end($subjectEnd);
							$feature->chrom($chrom);
							$feature->strand($strand);
							$feature->name($name);
							$feature->type('Reagent');
							$refFeatures->{$id} = $feature;
						}
						my $childFeature = Feature->new( id => $subjectStart );
						unless ( exists $matches->{$id}{$subjectStart}{$subjectEnd} ) {
							if ( abs( $subjectEnd - $refFeatures->{$id}->end() ) < 500 ) {
								$matches->{$id}{$subjectStart}{$subjectEnd} = 1;
								$childFeature->start($subjectStart);
								$childFeature->end($subjectEnd);
								$childFeature->chrom($chrom);
								$childFeature->strand($strand);
								$childFeature->name($name);
								$childFeature->type('reagent');
								$childFeature->parent($id);

								if ( $subjectEnd > $refFeatures->{$id}->end() ) {
									$refFeatures->{$id}->end($subjectEnd);
								}
								if ( $subjectStart < $refFeatures->{$id}->start() ) {
									$refFeatures->{$id}->start($subjectStart);
								}
								push( @{ $refFeatures->{$id}->children() }, $childFeature );
							}
						}
					}
					else {
						if ( !$name ) {
							print LOG "name undefined for ", $line, "\n";
						}
					}
				}
				else {

					#					print $identity, "\t", $alignmentLength, "\t", $minLength,
					#					  "\n";
				}
			}
			else {
				print LOG $splitId, "\t", $idFields, "\t", $chrom, "\n";
			}
		}
		else {
			print LOG "unexpected line layout ", $columnCount, " columns ", $_, "\n";
		}
	}
}

sub readBlastOutputCrispr($$$$$) {
	my ( $blastFile, $refFeatures, $minLength, $refHairpins, $splitId ) = @_;
	my $fhOutFile;
	my $fhBlastFile;
	my $matches;
	my %ids;
	unless ( open( $fhBlastFile, "<", $blastFile ) ) {
		die "unable to open $blastFile", $!;
	}
	while ( readline($fhBlastFile) ) {
		chomp;
		my $line        = $_;
		my @blastLine   = split();
		my $columnCount = @blastLine;
		if ( $columnCount == 12 ) {
			my $idFields        = $blastLine[0];
			my $chrom           = $blastLine[1];
			my $identity        = $blastLine[2];
			my $alignmentLength = $blastLine[3];
			my $mismatches      = $blastLine[4];
			my $gaps            = $blastLine[5];
			my $queryStart      = $blastLine[6];
			my $queryEnd        = $blastLine[7];
			my $subjectStart    = $blastLine[8];
			my $subjectEnd      = $blastLine[9];
			my $eValue          = $blastLine[10];
			my $bitScore        = $blastLine[11];
			my $strand          = '+';

			$chrom =~ s/C//g;
			if ( $subjectStart > $subjectEnd ) {
				( $subjectStart, $subjectEnd ) = ( $subjectEnd, $subjectStart );
				$strand = '-';
			}
			my $id   = '';
			my $name = '';
			if ( $identity > 98 && $alignmentLength >= $minLength ) {
				$name = $idFields;
				$id   = $idFields . '-' . $chrom;
				my $seqCount = $ids{$id}++;
				if ( $name && $seqCount == 0 ) {
					unless ( exists $refFeatures->{$id} ) {
						my $feature = Feature->new( id => $id );
						$feature->start($subjectStart);
						$feature->end($subjectEnd);
						$feature->chrom($chrom);
						$feature->strand($strand);
						$feature->name($name);
						$feature->type('Reagent');
						$refFeatures->{$id} = $feature;
					}
					my $childFeature = Feature->new( id => $subjectStart );
					unless ( exists $matches->{$id}{$subjectStart}{$subjectEnd} ) {
						if ( abs( $subjectEnd - $refFeatures->{$id}->end() ) < 500 ) {
							$matches->{$id}{$subjectStart}{$subjectEnd} = 1;
							$childFeature->start($subjectStart);
							$childFeature->end($subjectEnd);
							$childFeature->chrom($chrom);
							$childFeature->strand($strand);
							$childFeature->name($name);
							$childFeature->type('reagent');
							$childFeature->parent($id);

							if ( $subjectEnd > $refFeatures->{$id}->end() ) {
								$refFeatures->{$id}->end($subjectEnd);
							}
							if ( $subjectStart < $refFeatures->{$id}->start() ) {
								$refFeatures->{$id}->start($subjectStart);
							}
							push( @{ $refFeatures->{$id}->children() }, $childFeature );
						}
						else {
							print "$subjectEnd - $refFeatures->{$id}->end()\t",
							  $subjectEnd - $refFeatures->{$id}->end();
						}
					}
				}
				else {
					print "name,seqCount:\t", $name, "\t", $seqCount, "\n";
				}
			}
			else {

				#				print "alignmentLength\t", $alignmentLength, "\t", $identity,
				#				  "\t", $minLength, "\n";
			}
		}
	}
}

sub readBlastOutputLH($$$$) {
	my ( $blastFile, $refFeatures, $minLength, $refHairpins ) = @_;
	my $fhOutFile;
	my $fhBlastFile;
	my $matches;
	unless ( open( $fhBlastFile, "<", $blastFile ) ) {
		die "unable to open $blastFile", $!;
	}
	my %ids;
	while ( readline($fhBlastFile) ) {
		chomp;
		my $line        = $_;
		my @blastLine   = split();
		my $columnCount = @blastLine;
		if ( $columnCount == 12 ) {
			my $idFields        = $blastLine[0];
			my $chrom           = $blastLine[1];
			my $identity        = $blastLine[2];
			my $alignmentLength = $blastLine[3];
			my $mismatches      = $blastLine[4];
			my $gaps            = $blastLine[5];
			my $queryStart      = $blastLine[6];
			my $queryEnd        = $blastLine[7];
			my $subjectStart    = $blastLine[8];
			my $subjectEnd      = $blastLine[9];
			my $eValue          = $blastLine[10];
			my $bitScore        = $blastLine[11];
			my $strand          = '+';

			$chrom =~ s/CHROMOSOME_//g;
			$chrom =~ s/C//g;
			if ( $subjectStart > $subjectEnd ) {
				( $subjectStart, $subjectEnd ) = ( $subjectEnd, $subjectStart );
				$strand = '-';
			}
			my $id      = '';
			my $name    = '';
			my @idArray = split( /_/, $idFields );
			my $idChrom = $idArray[1];
			if ( !defined $idChrom ) {
				$idChrom = $chrom;
			}
			if ( defined $idChrom ) {
				$idChrom =~ s/C//g;

				#print $idChrom, "\t", $chrom, "\n";
				if (   $identity > 98
					&& $alignmentLength >= $minLength )
				{
					if ( exists $refHairpins->{ $idArray[0] } ) {
						$name = $refHairpins->{ $idArray[0] };
					}
					else {
						$name = $idArray[0];
					}
					$id = $idArray[0] . '-' . $chrom;
					my $seqCount = $ids{$id}++;
					if (   $name
						&& $seqCount == 0
						&& !( $name eq 'DRSC20595' ) )
					{
						unless ( exists $refFeatures->{$id} ) {
							my $feature = Feature->new( id => $id );
							$feature->start($subjectStart);
							$feature->end($subjectEnd);
							$feature->chrom($chrom);
							$feature->strand($strand);
							$feature->name($name);
							$feature->type('Reagent');
							$refFeatures->{$id} = $feature;
						}
						my $childFeature = Feature->new( id => $subjectStart );
						unless ( exists $matches->{$id}{$subjectStart}{$subjectEnd} ) {
							if ( abs( $subjectEnd - $refFeatures->{$id}->end() ) < 500 ) {
								$matches->{$id}{$subjectStart}{$subjectEnd} = 1;
								$childFeature->start($subjectStart);
								$childFeature->end($subjectEnd);
								$childFeature->chrom($chrom);
								$childFeature->strand($strand);
								$childFeature->name($name);
								$childFeature->type('reagent');
								$childFeature->parent($id);

								if ( $subjectEnd > $refFeatures->{$id}->end() ) {
									$refFeatures->{$id}->end($subjectEnd);
								}
								if ( $subjectStart < $refFeatures->{$id}->start() ) {
									$refFeatures->{$id}->start($subjectStart);
								}
								push( @{ $refFeatures->{$id}->children() }, $childFeature );
							}
						}
					}
					else {
						if ( !$name ) {
							print LOG "name undefined for ", $line, "\n";
						}
					}
				}
			}
			else {
				print LOG "$idChrom undefined for ", $idFields, "\t", $chrom, "\n";
				die;
			}
		}
		else {
			print LOG "unexpected line layout ", $columnCount, " columns ", $_, "\n";
		}
	}
}
return 1;
