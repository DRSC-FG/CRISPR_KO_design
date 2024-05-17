#!usr/bin/env python3
from subprocess import Popen, PIPE

# Jonathan Rodiger - 2020

print('Processing Track...')
process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/bed/conservation/nucmer_results.bed', '--tracklabel', 'Conserved Regions', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
stdout, stderr = process.communicate()
print(stdout.decode('utf-8') + stderr.decode('utf-8'))
