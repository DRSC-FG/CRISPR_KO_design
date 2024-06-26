#!usr/bin/env python3
import collections
import sys
import re

### Step 7: format results ###
#                            #
# Jonathan Rodiger - 2019    #
# Aram Comjean 2023          #
##############################

if (len(sys.argv) == 3 and sys.argv[1] == '-path'):
    data_dir = sys.argv[2]
else:
    print('Error: wrong input format')
    print('Usage: python 7-format_results.py -path <data_dir>\n')
    exit()

# allows initialization of multi-key hashes like:
# dict['key1']['key2']['key3'] = 'val'
def makehash():
    return collections.defaultdict(makehash)




transcript2gene = {}
print ("+Reading: "+data_dir + '/output/transcript2gene.txt')
with open(data_dir + '/output/transcript2gene.txt', 'r') as f:
    for line in f:
        data = line.strip('\n').split('\t')
        transcript_id = data[0]
        gene_id = data[1]

        if transcript_id in transcript2gene:
            print ("*** Duplicate in transcriptgene.txt :"+str(transcript_id))
            continue;
        transcript2gene[transcript_id] = gene_id


# design_results[crispr][transcript] = [actual/total_hits, transcript_id, distance_to_start, missing_start, seed_score, eff_score, ote_score]


blank_row = {'actual_vs_total_hits':'', 'transcript_id':'', 'distance_to_start':'', 'missing_start':'', 'seed_score':'', 'eff_score':'', 'ote_score':''}

design_results = makehash()
print ("+Reading: "+data_dir + '/output/blast_analysis.txt')
with open(data_dir + '/output/blast_analysis.txt', 'r') as analysis:
    for line in analysis:
        line = line.strip()
        info = line.split('\t')

        target_transcript = info[0]
        crispr = info[1]
        actual_hits = info[2]
        total_hits = info[3]

        #design_results[crispr][target_transcript] = []
        #design_results[crispr][target_transcript].append(actual_hits + '/' + total_hits)

        design_results[crispr][target_transcript] = blank_row.copy()
        design_results[crispr][target_transcript]['actual_vs_total_hits'] = str(actual_hits + '/' + total_hits)

print ("+Reading: "+'/output/crispr_designs.txt')
with open(data_dir + '/output/crispr_designs.txt', 'r') as designs:
    for line in designs:
        line = line.strip()
        info = line.split('\t')

        crispr = info[1]
        transcript = info[0].split(';')[0]
        distance_to_start = info[0].split(';')[1]

        if len(info[0].split(';')) == 3:
            missing_start = 'missing_start:True'
        else:
            missing_start = 'missing_start:False'

        if crispr in design_results:
            design_results[crispr][transcript]['transcript']=transcript
            design_results[crispr][transcript]['distance_to_start']= distance_to_start
            design_results[crispr][transcript]['missing_start'] =missing_start

print ("+Reading: "+ data_dir + '/output/seed_scores.txt')
with open(data_dir + '/output/seed_scores.txt', 'r') as scores:
    for line in scores:
        line = line.strip()
        info = line.split('\t')

        crispr = info[1]
        seed_score = info[2]

        if crispr in design_results:
            for transcript in design_results[crispr]:
                design_results[crispr][transcript]['seed_score']=seed_score

print ("+Reading: "+data_dir + '/output/eff_scores.txt')
with open(data_dir + '/output/eff_scores.txt', 'r') as scores:
    for line in scores:
        line = line.strip()
        info = line.split('\t')

        crispr = info[0]
        eff_score = info[1]

        if crispr in design_results:
            for transcript in design_results[crispr]:
                design_results[crispr][transcript]['eff_score']=eff_score
                #design_results[crispr][transcript].append(eff_score)

# check these last because designs w/ no off-targets don't have score
print ("+Reading: "+data_dir +  '/output/ote_scores.txt')
with open(data_dir + '/output/ote_scores.txt', 'r') as scores:
    for line in scores:
        line = line.strip()
        info = line.split('\t')

        crispr = info[0]
        ote_score = info[1]

        if crispr in design_results:
            for transcript in design_results[crispr]:
                design_results[crispr][transcript]['ote_score']=ote_score
                #design_results[crispr][transcript].append(ote_score)

for crispr in design_results:
    for transcript in design_results[crispr]:
        # missing ote score means 0 off-targets
        #if len(design_results[crispr][transcript]) != 7:
        if 'ote_score' not in design_results[crispr][transcript]:
            #design_results[crispr][transcript].append(0)
            design_results[crispr][transcript]['ote_score']=0

# store CDS to calculate percent coverage
# Then get the start/stop of all CDS for those genes.  Use in summary to calcuate the length.
#


print ("+Reading: "+data_dir +  '/output/transcript_ids.csv')
transcript_ids_csv = open(data_dir + '/output/transcript_ids.csv', 'r')
transcript_ids = transcript_ids_csv.read().split(',')
transcripts = makehash()

print ("+Reading: "+data_dir +  '/output/base_features.gtf')
with open(data_dir + '/input/base_features.gtf') as f:
    for line in f:
        line = line.strip()

        if line[0] == '#':
            continue

        seqid, source, feature, start, end, score, strand, frame, attribute = line.split('\t')

        if 'CDS' in feature:
            results = re.search('gene_id "(.+?)"; transcript_id "(.+?)";', attribute)
            gene = results.group(1)
            transcript = results.group(2)

            if transcripts[gene][transcript]:
                transcripts[gene][transcript].append([int(start), int(end)])
            else:
                transcripts[gene][transcript] = []
                transcripts[gene][transcript].append([int(start), int(end)])


# design_results[crispr][transcript] = [actual/total_hits, transcript_id, distance_to_start, missing_start, seed_score, eff_score, ote_score]
print ("+Writing: "+data_dir +  '/output/design_results.txt')
with open(data_dir + '/output/design_results.txt', 'w') as results:
    results.write('design\ttranscript_id\tactual/total_hits\tdistance_to_start\t' 
                + 'coverage\tmissing_start\tseed_score\teff_score\tote_score\tml_score\n')
    for crispr in design_results:
        for transcript in design_results[crispr]:
            info = design_results[crispr][transcript]
            gene = transcript2gene[transcript]

            CDS_length = 0
            for CDS in transcripts[gene][transcript]:
                CDS_length += CDS[1] - CDS[0] + 1

            # percent coverage = distance to start codon / CDS length
            if CDS_length == 0:
                print('gene: ' + gene + ' transcript: ' + transcript)
                coverage = 'not_annotated'
            else:
                coverage = str((float(info['distance_to_start']) / float(CDS_length))*100).split('.')[0] + '%'
                #print('coverage = ' + info[2] + '/' + str(CDS_length))
                #print(coverage)
            if coverage[0] == '-':
                coverage = '0%'

            results.write(crispr + '\t' + transcript + '\t' + info['actual_vs_total_hits'] + '\t' + info['distance_to_start'] + '\t' + coverage + '\t' 
                          + info['missing_start'] + '\t' + str(info['seed_score']) + '\t' + str(info['eff_score']) + '\t' + str(info['ote_score']) + '\n')

# format machine learning input csv
designs = []
with open(data_dir + '/output/design_results.txt', 'r') as f:
    next(f)
    for line in f:
        line = line.split('\t')
        designs.append(line[0])


print('+ Genereating input file for Machine Learning Score')

# with open('../machine_learning/Dmel-sgRNA-Efficiency-Prediction-master/designs.csv', 'w') as f:
print ('+ Writing : '+ data_dir + '/input_ml/designs.csv')
with open(data_dir + '/input_ml/designs.csv', 'w') as f:
     f.write('gRNA_23mer\n')
     for design in designs:
         f.write(design + '\n')
