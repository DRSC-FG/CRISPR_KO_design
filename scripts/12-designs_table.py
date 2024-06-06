#!usr/bin/env python3
import sys

# Jonathan Rodiger - 2020
# Aram 2023




if (len(sys.argv) == 4 and sys.argv[1] == '-in'):
        species = sys.argv[2]
        species_version = sys.argv[3]
else:
        print('Error: wrong input format')
        print('Usage: python 12-designs_table.py -in <species> <species_version>\n')
        exit()

crispr2loc = {}
print ('+Reading:'+ species + '/jbrowse/designs.gff3')
with open(species + '/jbrowse/designs.gff3', 'r') as f:
        count =0
        for line in f:
                count=count+1
                if count <30:
                        print (line)
                if line[0] == '#':
                        continue
                data       = line.strip('\n').split('\t')
                crispr     = line.split('<br>')[1]
                chromosome = data[0]
                start      = data[3]
                stop       = data[4]
                strand     = data[6]
                crispr2loc[crispr] = [chromosome, start, stop, strand]


transcript2gene={}

print ('+Reading:'+ species + '/output/transcript2gene.txt')
with open(species + '/output/transcript2gene.txt', 'r') as f:
        for line in f:
                if count <30:
                        print (line)
                if line[0] == '#':
                        continue
                data       = line.strip('\n').split('\t')
                transcript = data[0]
                gene = data[1]

                transcript2gene[transcript] = gene


print ('+Reading:'+ species + '/output/final_design_results_filtered.txt')
with open(species + '/output/final_design_results_filtered.txt', 'r') as f:
        print ('+Writing :'+ species + '/output/design_table.tsv')
        with open(species + '/output/design_table.tsv', 'w') as out:
                next(f)
                header = 'species\tgene_id\ttranscript_id\tsequence\tseq_no_pam\tchr\tstart\tstop\tstrand\thits\tstart_distance\tcoverage\tmissing_start\tseed_score\teff_score\tote_score\tml_score\n'
                out.write (header)

                for line in f:
                        data = line.strip('\n').split('\t')

                        transcript = data[1].strip()
                        # skip designs that don't cut any transcripts
                        if data[2][0] == '0':
                                continue
                                
                        if transcript in transcript2gene:
                                gene = transcript2gene[transcript]
                        else:
                                gene = '!!!'+transcript
                        crispr = data[0]

                        # check if start codon is annotated
                        if data[4] == 'not_annotated':
                                coverage = 'not annotated'
                        else:
                                coverage = data[4]
                        if data[5] == 'missing_start:True':
                                missing_start = 'not annotated'
                        else:
                                missing_start = 'annotated'

                        out.write('\t'.join([species_version, gene, data[1], crispr, crispr[0:20], crispr2loc[crispr][0], crispr2loc[crispr][1], crispr2loc[crispr][2], crispr2loc[crispr][3], data[2], data[3], coverage, missing_start, data[6], data[7], data[8], data[9]]) + '\n')
