#!/usr/bin/env nextflow
/**
Nextflow workflow for adding annotation to DNA VCF from RNA outlier results
**/

nextflow.enable.dsl=2


process ResultsToBED {
    time '1h'
    memory '4 GB'
    cpus 1

    input:
        path sampleresults

    output:
        path "*.bed"

    script:
    """
    /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/convert_res_to_bed.py $sampleresults "results.bed"
    """
}

process AddAnnotationToVCF {
    time '1h'
    memory '4 GB'
    cpus 1

    input:
        path resultsbed
        path vcf
        path header_file
        val type

    output:
        path "*.vcf"

    script:
    """
    bash add_result_to_vcf.sh -b $resultsbed -v $vcf -o annotated_fraser_vcf.vcf -h $header_file -t $type
    """
}