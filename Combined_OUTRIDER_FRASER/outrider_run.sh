#!/bin/bash
#SBATCH --job-name=outrider_run
#SBATCH --output=outrider_%j.out
#SBATCH --error=outrider_%j.err
#SBATCH --time=03:59:59
#SBATCH --cpus-per-task=10
#SBATCH --mem=80gb
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
featurecount_out="$OUTPUT/outrider_featurecount.txt"
converted_matrix_path="${featurecount_out%.txt}.Rmatrix.txt"
outrider_ods_out="$OUTPUT/outrider.rds"

# Get the BAM's for featurecount
BAM_PATHS=()
for BAM in `cut -f2 $SAMPLESHEET`; do BAM_PATHS+=($BAM); done
BAM_PATHS=("${BAM_PATHS[@]:1}") #removed the 1st element

SAMPLE_NAMES=()
for SAMPLE in `cut -f1 $SAMPLESHEET`; do SAMPLE_NAMES+=($SAMPLE); done
SAMPLE_NAMES=("${SAMPLE_NAMES[@]:1}") #removed the 1st element

# Loading featureCounts environment
eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate featurecounts

# feature counts -p = paired end data=True, -s 1 = forward stranded? -a = annotation file
# -o output file, followed by the input BAM(s)
echo "$(date) -  Starting featurecounts"


featureCounts -p -s 1 -T 8 \
    -a $ANNOTATION \
    -o $featurecount_out "${BAM_PATHS[@]}"

mamba deactivate

# Running R script for Entrez annotation and remove unnecessary headers 

mamba activate r-notebook-kernel
# First argument = path of the txt file from featureCount, second argument = the desired output path

Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/outrider_fraser/format_count_file.R $featurecount_out $converted_matrix_path $SAMPLESHEET

mamba deactivate

eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate outrider_env

Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/outrider_fraser/outrider_findq_run.R $converted_matrix_path $outrider_ods_out $EXTCOUNTS
