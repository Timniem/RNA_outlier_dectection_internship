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
    time '1h'
    memory '16 GB'
    cpus 1
    
    publishDir "$params.output/counts", mode: 'copy'

    input:
        path inputFiles
        path mergescript
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
        path outriderCounts
        path externalCounts
    output:
        path "*.rds"
        path "*.tsv"

    script: 
        """
        Rscript ${params.outrider.outriderR} "${outriderCounts}" "outrider.rds" "result_table.tsv" "${params.samplesheet}" "${externalCounts}" "${params.extcounts.amount_outrider}"
        """
}
