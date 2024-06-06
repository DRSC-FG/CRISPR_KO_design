CRISPR Design for KO.
Designs in the expressing part of the gene sequence.

Contains Perl/python scripts.  Some code is specific to the HMS RC environment

#-----------------------------------------
#build a new run area..
cd CRISPR_KO_design_base
rsync * --exclude 2023_Tick_KO_design /path/to/new/runarea/

#set the data directory
#
# While multiple runs can happen at the same time without interference,
# The logs folder might get confused (slurm log directives make using a env var for a log path challenging) 
#
# In this case our data folder is "data_tick" Species 6945 (black legged tick)

DATA_DIR=data_tick
DATA_DIR2=../../data_tick
TAXONID=6945

DATA_DIR=data_aabf5
DATA_DIR2=../../data_aabf5
TAXONID=7160

DATA_DIR=data_aalbo1
DATA_DIR2=../../data_aalbo1
TAXONID=7160


you can run multiple species from this run directory. 
each run has all data readfrom and stored in a "data" dir 

mkdir -p $DATA_DIR/output
mkdir -p $DATA_DIR/input
mkdir -p $DATA_DIR/blast_dbs
mkdir -p $DATA_DIR/logs
mkdir -p $DATA_DIR/input_ml/

mkdir -p logs 


# download genomic fasta NCBI.. Put GTF,GFF and fasta in $DATA_DIR/input

# Make sure input gtf are available:
# Link or rename input files.  (consistant names for existing scripts).

cd $DATA_DIR/input
ln -s rna.fna transcripts.fa
ln -s genomic.gtf base_features.gtf
ln -s GCF_016920785.2_ASM1692078v2_genomic.fna genomic.fa
cd -

module load samtools/1.15.1
samtools faidx $DATA_DIR/input/fasta.fna
cut -f1-2 $DATA_DIR/input/fasta.fna > $DATA_DIR/output/fasta_lengths.csv



#-----------------------------------
# 0 FIND LONGEST CDS Transcripts

python scripts/0-find_longest_CDS_transcripts.py -path $DATA_DIR  > $DATA_DIR/logs/0_find_longest_cds_transcripts.txt
+Reading: $DATA_DIR/input/base_features.gtf 
+Writing: $DATA_DIR/output/transcript_ids.csv
+Writing: $DATA_DIR/ouput/transcript2gene.txt
+Writing: logs/0_error_log.txt


we can optionally generate the transcript_ID file with one per line
usefull for debugging, checking
cat $DATA_DIR/output/transcript_ids.csv | tr , \\n > $DATA_DIR/output/transcript_ids_line.txt


#-----------------------------------
# 1 Get Designs from CRISPR.  

in this case the gene name in in the .fa file as the value in the ()

python scripts/1-get_crispr_designs.py -path $DATA_DIR > $DATA_DIR/logs/1_get_crispr_designs.txt
+Reading: $DATA_DIR/output/transcript_ids.csv
+Reading: $DATA_DIR/output/transcript.fa
+Reading: $DATA_DIR/input//base_features.gtf
+Writing: $DATA_DIR/output/crispr_designs.txt


#-----------------------------------
# 2 Find Unique Kmers

#Uses a lot of memory, run with sbatch if an option

sbatch scripts/run_2_find_unique_kmers.job $DATA_DIR

#[perl scripts/2-find_unique_kmers.pl -path $DATA_DIR]

+ Reading :$DATA_DIR/input/sequences.fa(1) 15 => CCCTCTCCCGCTCCG
.......
+ Reading :$DATA_DIR/input/sequences.fa(1) 15 => CCCTCTCCCGCTCCG
+ Wrtiting: unique_kmers.fasta
+ Wrtiting: seed_scores.txt

#-----------------------------------
#3 BUILD blastDB, blast genome

#update the script and move

sbatch scripts/run_buildblastdb.job $DATA_DIR $DATA_DIR/input/genomic.fa
sbatch scripts/run_step3.job $DATA_DIR $DATA_DIR/output/unique_kmers.fasta $DATA_DIR/input/genomic.fa
#----  perl scripts/3-blast_crisprs.pl -datadir data_aabf5 -fasta data_aabf5/output/unique_kmers.fasta  -genomicfasta    --species=data_aalbo1

+ Writing: blast_report.txt

#-----------------------------------
#4 Get ote scores.


sbatch  scripts/run_step4.job $DATA_DIR

+ Reading: (temp) $DATA_DIR/ote_numbers.txt 
1510227 CRISPRs with OTE scores
+ re ote_numbers.txt 
+ Writing: $DATA_DIR/output/ote_scores.txt 


#-----------------------------------
#5 Calculate efficency score

perl scripts/5-calculate_efficiency.pl in -path $DATA_DIR > $DATA_DIR/logs/5_out.txt

+Reading:$DATA_DIR/output/blast_report.txt
+Writing:$DATA_DIR/output/ote_numbers.txt
+Reading:$DATA_DIR/output/ote_numbers.txt
2845178 CRISPRs with OTE scores
+Writing: $DATA_DIR/output/ote_scores.txt

#-----------------------------------
#6 Analyze Blast Report

conda activate /n/groups/flyrnai/environments/conda/conda3.9.13

python scripts/6-analyze_report.py  -path $DATA_DIR >  $DATA_DIR/logs/6_out.txt

+Reading: $DATA_DIR/output/transcript2gene.txt
+Reading: $DATA_DIR/input/base_features.gtf
+Reading: $DATA_DIR/output/crispr_designs.txt
+Reading: $DATA_DIR/output/blast_report.txt
+Writing: $DATA_DIR/output/blast_analysis.txt



python scripts/7-format_results.py  -path $DATA_DIR >  $DATA_DIR/logs/7_out.txt

+Reading: $DATA_DIR/output/transcript2gene.txt
+Reading: $DATA_DIR/output/blast_analysis.txt
+Reading: /output/crispr_designs.txt
+Reading: $DATA_DIR/output/seed_scores.txt
+Reading: $DATA_DIR/output/eff_scores.txt
+Reading: $DATA_DIR/output/ote_scores.txt
+Reading: $DATA_DIR/output/transcript_ids.csv
+Reading: $DATA_DIR/output/base_features.gtf
+Writing: $DATA_DIR/output/design_results.txt
+ Genereating input file for Machine Learning Score
+ Writing : $DATA_DIR/input_ml/designs.csv



#-----------------------------------
# build machine learning input

#echo "gRNA_23mer"  > $DATA_DIR/input_ml/designs.csv 
#cut -f2 $DATA_DIR/output/crispr_designs.txt >> $DATA_DIR/input_ml/designs.csv 


in the machine learning folder there is a run_ml2.sh slurm start job
you may have to edit.  It can take a long time to run (last run was 12 days)
   
Right now it uses an environment set up by Jon (source /n/groups/flyrnai/jon/mosquito_crisprs/machine_learning/Dmel-sgRNA-Efficiency-Prediction-master/ml_env/bin/activate).
Conda environments aren't portable or clonable so for right now this one works.   This should be addressed in future.

check the input file and run from the "machine_leaning" directory
sbatch run_ml2.sh

output:
machine_learning/23mer_sgRNA_predictions.csv

cd $DATA_DIR/input_ml
split -n l/6 -d designs.csv temp_designs


echo gRNA_23mer > designs01.csv
echo gRNA_23mer > designs02.csv
echo gRNA_23mer > designs03.csv
echo gRNA_23mer > designs04.csv
echo gRNA_23mer > designs05.csv

# the first one has the header already

cp temp_designs00 designs00.csv
cat temp_designs01 >>designs01.csv
cat temp_designs02 >>designs02.csv
cat temp_designs03 >>designs03.csv
cat temp_designs04 >>designs04.csv
cat temp_designs05 >>designs05.csv

cd -


cp -rp ml_base/ ml_${DATA_DIR}_1
cp -rp ml_base/ ml_${DATA_DIR}_2
cp -rp ml_base/ ml_${DATA_DIR}_3
cp -rp ml_base/ ml_${DATA_DIR}_4
cp -rp ml_base/ ml_${DATA_DIR}_5
cp -rp ml_base/ ml_${DATA_DIR}_6

each file should have a header with sgRNA so add that manually.
FROM LOGIN NODE! (It won't start from compute node)

source /n/groups/flyrnai/jon/mosquito_crisprs/machine_learning/Dmel-sgRNA-Efficiency-Prediction-master/ml_env/bin/activate

cd ml_${DATA_DIR}_1
sbatch run_ml2.sh ../${DATA_DIR}/input_ml/designs00.csv
cd ../ml_${DATA_DIR}_2
sbatch run_ml2.sh ../${DATA_DIR}/input_ml/designs01.csv
cd ../ml_${DATA_DIR}_3
sbatch run_ml2.sh ../${DATA_DIR}/input_ml/designs02.csv
cd ../ml_${DATA_DIR}_4
sbatch run_ml2.sh ../${DATA_DIR}/input_ml/designs03.csv
cd ../ml_${DATA_DIR}_5
sbatch run_ml2.sh ../${DATA_DIR}/input_ml/designs04.csv
cd ../ml_${DATA_DIR}_6
sbatch run_ml2.sh ../${DATA_DIR}/input_ml/designs05.csv




in the machine learning folder there is a run_ml2.sh slurm start job
you may have to edit.  It can take a long time to run (last run was 12 days)
once it starts it should be good to ..
Right now it uses an environment set up by Jon (source /n/groups/flyrnai/jon/mosquito_crisprs/machine_learning/Dmel-sgRNA-Efficiency-Prediction\
-master/ml_env/bin/activate).
Conda environments aren't portable or clonable so for right now this one works.   This should be addressed in future.

check the input file and run from the "machine_leaning" directory
source run_ml2.sh

output:
machine_learning/23mer_sgRNA_predictions.csv


copy results to output dir
#cp -rp machine_learning/23mer_sgRNA_predictions.csv $DATA_DIR/output/ml_scores.csv

cp -p ml_${DATA_DIR}_1/23mer_sgRNA_predictions.csv $DATA_DIR/output/ml_scores.csv
tail -n +2 ml_${DATA_DIR}_2/23mer_sgRNA_predictions.csv >>$DATA_DIR/output/ml_scores.csv
tail -n +2 ml_${DATA_DIR}_3/23mer_sgRNA_predictions.csv >>$DATA_DIR/output/ml_scores.csv
tail -n +2 ml_${DATA_DIR}_4/23mer_sgRNA_predictions.csv >>$DATA_DIR/output/ml_scores.csv
tail -n +2 ml_${DATA_DIR}_5/23mer_sgRNA_predictions.csv >>$DATA_DIR/output/ml_scores.csv
tail -n +2 ml_${DATA_DIR}_6/23mer_sgRNA_predictions.csv >>$DATA_DIR/output/ml_scores.csv


#-----------------------------------
# 8. Add machine learning scores and filter the output

+Reading:  $DATA_DIR/output/ml_scores.csv
+Reading:  $DATA_DIR/output/design_results.txt
+Writing: $DATA_DIR/output/final_design_results.txt

python3 scripts/8-add_ml_scores.py -path $DATA_DIR
wc -l $DATA_DIR/output/design_results.txt $DATA_DIR/output/final_design_results.txt


#-----------------------------------
# 9. Add machine learning scores and filter the output

python scripts/9-remove_bad_designs.py -in $DATA_DIR > $DATA_DIR/logs/9_filter_results.txt
+Reading: $DATA_DIR/output/blast_report.txt
+Reading: $DATA_DIR/output/final_design_results.txt


mkdir -p $DATA_DIR/jbrowse

#-----------------------------------
# 10. Generate gff
#
# pulls in blast_report looking for coordinates of sequence
# only uses "on-target" blast hits.
# It filters non ontarget results

+Reading: $DATA_DIR/output/final_design_results.txt
+Reading: $DATA_DIR/output/blast_report.txt
+Writing $DATA_DIR/jbrowse/designs.gff3

mkdir  $DATA_DIR/jbrowse 
python scripts/10-designs_gff3.py -in $DATA_DIR



#-----------------------------------                                                                               
# 11. Generate gff3

goes through gff file and pulls "gene" information rows and writes to "gene.gff3"
pulls :exon,transcrip,mRNA rows and writes to transcripts.gff3

python scripts/11-gene_transcript_gff3.py -in $DATA_DIR 
+Reading: $DATA_DIR/input/genomic.gff
+Writing: $DATA_DIR/jbrowse/transcripts.gff3
+Writing: $DATA_DIR/jbrowse/gene.gff3

#-----------------------------------                                                                               
# 12. Generate gff

python scripts/12-designs_table.py -in $DATA_DIR $TAXONID
+Reading: $DATA_DIR/output/final_design_results_filtered.txt
+Writing:  $DATA_DIR/output/design_table.tsv




##----------------------------------------
#  Verify
##--------------------------------------------
pull the sequences from the fasta files see if they match
samtools faidx reference.fasta lyrata:1-108

module load samtools/1.15.1

samtools faidx $DATA_DIR/input/genomic.fa NW_024609846.1:78620453-78620475
>NW_024609846.1:78620453-78620475
AGAAGGTGCAGGACAAATACAGG

or if - strand: 
samtools faidx $DATA_DIR/input/genomic.fa NW_024609839.1:30891559-30891581 | tr ACGTacgt TGCAtgca | rev





##----------------------------------------
#  JBrowse Tools. 
##--------------------------------------------
jbrowse track data is stored at /n/groups/flyrnai/site_data/fly2mosquito/<species> and there are symlinks 
to /www/www.flyrnai.org/docroot/tools/fly2mosquito/web/JBrowse-1.16.9

to build directories for jbrowse see script in /n/groups/flyrnai/jon/mosquito_crisprs/guidexpress/

for now unlike other scripts,  these are run after moving into scripts_jbrowse

cp -rp /n/groups/flyrnai/jon/mosquito_crisprs/guidexpress/jbrowse_pipeline/* .
cp -rp /n/groups/flyrnai/jon/tf_tool/yifang/jbrowse/JBrowse-1.13.0/ .



##------------------------
##  Build JBrowse
##------------------------

module load gcc/6.2.0 perl/5.30.0


cd scripts_jbrowse/
mkdir -p ../${DATA_DIR}/output_jbrowse/

# (approx 60 minutes)
perl 09-build_genome_track.pl -path $DATA_DIR2
perl 10-build_gene_and_transcript_tracks.pl -path $DATA_DIR2
perl 11-build_crispr_tracks.pl -path $DATA_DIR2
perl 12-generate_track_labels.pl  -path $DATA_DIR2


# run as batch. (update the environment in)
sbatch scripts_jbrowse/RUNALL_aabf5_jbrowse.sh
sbatch scripts_jbrowse/RUNALL_aalbo1_jbrowse.sh



# copy to destination:

mkdir /n/groups/flyrnai/site_data/fly2mosquito/bl_tick
cd ${DATA_DIR}/data
mkdir -p  /n/groups/flyrnai/site_data/fly2mosquito/Aalbo1
mkdir -p  /n/groups/flyrnai/site_data/fly2mosquito/Aabf5

rsync -aP ${DATA_DIR}/output_jbrowse/* /n/groups/flyrnai/site_data/fly2mosquito/Aalbo1/
rsync -aP ${DATA_DIR}/output_jbrowse/* /n/groups/flyrnai/site_data/fly2mosquito/Aabf5/





# From Jon's Notes:

- species names/paths are hardcoded in jbrowse perl scripts in `/n/groups/flyrnai/jon/mosquito_crisprs/guidexpress/jbrowse_pipeline`
- script to precompute cross species designs in `/n/groups/flyrnai/jon/mosquito_crisprs/guidexpress/cross_species`
- /n/groups/flyrnai/jon/tf_tool/yifang/jbrowse


##----------------------------------------
RESULTS
##--------------------------------------------
the results are stored in the "data" directory

This is ready to upload to the msql database.
$DATA_DIR/output/design_table.tsv

slightly less informative file but the same info.
final_design_results_filtered.txt


