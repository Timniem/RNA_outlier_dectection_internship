#!/usr/bin/env nextflow
/**
Nextflow OUTRIDER workflow
using Rsubreads featureCounts to get count matrices, uses Gagneur-lab OUTRIDER
for calling outliers. 
Results will be stored in a outrider dataset (*.rds) and a resultsfile (*.tsv)
**/
nextflow.enable.dsl=2

process OutriderCount {
    time '1h'
    memory '16 GB'
    cpus 10

    publishDir "$workDir/counts", mode: 'copy'

    input:
        val mode
        val gtf
    output:
        path "outrider_counts_${mode}.txt"
        path "outrider_count_summary.tsv"
    script:
        """
        echo "${gtf}"
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate outrider_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/outrider/featurecounts.R ${params.samplesheet} ${gtf} "outrider_counts_${mode}.txt"
        """
}

process Outrider {
    time '8h'
    memory '32 GB'
    cpus 4

    publishDir "$workDir/outrider", mode: 'copy'

    input:
        val mode
        path outriderCounts
        path externalCounts
    output:
        path "*.rds"
        path "*.tsv"

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate outrider_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/outrider/outrider.R "${outriderCounts}" "outrider_${mode}.rds" "result_table_${mode}.tsv" "${params.samplesheet}" "${externalCounts}" "${params.extcounts.amount_outrider}"
        """
}
