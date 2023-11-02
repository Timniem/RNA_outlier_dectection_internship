#!/bin/bash
#SBATCH --job-name=calc_coverage
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=01:59:59
#SBATCH --cpus-per-task=8
#SBATCH --mem=64gb
#SBATCH --nodes=1
#SBATCH --export=NONE
#SBATCH --get-user-env=60L
#SBATCH --tmp=4gb

module load BEDTools

pid_exons=/groups/umcg-gdio/tmp01/umcg-tniemeijer/coverage/PID_genes_exon.bed
bams_path=/groups/umcg-gdio/tmp01/umcg-kmaassen/samples/rnaseq/blood/pid/
output_folder=/groups/umcg-gdio/tmp01/umcg-tniemeijer/coverage/output/

for bam_file in $bams_path*
do
    if [ "${bam_file: -4}" == ".bam" ]
	then
        f="$(basename -- $bam_file)"
        in_path="${bams_path}${f}"
        out_path="${output_folder}${f%.bam}.coverage"
        echo $in_path
        echo $out_path
        bedtools bamtobed -i $in_path | bedtools coverage -b - -a $pid_exons > $out_path
    fi
done 