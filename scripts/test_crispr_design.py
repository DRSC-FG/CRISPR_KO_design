#!usr/bin/env python3
from Bio import SeqIO
import collections
import sys
import re

### Step 1: get crispr designs ###
#                                #
# Jonathan Rodiger - 2019        #
#                                #
##################################

if (len(sys.argv) == 3 and sys.argv[1] == '-path'):
    data_dir = sys.argv[2]
    print ('+Reading: '+ data_dir + '/output/transcript_ids.csv')
    transcript_ids_csv = open(data_dir + '/output/transcript_ids.csv', 'r')
    transcript_ids = transcript_ids_csv.read().split(',')
else:
    print('Error: wrong input format')
    print('Usage: python 1-get_crispr_designs.py -in <data_dir>\n')
    exit()

# allows initialization of multi-key hashes like:
# dict['key1']['key2']['key3'] = 'val'
def makehash():
    return collections.defaultdict(makehash)


# Returns hash of features of interest for all protein-coding transcripts from given file,
# assuming it's in GTF format.
def read_gtf(filename, transcript_ids):
    transcripts = makehash()

    f = open(filename, 'r')
    for line in f:
        line = line.strip()

        if line[0] == '#':
            continue

        seqid, source, feature, start, end, score, strand, frame, attribute = line.split('\t')

        # only store start codon and UTRs
        if 'start_codon' in feature or 'stop_codon' in feature or 'transcript' in feature or 'CDS' in feature or 'exon' in feature:
            # extract gene and transcript IDs
            results = re.search('gene_id "(.+?)"; transcript_id "(.+?)";', attribute)
            gene = results.group(1)
            transcript = results.group(2)

            # only store transcripts of interest and skip RNA
            if transcript not in transcript_ids or 'Trna' in gene:
                continue

            # can be multiple UTRs

            if not (transcripts[gene][transcript]['CDS']):
                transcripts[gene][transcript][feature] = []
                transcripts[gene][transcript]['lowest_CDS'] = 10000000000000
                transcripts[gene][transcript]['highest_CDS'] = 0


            if not (transcripts[gene][transcript]['exon']):
                transcripts[gene][transcript][feature] = []
                transcripts[gene][transcript]['lowest_exon'] = 10000000000000
                transcripts[gene][transcript]['highest_exon'] = 0

            if not (transcripts[gene][transcript][feature]):
                transcripts[gene][transcript][feature] = []

            transcripts[gene][transcript][feature].append([int(start), int(end)])
            transcripts[gene][transcript]['strand'] = strand

            start=int(start)
            end=int(end)
            if feature=='CDS':
                print ("checking CDS: "+ str(start))
                if  transcripts[gene][transcript]['lowest_CDS'] > start:
                    print ("setting start")
                    transcripts[gene][transcript]['lowest_CDS'] = start

                if transcripts[gene][transcript]['highest_CDS'] < end:
                    print ("setting end")
                    transcripts[gene][transcript]['highest_CDS'] = end


            if feature=='exon':
                print ("checking exon: "+ str(start))
                if  transcripts[gene][transcript]['lowest_exon'] > start:
                    print ("setting start")
                    transcripts[gene][transcript]['lowest_exon'] = start

                if transcripts[gene][transcript]['highest_exon'] < end:
                    print ("setting end")
                    transcripts[gene][transcript]['highest_exon'] = end



    f.close()
    print (transcripts)
    return transcripts


# Returns list of sequences from given file, assuming it's in FASTA format.
def read_fasta(gtf, fasta):
    print ("+---Read Fasta-----------------------------------------------transcripts.fa+");
    sequences = {}

    for record in SeqIO.parse(fasta, "fasta"):
        seqid = record.id
      
        match = re.findall(r'\((.*?)\)', record.description)
        #print (record.description)
        #print (match)
        gene = match[0]
        #gene = record.description.split('gene:')[1]
        
        seq = record.seq

        if gtf[gene][seqid]:
            # get features if they exist
            features = gtf[gene][seqid]

            if features['start_codon']:
                start_codon = features['start_codon']
                print ("-found start_codon:")
                print (start_codon)
            else:
                start_codon = ''

            if (features ['highest_exon'] != 0 and features ['highest_CDS']!=0):
                three_prime_utr = features ['highest_exon']- features['highest_CDS'] 

            if (features ['lowest_exon'] != 0 and features ['lowest_CDS']!=0):
                five_prime_utr = features ['lowest_CDS']- features['lowest_exon'] 


            #five_prime_utr = features['five_prime_utr']
            print ("-five_prime_utr length: "+ str (five_prime_utr))
            #three_prime_utr = features['three_prime_utr']
            print ("-three_prime_utr length: "+ str (three_prime_utr))
            strand = features['strand']
            print ("-strand : ")
            print (strand)

            #five_prime_offset = 0
            #for utr in five_prime_utr:
            five_prime_offset = five_prime_utr

            #three_prime_offset = 0
            #for utr in three_prime_utr:
            three_prime_offset = three_prime_utr

            # treats stop codon as CDS despite gtf annotation
            if five_prime_utr and three_prime_utr:
                print ("--1")
                sub_seq = seq[five_prime_offset:three_prime_offset * -1]
            elif five_prime_utr:
                print ("--2")
                sub_seq = seq[five_prime_offset:]
            elif three_prime_utr:
                print ("--3")
                sub_seq = seq[:three_prime_offset * -1]
            else:
                sub_seq = seq
            print (seqid + ';' + strand + ';' + str(start_codon)+'  ='+ sub_seq)
            sequences[seqid + ';' + strand + ';' + str(start_codon)] = sub_seq
            print (seqid+": length: "+ str(len(sub_seq)))
    return sequences


# Traverses through given sequence list and prints all k-mers
#
# Output format:
# --------------
#   COL     DESC
#   1       gene name;distance to start codon/utr
#   2       kmer sequence
def print_kmers(sequences):
    # output file
    print ('+Writing: '+data_dir + '/output/crispr_designs.txt')
    f = open(data_dir + '/output/crispr_designs.txt', 'w')

    for key in sequences:
        seqid, strand, start_codon = key.split(';')

        seq = sequences[key]

        position = 0
        while position <= len(seq) - 23:
            kmer = seq[position:position+23]
            revcom = kmer.reverse_complement()

            note = ''
            if start_codon != '':
                distance_to_start = position - 3
            else:
                note = ';missing_start'
                distance_to_start = position

            if check_design(kmer):
                f.write(seqid + ';' + str(distance_to_start) + note + '\t' + str(kmer) + '\n')
            if check_design(revcom):
                f.write(seqid + ';' + str(distance_to_start) + note + '\t' + str(revcom) + '\n')

            position += 1

    f.close()


# Checks CRISPR design; returns true if CRISPR ends with 'NGG' and does not
# contain U6 terminator ('TTTT'). (Ignore T's found in PAM)
def check_design(crispr):
    result = re.search("([ACGT]{20})[ACGT]GG", str(crispr))
    if result:
        return 'TTTT' not in result.group(1)
    else:
        return False


print ("+Reading: "+data_dir + '/input//base_features.gtf')
gtf = read_gtf(data_dir + '/input/base_features.gtf', transcript_ids);

transcripts = read_fasta(gtf, data_dir + '/input/transcripts.fa')
print_kmers(transcripts)
