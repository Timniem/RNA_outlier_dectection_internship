#!/usr/bin/env nextflow
/**
Nextflow OUTRIDER workflow

**/
nextflow.enable.dsl=2

params.samplesheet = '/groups/umcg-gdio/tmp01/umcg-tniemeijer/outrider_fraser/sampletables/sampletable.tsv'

process FeatureCount {
    time '1h'
    memory '16 GB'
    cpus 10

    publishDir "$params.output/counts", mode: 'copy'

    input:
        val mode
        val gtf
    output:
        path "outrider_counts_${mode}.txt"
    
    script:
        """
        echo "${gtf}"
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate outrider_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/Nextflow/outrider/featurecounts.R ${params.samplesheet} ${gtf} "outrider_counts_${mode}.txt"
        """
}

process Outrider_R {
    time '6h'
    memory '100 GB'
    cpus 10

    publishDir "$params.output/outrider", mode: 'copy'

    input:
        val mode
        path outriderCounts
    output:
        path "outrider_${mode}.rds"

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate outrider_env
        Rscript ${projectDir}/resources/outrider/outrider.R "${outriderCounts}" "outrider_${mode}.rds"
        """
}

