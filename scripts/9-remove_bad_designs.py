#!usr/bin/env python3
import sys

# Jonathan Rodiger - 2019

# Check for off-targets in blast report w/ only mismatch in N of PAM (-NGG/-NAG)

if (len(sys.argv) == 3 and sys.argv[1] == '-in'):
    data_dir = sys.argv[2]
else:
    print('Error: wrong input format')
    print('Usage: python 9-remove_bad_designs.py -in <data_dir>\n')
    exit()

bad_designs = {}
print ("+Reading: "+data_dir + '/output/blast_report.txt')
with open(data_dir + '/output/blast_report.txt', 'r') as f:
	for line in f:
		line = line.strip('\n').split('\t')
		if line[10] == '0' and line[11] == '0' and line[9][20] == 'X':
			bad_designs[line[5]] = None


# Only include crisprs in this list.
crispr_designs = {}
print ("+Reading: "+data_dir + '/output/crispr_designs.txt')
count=0
with open(data_dir + '/output/crispr_designs.txt', 'r') as f:
	for line in f:
		line = line.strip('\n').split('\t')
                key=line[1]
                count=count+1
                if count<40:
                    print (key)
		crispr_designs[key]=0

results = []
print ("+Reading: "+data_dir + '/output/final_design_results.txt')
with open(data_dir + '/output/final_design_results.txt', 'r') as f:
	header = next(f)
	for line in f:
            splitLine = line.split('\t')
            if splitLine[0] in bad_designs:
                continue
		# some designs w/ no on-target hits weren't being removed
            if splitLine[2][0] == '0':
                print("nohit:"+ line.split('\t')[0])
                continue
            if splitLine[0] not in crispr_designs:
                print ("no design:"+line[0]);
                continue



            #		if line.split('\t')[4] != 'not_annotated':
            #			# check that coverage isn't above 100%
            #			if int(line.split('\t')[4].strip('%')) > 100:
            #				print('Error: ' + line)
            #				exit()

            #build up results
            results.append(line)

print ("+Writing: "+data_dir + '/output/final_design_results_filtered.txt')
with open(data_dir + '/output/final_design_results_filtered.txt', 'w') as out:
	out.write(header)
	for line in results:
		out.write(line)
