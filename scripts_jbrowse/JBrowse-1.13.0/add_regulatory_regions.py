#!usr/bin/env python3
from subprocess import Popen, PIPE

# Jonathan Rodiger - 2020

datasets = ['FlyBase_Regulatory_Regions', 'GMR_Brain_exp_1_REDfly_CRMs', 'REDfly_CRMs', 'VDRC_VT_REDfly_CRMs']

for dataset in datasets:
	filename = dataset + '.bed'
	track_label = dataset

	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/regulatory_regions/'+filename, '--tracklabel', track_label, '--config', '{ "category" : "Regulatory Regions" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(track_label + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))
