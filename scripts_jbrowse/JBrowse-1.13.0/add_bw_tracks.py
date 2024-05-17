#!usr/bin/env python3
from subprocess import Popen, PIPE

# Jonathan Rodiger - 2020

# bigwig files by data source
bdtnp = ['bdtnpBcd1Fdr1.bw','bdtnpD1Fdr1.bw','bdtnpDa2Fdr1.bw','bdtnpGt2Fdr1.bw','bdtnpH1Fdr1.bw','bdtnpHkb1Fdr1.bw','bdtnpKr1Fdr1.bw','bdtnpMad2Fdr1.bw','bdtnpMed2Fdr1.bw','bdtnpRun1Fdr1.bw','bdtnpSna1Fdr1.bw','bdtnpTll1Fdr1.bw','bdtnpZ2Fdr1.bw']

e_tabm = ['E-TABM-648.bw','E-TABM-650.bw','E-TABM-652.bw']

gsm = ['GSM1228847.bw','GSM1228849.bw','GSM1228853.bw','GSM1645140.bw','GSM2042226.bw','GSM2199201.bw','GSM763061.bw','GSM994682.bw','GSM994694.bw']

modencode = ['modENCODE_2573.bw','modENCODE_2641.bw','modENCODE_2642.bw','modENCODE_3390.bw','modENCODE_3395.bw','modENCODE_3806.bw','modENCODE_3826.bw','modENCODE_4070.bw','modENCODE_4095.bw','modENCODE_4096.bw','modENCODE_4974.bw','modENCODE_4998.bw','modENCODE_5004.bw','modENCODE_5008.bw','modENCODE_5017.bw','modENCODE_5023.bw','modENCODE_5025.bw','modENCODE_5028.bw','modENCODE_604.bw','modENCODE_615.bw','modENCODE_616.bw','modENCODE_618.bw','modENCODE_628.bw']

# load dataset to symbol mapping
data2symbol = {}
with open('data2symbol.tsv', 'r') as f:
	for line in f:
		data = line.strip('\n').split('\t')
		data2symbol[data[1]] = data[0]

for filename in bdtnp:
	data_id = filename.split('.')[0]
	process = Popen(['bin/add-bw-track.pl', '--label', data2symbol[data_id]+'_'+data_id+'_bw', '--bw_url', 'bigwig/'+filename, '--plot', '--category', 'bdtnp', '--height', '25'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

for filename in e_tabm:
	data_id = filename.split('.')[0]
	process = Popen(['bin/add-bw-track.pl', '--label', data2symbol[data_id]+'_'+data_id+'_bw', '--bw_url', 'bigwig/'+filename, '--plot', '--category', 'E-TABM', '--height', '25'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

for filename in gsm:
	data_id = filename.split('.')[0]
	process = Popen(['bin/add-bw-track.pl', '--label', data2symbol[data_id]+'_'+data_id+'_bw', '--bw_url', 'bigwig/'+filename, '--plot', '--category', 'GSM', '--height', '25'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))

for filename in modencode:
	data_id = filename.split('.')[0]
	process = Popen(['bin/add-bw-track.pl', '--label', data2symbol[data_id]+'_'+data_id+'_bw', '--bw_url', 'bigwig/'+filename, '--plot', '--category', 'modENCODE', '--height', '25'], stdout=PIPE, stderr=PIPE)
	stdout, stderr = process.communicate()
	print(data_id + ' ' + stdout.decode('utf-8') + stderr.decode('utf-8'))
