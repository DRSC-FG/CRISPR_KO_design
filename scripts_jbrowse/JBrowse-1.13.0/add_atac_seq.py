#!usr/bin/env python3
from subprocess import Popen, PIPE

# Jonathan Rodiger - 2020

with open('atac_seq_metadata.tsv', 'r') as f:
	header = next(f)
	for line in f:
		data = line.strip().split('\t')

		track_id = data[0]
		track_name = data[1]
		GEO_Accession = data[2]

		track_name = track_name.replace(' ', '_')

		filename = track_name + '_' + track_id + '_' + GEO_Accession + '.bed'

		track_label = filename.split('.bed')[0]

		process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/atac-seq/'+filename, '--tracklabel', track_label, '--config', '{ "category" : "ATAC-seq" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
		stdout, stderr = process.communicate()
		print(track_name + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))
