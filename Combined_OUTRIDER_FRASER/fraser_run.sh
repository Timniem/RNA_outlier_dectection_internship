#!/bin/bash
#SBATCH --job-name=fraser_run
#SBATCH --output=fraser_%j.out
#SBATCH --error=fraser_%j.err
#SBATCH --time=05:59:59
#SBATCH --cpus-per-task=11
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
        -o|--output)
            OUTPUT="$2"
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
echo "Output= ${OUTPUT}"

eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate fraser_env

Rscript Combined_OUTRIDER_FRASER/fraser.R $SAMPLESHEET $OUTPUT