#!usr/bin/env python3
import sys
import re

# Jonathan Rodiger - 2020
#updates 2022

# Write gff3 for JBrowser
#
# gets transcript data and gene data from gff.  Writes to 
# Transcripts.gff/ gene.gff files


if (len(sys.argv) == 3 and sys.argv[1] == '-in'):
    species = sys.argv[2]
else:
    print('Error: wrong input format')
    print('Usage: python 11-gene_transcript_gff3.py -in <species>\n')
    exit()

genes = []
transcripts = []

print ("+Reading: "+species + '/input/genomic.gff')
with open(species + '/input/genomic.gff', 'r') as f:
    for line in f:
        if line[0] == '#':
            transcripts.append(line)
            continue

        data = line.strip('\n').split('\t')

        # add gene to transcript and genes files

        if data[2] == 'gene':

            genes.append(line)
            transcripts.append(line)

        elif data[2] == 'pseudogene' and 'transcript' not in line:
            genes.append(line)
            transcripts.append(line)
            # some gff3 files have parent info for transcripts which causes feature not found error

                #ac 2023 (oddly this didn't work for the tick genes..

                #elif data[2] == 'pseudogene':
            #	transcripts.append(line.split('Parent=')[0] + '\n')
            #elif data[2] == 'transcript':
            #	transcripts.append(line.split('Parent=')[0] + '\n')
            #elif data[2] == 'exon' or data[2] == 'CDS':
            #	transcripts.append(line)
            #elif data[2] == 'mRNA' or data[2] == 'pseudogenic_transcript':
            #		transcripts.append(line.split('Parent=')[0] + '\n')
            #elif 'RNA' in data[2]:
            #	transcripts.append(line.split('Parent=')[0] + '\n')
        elif data[2] == 'transcript' or data[2] == 'exon' or data[2] == 'CDS' or 'RNA' in data[2]:
            #replace parent= with nothing - this didn't work, each element was on a different row
            #cleanedline= replaced=re.sub('Parent=.+?;','', line)
            transcripts.append(line)

print ("+Writing: "+species + '/jbrowse/genes.gff3')
with open(species + '/jbrowse/genes.gff3', 'w') as out:
    for line in genes:
        out.write(line)

print ("+Writing: "+species + '/jbrowse/transcripts.gff3')
with open(species + '/jbrowse/transcripts.gff3', 'w') as out:
    for line in transcripts:
        out.write(line)
