#!/usr/bin/env nextflow
/**
Nextflow OUTRIDER workflow
using Rsubreads featureCounts to get count matrices, uses Gagneur-lab OUTRIDER
for calling outliers. 
Results will be stored in a outrider dataset (*.rds) and a resultsfile (*.tsv)
**/
nextflow.enable.dsl=2

process OutriderCount {
    time '30m'
    memory '8 GB'
    cpus 4

    publishDir "$params.output/counts", mode: 'copy'

    input:
        tuple val(sampleID), path(bamFile), val(pairedEnd), val(strandSpecific)
    output:
        path "${sampleID}_outrider_counts.tsv"
    script:
        """
        Rscript ${params.outrider.outridercountsR} ${sampleID} ${bamFile} ${params.featurecounts.genes_gtf} ${pairedEnd} ${strandSpecific}
        """
}

process MergeOutridercounts {
    time '30m'
    memory '16 GB'
    cpus 1
    
    publishDir "$params.output/counts", mode: 'copy'

    input:
        tuple path(inputFiles), path(mergescript)
    output:
        path "merged_outrider_counts.txt"
    script:
    
        """
        Rscript ${mergescript} ${inputFiles}
        """
}


process CreateOutriderDataset{
    time '30m'
    memory '32 GB'
    cpus 1

    publishDir "$params.output/outrider", mode: 'copy'

    input:
        tuple path(outriderCounts), path(createOutriderDsScript)
    output:
        tuple path("outrider.rds"), path("q_values.txt")

    script: 
        """
        Rscript ${createOutriderDsScript} "${outriderCounts}" "outrider.rds" "${params.samplesheet}" "${params.extcounts.folder}" "${params.extcounts.amount_outrider}"
        """
}

process OutriderOptim{
    // Outrider optimize functions
    time '30m'
    memory '16 GB'
    cpus 1

    publishDir "$params.output/outrider/encdims", mode: 'copy'

    input:
        tuple path(outriderDataset), val(q_value), path(outriderOptimScript)
    output:
        path "*.tsv" // file with encdims specific to this Q.

    script: 
        """
        Rscript ${outriderOptimScript} "${outriderDataset}" "${q_value}"
        """
}

process MergeQfiles {
    // Outrider optimize functions
    time '1h'
    memory '16 GB'
    cpus 1
    
    publishDir "$params.output/counts", mode: 'copy'

    input:
        path inputFiles
    output:
        path "merged_outrider_counts.txt"
    script:
        """
        Rscript ${mergescript} ${inputFiles}
        """
}

process Outrider {
    time '10h'
    memory '64 GB'
    cpus 4

    publishDir "$params.output/outrider", mode: 'copy'

    input:
        path outriderDataset
        val best_q
    output:
        path "*.rds"
        path "*.tsv"

    script: 
        """
        Rscript ${params.outrider.outriderR} "${outriderDataset}" "outrider.rds" "result_table_outrider.tsv"
        """
}
