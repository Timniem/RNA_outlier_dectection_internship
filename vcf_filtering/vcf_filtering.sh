# Script that filters vcf based on genes from OUTRIDER
# first creating a bed from genes.txt, followed by filtering the .vcf based on the bed with intersectBED\

module load BEDTools

genes_from_outrider=/groups/umcg-gdio/tmp01/umcg-tniemeijer/vcf_filter/test_filter.txt
genes_bed=/groups/umcg-gdio/tmp01/umcg-tniemeijer/vcf_filter/resources/genes_GRCh37.bed
outrider_genes_bed_output="${genes_from_outrider%.txt}.bed"
vcf_in=/groups/umcg-gdio/tmp01/umcg-tniemeijer/vcf_filter/J3_no_info.vcf.gz
vcf_out="${vcf_in%.vcf.gz}_OUTRIDER_filtered.vcf"


grep -Fwf $genes_from_outrider $genes_bed | sed 's/^chr//' > $outrider_genes_bed_output


intersectBed -a $vcf_in -b $outrider_genes_bed_output -header > $vcf_out 

