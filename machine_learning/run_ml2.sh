#!/bin/bash

#SBATCH -p long
#SBATCH -t 17-12:0:0
#SBATCH --mem=250G
#SBATCH -o logs/ml_%j.out
#SBATCH -e logs/ml_%j.err

module load python/3.6.0
module load gcc/6.2.0 R/3.5.1-extra
#source ../machine_learning/Dmel-sgRNA-Efficiency-Prediction-master/ml_env/bin/activate
source /n/groups/flyrnai/jon/mosquito_crisprs/machine_learning/Dmel-sgRNA-Efficiency-Prediction-master/ml_env/bin/activate
#echo 'R_LIBS_USER="~/R-3.5.1/library"' >  $HOME/.Renviron

# So R doesn't listen to env Variable when run on O2.  So they use the .Renviron file above.  But then every time you run R 
# you need to adjust. This sucks.  So I put the env in the R file itself.  Rpreprocessing/sgRNA_Input_Processing.R

export R_LIBS_USER="/n/groups/flyrnai/environments/R/R_3.5.1/library"

echo "--- Starting "
echo "input dir:"
echo $1
#srun python3 dMel_CRISPR_efficiency.py --csv ../data/input_ml/designs.csv
srun python3 dMel_CRISPR_efficiency.py --csv $1/input_ml/designs.csv
echo "--- Done "
