#!usr/bin/env python3
import sys

# Jonathan Rodiger - 2020


# pulls in blast_report looking for coordinates of sequence
# of final design reults.
# only uses "on-target" blast hits and designs that don't cut transcripts.
# It filters non ontarget results

# Write gff3 for JBrowse

if (len(sys.argv) == 3 and sys.argv[1] == '-in'):
	species = sys.argv[2]
else:
	print('Error: wrong input format')
	print('Usage: python 10-designs_gff3.py -in <species>\n')
	exit()

designs = {}
# load design info
print ("+Reading: "+ species + '/output/final_design_results_filtered.txt')
with open(species + '/output/final_design_results_filtered.txt', 'r') as f:
	header = next(f)
	for line in f:
		data = line.strip('\n').split('\t')
		# skip designs that don't cut any transcripts
		if data[2][0] == '0':
			continue
		designs[data[0]] = data

# parse blast output for genome coordinates
print ("+Reading: "+species +  '/output/blast_report.txt')
with open(species + '/output/blast_report.txt', 'r') as f:
	header = next(f)
	for line in f:
		line = line.strip('\n')

		(chromosome, start,   stop,    q_start,      q_end, 
		 crispr,     strand,  base,    subject_seq,  alignment,
		 ot1,        ot2,     ot_pam,  ot_type) = line.split('\t')

		if ot_type != 'On-Target':
			continue

		# some designs from blast report already removed
		try:
			designs[crispr].append(chromosome)
			designs[crispr].append(start)
			designs[crispr].append(stop)
			designs[crispr].append(strand)
		except KeyError as e:
			pass

# write gff3 for jbrowse
print ("+Writing:"+ species + '/jbrowse/designs.gff3')
with open(species + '/jbrowse/designs.gff3', 'w') as out:
	for crispr in designs:
		# designs without on target hits
		if len(designs[crispr]) != 14:
			print(crispr)
			continue
		# design info
		transcipt     = designs[crispr][1]
		hits          = designs[crispr][2]
		distance      = designs[crispr][3]
		coverage      = designs[crispr][4]
		missing_start = designs[crispr][5]
		seed_score    = designs[crispr][6]
		eff_score     = designs[crispr][7]
		ote_score     = designs[crispr][8]
		ml_score      = designs[crispr][9]
		chrom         = designs[crispr][10]
		start         = designs[crispr][11]
		stop          = designs[crispr][12]
		strand        = designs[crispr][13]
		# ensure start is before stop
		if start > stop:
			tmp = start
			start = stop
			stop = tmp
		# gff entry
		gff_entry = [
			chrom,      # seq id
			'.',        # source
			'CRISPR',   # feature
			str(start), # start
			str(stop),  # stop
			'.',        # score
			strand,     # strand
			'.',        # frame
			''          # description
		]
		# check for missing annotation
		if missing_start == 'missing_start:True':
			missing_start = '(Missing Start Codon Annotation)'
		else:
			missing_start = ''
		# jbrowse pop up content
		gff_entry[8] = ('Name=' + crispr + '; Note=' 
			+ transcipt + '<br>' + crispr + '<br>' 
			+ 'Efficiency:' + eff_score
			+ ' OT:' + ote_score
			+ ' SeedScore:' + seed_score
			+ ' MachineLearning:' + ml_score
			+ '<br>Actual/Total Hits:' + hits
			+ ' Distance to Start:' + distance
			+ ' Coverage:' + coverage
			+ '<br>' + missing_start)
		# write gff3 entry
		out.write('\t'.join(gff_entry) + '\n###\n')
