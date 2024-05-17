#!usr/bin/env python3
import collections
import re
import sys  


# Jonathan Rodiger - 2019
# Aram Comjean 2022

data_path = ''

if (len(sys.argv) == 3 and sys.argv[1] == '-path'):
    data_path = sys.argv[2]
else:
    print('Error: wrong input format')
    print('Usage: python 0-find_longest_CDS_transcripts.py  -path <data_path>\n')
    exit()




# allows initialization of multi-key hashes like:
# dict['key1']['key2']['key3'] = 'val'
def makehash():
    return collections.defaultdict(makehash)


# gene_ids_csv = open('gambiae/genes.csv', 'r')
# gene_ids = gene_ids_csv.read().split('\n')
gene_ids = []

transcripts = makehash()
print ("+Reading: "+ data_path + '/input/base_features.gtf') 
with open(data_path + '/input/base_features.gtf', 'r') as f:
    for line in f:
        line = line.strip()

        if line[0] == '#':
            continue

        seqid, source, feature, start, end, score, strand, frame, attribute = line.split('\t')

        results = re.search('gene_id "(.*?)"; transcript_id "(.*?)";', attribute)
        if results:
            gene = results.group(1)
            transcript = results.group(2)
            
            if transcript == '':
                continue
            if gene not in gene_ids:
                gene_ids.append(gene)

            if not transcripts[gene][transcript][feature]:
                transcripts[gene][transcript][feature] = []
            
            transcripts[gene][transcript][feature].append([int(start), int(end)])

print ('+Writing: '+ data_path + '/output/transcript_ids.csv')
with open(data_path + '/output/transcript_ids.csv', 'w') as out:
    for gene in transcripts:
        longest_CDS = 0
        longest_id = ''
        for transcript in transcripts[gene]:
            CDS_length = 0
            if longest_id == '':
                longest_id = transcript
            for CDS in transcripts[gene][transcript]['CDS']:
                CDS_length += CDS[1] - CDS[0]
            if CDS_length > longest_CDS:
                longest_CDS = CDS_length
                longest_id = transcript
        out.write(longest_id + ',')

print ('+Writing: '+ data_path + '/ouput/transcript2gene.txt')
with open(data_path + '/output/transcript2gene.txt', 'w') as mapping:
    for gene in transcripts:
        for transcript in transcripts[gene]:
            mapping.write(transcript + '\t' + gene + '\n')

print ('+Writing: logs/0_error_log.txt')
with open('logs/0_error_log.txt', 'w') as out:
    for gene in gene_ids:
        has_CDS = False
        for transcript in transcripts[gene]:
            if 'CDS' in transcripts[gene][transcript]:
                has_CDS = True
        if not has_CDS:
            out.write(gene + '\n')
