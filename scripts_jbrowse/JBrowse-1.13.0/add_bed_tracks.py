#!usr/bin/env python3
from subprocess import Popen, PIPE

# Jonathan Rodiger - 2020

# cmd to add bed tracks:
# bin/flatfile-to-json.pl --bed data/bed/modENCODE_628.bed --tracklabel bab1_modENCODE_628 --config '{ "category" : "Annotated modENCODE"  }' --className feature2 --arrowheadClass

# bed files by data source
bdtnp = ['bdtnpBcd1Fdr1.bed','bdtnpD1Fdr1.bed','bdtnpDa2Fdr1.bed','bdtnpGt2Fdr1.bed','bdtnpH1Fdr1.bed','bdtnpHkb1Fdr1.bed','bdtnpKr1Fdr1.bed','bdtnpMad2Fdr1.bed','bdtnpMed2Fdr1.bed','bdtnpRun1Fdr1.bed','bdtnpSna1Fdr1.bed','bdtnpTll1Fdr1.bed','bdtnpZ2Fdr1.bed']

e_tabm = ['E-TABM-648.bed','E-TABM-650.bed','E-TABM-652.bed']

gsm = ['GSM1228847.bed','GSM1228849.bed','GSM1228853.bed','GSM1645140.bed','GSM2042226.bed','GSM2199201.bed','GSM763061.bed','GSM994682.bed','GSM994694.bed']

modencode = ['modEncode_2573.bed','modEncode_2641.bed','modEncode_2642.bed','modEncode_3390.bed','modEncode_3395.bed','modEncode_3806.bed','modEncode_3826.bed','modEncode_4070.bed','modEncode_4095.bed','modEncode_4096.bed','modEncode_4974.bed','modEncode_4998.bed','modEncode_5004.bed','modEncode_5008.bed','modEncode_5017.bed','modEncode_5023.bed','modEncode_5025.bed','modEncode_5028.bed','modEncode_604.bed','modEncode_615.bed','modEncode_616.bed','modEncode_618.bed','modEncode_628.bed']

# additional tracks from modERN + modENCODE
track_names = []
with open('track_names.txt', 'r') as f:
	for line in f:
		filename = line.strip()
		track_names.append(filename)

for filename in track_names:
	track_name = filename.split('.bed')[0]
	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/bed/cell_lines/'+filename, '--tracklabel', track_name, '--config', '{ "category" : "Peak Locations" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(track_name + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

# # load dataset to symbol mapping
# data2symbol = {}
# with open('data2symbol.tsv', 'r') as f:
# 	for line in f:
# 		data = line.strip('\n').split('\t')
# 		data2symbol[data[1]] = data[0]

# for filename in bdtnp:
# 	data_id = filename.split('.')[0]
# 	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/bed/'+filename, '--tracklabel', data2symbol[data_id]+'_'+data_id, '--config', '{ "category" : "Annotated bdtnp" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
# 	stdout, stderr = process.communicate()
# 	print(data2symbol[data_id]+'_'+data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

# for filename in e_tabm:
# 	data_id = filename.split('.')[0]
# 	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/bed/'+filename, '--tracklabel', data2symbol[data_id]+'_'+data_id, '--config', '{ "category" : "Annotated E-TABM" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
# 	stdout, stderr = process.communicate()
# 	print(data2symbol[data_id]+'_'+data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

# for filename in gsm:
# 	data_id = filename.split('.')[0]
# 	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/bed/'+filename, '--tracklabel', data2symbol[data_id]+'_'+data_id, '--config', '{ "category" : "Annotated GSM" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
# 	stdout, stderr = process.communicate()
# 	print(data2symbol[data_id]+'_'+data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

# for filename in modencode:
# 	data_id = filename.split('.')[0]
# 	process = Popen(['bin/flatfile-to-json.pl', '--bed', 'data/bed/'+filename, '--tracklabel', data2symbol[data_id]+'_'+data_id, '--config', '{ "category" : "Annotated modENCODE" }', '--className', 'feature2', '--arrowheadClass', '""'], stdout=PIPE, stderr=PIPE)
# 	stdout, stderr = process.communicate()
# 	print(data2symbol[data_id]+'_'+data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))
