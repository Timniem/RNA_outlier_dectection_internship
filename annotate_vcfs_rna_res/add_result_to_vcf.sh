#!/bin/bash

ml BCFtools
ml BEDTools

in_bed=test.bed
input_vcf=/groups/umcg-gdio/tmp01/umcg-tniemeijer/samples/dna/PID/pid7.vcf.gz
header_file=/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/resources/FRASER_annots.hdr
columns_fraser="CHROM,FROM,TO,INFO/FRASER_SPLICE_ABERRANT_PVAL,FRASER_SPLICE_ABERRANT_DELTAPSI"
columns_outrider="CHROM,FROM,TO,INFO/OUTRIDER_EXPRESSION_ABERRANT_PVAL,OUTRIDER_EXPRESSION_ABERRANT_ZSCORE"
columns_MAE="CHROM,FROM,TO,INFO/FRASER_SPLICE_ABERRANT_PVAL,FRASER_SPLICE_ABERRANT_DELTAPSI"

bedtools sort -i $in_bed > sorted_aberrant_locations.bed
bcftools sort $input_vcf -o sorted_input.vcf
bcftools annotate -a sorted_aberrant_locations.bed -h $header_file -c $columns_fraser sorted_input.vcf -o annotated_output.vcf
