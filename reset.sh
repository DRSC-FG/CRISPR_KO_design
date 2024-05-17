#cleanup input and output files


DATA_DIR=data_tick


echo "cleaning Machine Learning dir"
rm logs/*
rm $DATA_DIR/blast_dbs/*
rm $DATA_DIR/input/*
rm $DATA_DIR/input_ml/*
rm $DATA_DIR/ouput/*

echo "cleaning Machine Learning dir"
rm machine_learning/23mer_sgRNA_predictions.csv
rm machine_learning/logs/*
rm machine_learning/Rpreprocessing/R_Featurized_sgRNA.csv
echo "done"
