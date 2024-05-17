#!usr/bin/env python3

# Base Jonathan Rodiger - 2020
# Updated Aram Comjean 2021-july
#
#

#
#  This code takes 2 input paramters
#    the input line is a gff file.
#
#
#
#    this takes the gene information (start/ stop) and generates a new start location at 500 units from the start
#    the direction is decided by +/-
#
#    this information is stored in the output filename in columns
#
#    Note: the data isn't fixed.  If a start becomes negative or overruns the length of the chromosome. its stored and
#    should be checked for in future processes.
#
#    the output is a csv with the following columns:
#    ['gene_id', 'chromosome', 'start', 'end', 'new_start','new_end', 'direction']
#

import sys            # Read command line parameters
import re
import csv

offset = 500


str = 'ID=gene-LOC115328884;Dbxref=GeneID:115328884;Name=LOC115328884;end_range=59274,.;gbkey=Gene;gene=LOC115328884;gene_biotype=protein_coding;partial=true'
str = 'ID=exon-XM_050693547.1-10;Parent=rna-XM_050693547.1;Dbxref=GeneID:118273279,Genbank:XM_050693547.1;gbkey=mRNA;gene=LOC118273279;product=uncharacterized LOC118273279%2C transcript variant X43;transcript_id=XM_050693547.1'


#GTF 
str = 'NC_064229.1	Gnomon	transcript	7337325	7340425	.	-	.	gene_id "LOC118278147"; transcript_id ""; db_xref "GeneID:118278147"; experiment "COORDINATES: polyA evidence [ECO:0006239]"; gbkey "ncRNA"; gene "LOC118278147"; product "uncharacterized LOC118278147"; transcript_biotype "lnc_RNA"; '

print ('str= '+str)

match = re.findall(r'gene_id "(.*?)"', str)
match = re.findall(r'transcript_id "(.*?)"', str)

# If-statement after search() tests if it succeeded
if match:
    print('found', match) ## 'found word:cat'
    #print('found', match.group()) ## 'found word:cat'
else:
    print ('not found')
