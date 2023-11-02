#!/bin/bash
#SBATCH --job-name=fraser
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=01:59:59
#SBATCH --cpus-per-task=12
#SBATCH --mem=64gb
#SBATCH --nodes=1
#SBATCH --export=NONE
#SBATCH --get-user-env=60L
#SBATCH --tmp=4gb

input=/groups/umcg-gdio/tmp01/umcg-tniemeijer/fraser/sampleTables/sampletable_ext.tsv
output=/groups/umcg-gdio/tmp01/umcg-tniemeijer/fraser/fraser_output_3
file_out_name=fraser_obj

eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate fraser_env

Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/fraser/fraser_findq_run.R $input $output $file_out_name

