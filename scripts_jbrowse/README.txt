#-------------------------------
# Create files for jBrowse using Perl scripts.

cpanm install JSON
cpanm install Digest::Crc32
cpanm install Hash::Merge
cpanm install Devel::Size
cpanm install CGI
cpanm install File::Next
cpanm install Heap::Simple
cpanm install Heap::Simple:XS
cpanm install PerlIO::gzip

#--------------------------------
#RUN

see ../README.txt in the Build Jbrowse section.

something like: 

#module load gcc/6.2.0 perl/5.30.0

source /n/groups/flyrnai/environments/perl/start_perl_530.sh

# Data Dir 2 is relative to Jbrowse_1..... dir
DATA_DIR2=../../data_mosquito
cd scripts_jbrowse/


# (approx 60 minutes)
perl 09-build_genome_track.pl -path $DATA_DIR2
perl 10-build_gene_and_transcript_tracks.pl -path $DATA_DIR2
perl 11-build_crispr_tracks.pl -path $DATA_DIR2
perl 12-generate_track_labels.pl 

#
# There is some info on setting up data for JBrowse 1.x series here:
# https://jbrowse.org/docs/tutorial.html
#



bin/prepare-refseqs.pl --fasta ../../data_tick/input/genomic.fa --out data/




(base) ac411@compute-a-16-160:/n/scratch3/users/a/ac411/CRISPR/2023_Tick_KO_design/scripts_jbrowse$ 
(base) ac411@compute-a-16-160:/n/scratch3/users/a/ac411/CRISPR/2023_Tick_KO_design/scripts_jbrowse$ 
(base) ac411@compute-a-16-160:/n/scratch3/users/a/ac411/CRISPR/2023_Tick_KO_design/scripts_jbrowse$ perl 10- -path $DATA_DIR2
10-build_gene_and_transcript_tracks.pl   10-build_gene_and_transcript_tracks.pl~  
(base) ac411@compute-a-16-160:/n/scratch3/users/a/ac411/CRISPR/2023_Tick_KO_design/scripts_jbrowse$ perl 10-build_gene_and_transcript_tracks.pl -path $DATA_DIR2
-------------------------------------
-step 1

bin/flatfile-to-json.pl -gff ../../data_tick/jbrowse/genes.gff3 -out data/ -trackLabel "Genes" --getSubs true --subfeatureClasses '{"reagent":"generic_part_a", "exon":"exon", "cds":"transcript-CDS", "ncRNA":"transcript-exon"}' --cssClass feature5 --autocomplete label --arrowheadClass transcript-arrowhead --getLabel 
 -------------------------------------
-step 2 

bin/flatfile-to-json.pl -gff ../../data_tick/jbrowse/transcripts.gff3 -trackLabel "RNA" --getSubs true --subfeatureClasses '{"reagent":"generic_part_a", "exon":"exon", "cds":"transcript-CDS", "CDS":"transcript-CDS", "miRNA":"transcript-exon", "mRNA":"transcript-exon", "pre_miRNA":"transcript-exon", "miscRNA":"transcript-exon", "snRNA":"transcript-exon", "rRNA":"transcript-exon", "tRNA":"transcript-exon", "snoRNA":"transcript-exon", "pseudogene":"transcript-exon", "ncRNA":"transcript-exon"}' --cssClass generic_parent --autocomplete label --arrowheadClass none

use Genome.gff instead of transcripts.gff...  the parent stuff gets messed up:

id-LOC120845064     | Parent=gene-LOC120845064
id-LOC115329785     | Parent=gene-LOC115329785
id-LOC120838242     | Parent=gene-LOC120838242
id-LOC120838242-2   | Parent=gene-LOC120838242
id-LOC120838242-3   | Parent=gene-LOC120838242
id-LOC115328310     | Parent=gene-LOC115328310
id-LOC115328310-2   | Parent=gene-LOC115328310
id-LOC115328310-3   | Parent=gene-LOC115328310
id-LOC115328310-4   | Parent=gene-LOC115328310
id-LOC115328310-5   | Parent=gene-LOC115328310
id-LOC115328310-6   | Parent=gene-LOC115328310
id-LOC115327357     | Parent=gene-LOC115327357
id-LOC115327357-2   | Parent=gene-LOC115327357
id-LOC115331678     | Parent=gene-LOC115331678
id-LOC115331678-2   | Parent=gene-LOC115331678
id-LOC115331678-3   | Parent=gene-LOC115331678
id-LOC121836795     | Parent=gene-LOC121836795
id-LOC121836795-2   | Parent=gene-LOC121836795
id-LOC121836795-3   | Parent=gene-LOC121836795
