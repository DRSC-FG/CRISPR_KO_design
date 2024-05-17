#!usr/bin/env python3
from subprocess import Popen, PIPE

# Jonathan Rodiger - 2020

# filenames = ['FlyFactorSurvey_5k.bed', 'FlyFactorSurvey_10k.bed', 'Bulyk_5k.bed', 'Bulyk_10k.bed', 'Filtered_FlyFactorSurvey_5k.bed', 'Filtered_FlyFactorSurvey_10k.bed', 'Filtered_Bulyk_5k.bed', 'Filtered_Bulyk_10k.bed']
filenames = ['Filtered_Bulyk_5k.bed', 'Filtered_Bulyk_10k.bed']

for filename in filenames:
	data_id = filename.split('.')[0]
	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/motif_scan/updated_'+filename, '--tracklabel', data_id, '--config', '{ "category" : "Motif Scan" }'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))
