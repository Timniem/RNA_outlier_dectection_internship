#!/bin/bash
#SBATCH --job-name=outrider_run
#SBATCH --output=outrider_%j.out
#SBATCH --error=outrider_%j.err
#SBATCH --time=05:59:59
#SBATCH --cpus-per-task=10
#SBATCH --mem=100gb
#SBATCH --nodes=1
#SBATCH --export=NONE
#SBATCH --get-user-env=60L
#SBATCH --tmp=4gb

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            SAMPLESHEET="$2"
            shift # past argument
            shift # past value
            ;;
        -a|--annotation)
            ANNOTATION="$2"
            shift # past argument
            shift # past value
            ;;
        -o|--output)
            OUTPUT="$2"
            shift # past argument
            shift # past value
            ;;
        -e|--extcounts)
            EXTCOUNTS="$2"
            shift # past argument
            shift # past value
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

echo "Samplesheet= ${SAMPLESHEET}"
echo "Annotation= ${ANNOTATION}"
echo "Output= ${OUTPUT}"
echo "External counts= ${EXTCOUNTS}"

#generated variables
counts_file="$OUTPUT/outrider_counts.txt"
outrider_ods_out="$OUTPUT/outrider.rds"

# Get the BAM's for featurecount
eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate outrider_env

Rscript Combined_OUTRIDER_FRASER/featurecounts.R $SAMPLESHEET $ANNOTATION $counts_file

Rscript Combined_OUTRIDER_FRASER/outrider.R $counts_file $outrider_ods_out $EXTCOUNTS
