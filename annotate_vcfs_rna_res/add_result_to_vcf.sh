#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bed)
            BED="$2"
            shift # past argument
            shift # past value
            ;;
        -v|--vcf)
            VCF="$2"
            shift # past argument
            shift # past value
            ;;
        -o|--output)
            OUTPUT="$2"
            shift # past argument
            shift # past value
            ;;
        -h|--header)
            HEADER="$2"
            shift # past argument
            shift # past value
            ;;
        -t|--type)
            TYPE="$2"
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

echo "Bed= ${BED}"
echo "Vcf= ${VCF}"
echo "Header= ${HEADER}"
echo "Output= ${OUTPUT}"
echo "Type= ${TYPE}"

ml BCFtools
ml BEDTools

case $TYPE in
    fraser|FRASER)
        columns="CHROM,FROM,TO,INFO/FRASER_SPLICE_ABERRANT_PVAL,FRASER_SPLICE_ABERRANT_DELTAPSI"
        ;;
    outrider|OUTRIDER)
        columns="CHROM,FROM,TO,INFO/OUTRIDER_EXPRESSION_ABERRANT_PVAL,OUTRIDER_EXPRESSION_ABERRANT_ZSCORE"
        ;;
    mae|MAE)
        columns="CHROM,FROM,TO,INFO/MAE_ABERRANT_PVAL,MAE_ABERRANT_LOG2FC"
esac

bedtools sort -i $BED > sorted_aberrant_locations.bed
bcftools sort $VCF -o sorted_input.vcf
bcftools annotate -a sorted_aberrant_locations.bed -h $HEADER -c $columns sorted_input.vcf -o $OUTPUT
