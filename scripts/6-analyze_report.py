#!usr/bin/env python
import collections
import sys, re

### Step 6: analyze report ###
#                            #
# Jonathan Rodiger - 2019    #
#                            #
##############################

if (len(sys.argv) == 3 and sys.argv[1] == '-path'):
    data_dir = sys.argv[2]
else:
    print('Error: wrong input format')
    print('Usage: python 6-analyze_report.py -path <data base directory>\n')
    exit()

# allows initialization of multi-key hashes like:
# dict['key1']['key2']['key3'] = 'val'
def makehash():
    return collections.defaultdict(makehash)

### pseudocode logic: ###

# go through genes and check if any map to multiple transcripts

# build design to transcript mapping

# go through blast results and check if each design has on-target hit

# store coordinates of on-target hits

# for all designs with on-target hits, check if coordinates hit all transcripts

genes = []
transcript2gene = {}
print("+Reading: "+data_dir + '/output/transcript2gene.txt');
with open(data_dir + '/output/transcript2gene.txt', 'r') as mapping:
    for line in mapping:
        line = line.strip()
        info = line.split('\t')
        genes.append(info[1])
        transcript2gene[info[0]] = info[1]

gene2transcripts = makehash()
print ("+Reading: "+ data_dir + '/input/base_features.gtf')
with open(data_dir + '/input/base_features.gtf', 'r') as mapping:
    for line in mapping:
        line = line.strip()

        if line[0] == '#':
            continue

        seqid, source, feature, start, end, score, strand, frame, attribute = line.split('\t')

        if feature != 'transcript':
            continue
        else:
            if any(gene in attribute for gene in genes):
                # extract gene and transcript ID
                results = re.search('gene_id "(.+?)"; transcript_id "(.+?)";', attribute)
                if results:
                    gene = results.group(1)
                    transcript = results.group(2)
                else:
                    continue

                gene2transcripts[gene][transcript] = [int(start), int(end)]

crispr2transcript = {}
print ("+Reading: "+ data_dir + '/output/crispr_designs.txt')
with open(data_dir + '/output/crispr_designs.txt', 'r') as mapping:
    for line in mapping:
        line = line.strip()
        info = line.split('\t')
        transcript = info[0].split(';')[0]
        crispr = info[1]
        if crispr not in crispr2transcript:
            crispr2transcript[crispr] = []
        crispr2transcript[crispr].append(transcript)

on_target_hits = {}
print ("+Reading: "+ data_dir + '/output/blast_report.txt')
with open(data_dir + '/output/blast_report.txt', 'r') as report:
    for line in report:
        line = line.strip()

        (subject,    start,   end,     q_start,      q_end, 
         query_seq,  strand,  base,    subject_seq,  alignment,
         ot1,        ot2,     ot_pam,  ot_type) = line.split('\t')

        if ot_type != 'On-Target':
            continue

        crispr = query_seq

        if crispr in on_target_hits:
            raise ValueError('multiple on-target hits!')

        for transcript in crispr2transcript[crispr]:
            gene = transcript2gene[transcript]
            if crispr not in on_target_hits:
                on_target_hits[crispr] = []
            on_target_hits[crispr].append([gene, transcript, int(start), int(end)])

print ("+Writing: "+ data_dir + '/output/blast_analysis.txt')
with open(data_dir + '/output/blast_analysis.txt', 'w') as analysis:
    for crispr in on_target_hits:
        for hit_info in on_target_hits[crispr]:
            gene = hit_info[0]
            target_transcript = hit_info[1]
            start = hit_info[2]
            end = hit_info[3]

            actual = 0
            total = len(gene2transcripts[gene])

            for transcript in gene2transcripts[gene]:
                transcript_info = gene2transcripts[gene][transcript]
                transcript_start = transcript_info[0]
                transcript_end = transcript_info[1]

                if transcript_start <= start <= transcript_end and transcript_start <= end <= transcript_end:
                    actual += 1

            analysis.write(target_transcript + '\t' + crispr + '\t' + str(actual) + '\t' + str(total) + '\t')

            if actual != total:
                analysis.write('missing ' + str(total - actual) + ' transcript(s)\n')
            else:
                analysis.write('all\n')
