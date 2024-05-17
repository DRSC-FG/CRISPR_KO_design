#!usr/bin/env python3
import sys

### Step 8: add ML scores ###
#                           #
# Jonathan Rodiger - 2019   #
# Aram Comjean 2023         #
#                           #
#############################

if (len(sys.argv) == 3 and sys.argv[1] == '-path'):
    data_dir = sys.argv[2]
else:
    print('Error: wrong input format')
    print('Usage: python 8-add_ml_scores.py -in <data_dir>\n')
    exit()

ml_scores = {}
print ("+Reading: "+data_dir + '/output/ml_scores.csv')
with open(data_dir + '/output/ml_scores.csv', 'r') as f:
    #skip first line
    next(f)
    for line in f:
        line = line.strip().split(',')
        if len(line) >=2:
            key= line[0]
            #ml_scores.append(line[1][0:4])
            # set dictionary to machine learning score (first 4 chars of score)
            ml_scores[key]=line[1][0:4]

# Read design results and add machine learing score.

print ("+Reading: "+data_dir + '/output/design_results.txt')
with open(data_dir + '/output/design_results.txt', 'r') as f:

    print ("+Writing: "+data_dir + '/output/final_design_results.txt')
    with open(data_dir + '/output/final_design_results.txt', 'w') as out:
        header = next(f)
        out.write(header)

        for line in f:
            # get sequence
            linearray = line.strip().split('\t')
            key = linearray[0]
            if key in ml_scores:
                out.write(line.strip() + '\t' + ml_scores[key] + '\n')
            else: 
                out.write(line.strip() + '\t NONE  \n')

