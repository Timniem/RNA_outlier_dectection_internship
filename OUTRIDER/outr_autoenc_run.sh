#!/bin/bash
#SBATCH --job-name=findq_test
#SBATCH --output=findq_test.out
#SBATCH --error=findq_test.err
#SBATCH --time=04:00:01
#SBATCH --cpus-per-task=16
#SBATCH --mem=64gb
#SBATCH --nodes=1
#SBATCH --export=NONE
#SBATCH --get-user-env=60L
#SBATCH --tmp=4gb


input=/groups/umcg-gdio/tmp01/umcg-tniemeijer/featurecounts/output/feature_sjo_output.Rmatrix.txt
output=/groups/umcg-gdio/tmp01/umcg-tniemeijer/outrider/output/feature_sjo_output.ods

eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate outrider_env

Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/outrider/outr_autoencoder.R $input $output


