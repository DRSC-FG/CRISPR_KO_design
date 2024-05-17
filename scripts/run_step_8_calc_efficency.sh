#!/bin/bash

#SBATCH -p priority
#SBATCH -t 0:10:0
#SBATCH --mem=1G
#SBATCH -o step_8_efficency_%j.out
#SBATCH -e step_8_efficency%j.err

# IMPORTANT NOTE: TMP file used, only run one species at a time

module load perl/5.24.0

srun perl scripts/8_calculate_efficiency.pl -in data
