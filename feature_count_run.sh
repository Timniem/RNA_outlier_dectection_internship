#!/bin/bash
#SBATCH --job-name=feature_count_ps_test
#SBATCH --output=feature_count_test_ps.out
#SBATCH --error=feature_count_test_ps.err
#SBATCH --time=20:00:01
#SBATCH --cpus-per-task=8
#SBATCH --mem=16gb
#SBATCH --nodes=1
#SBATCH --export=NONE
#SBATCH --get-user-env=60L

# Loading environment
eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate featurecounts

# local variables
output_path=/groups/umcg-gdio/tmp01/umcg-tniemeijer/featurecounts/output/feature_sjo_output.txt
converted_matrix_path="${output_path%.txt}.Rmatrix.txt"
input_path=/groups/umcg-gdio/tmp01/umcg-kmaassen/samples/rnaseq/blood
annot_path=/groups/umcg-gdio/tmp01/umcg-kmaassen/resources/gtf/gencode.v34lift37.annotation.gtf

# change directory to input folder
cd $input_path

# feature counts -p = paired end data=True, -s 1 = forward stranded? -a = annotation file
# -o output file, followed by the input BAM(s)
featureCounts -p -s 1 \
    -a $annot_path \
    -o $output_path $input_path/*.bam

# Remove unnecessary headers 
cut -f1,7,8,9,10,11,12 \
    $output_path \
    > $converted_matrix_path

mamba deactivate
# Running R script for Entrez annotation
mamba activate r-notebook-kernel
Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/featurecounts/Entrez_annotation.R $converted_matrix_path
