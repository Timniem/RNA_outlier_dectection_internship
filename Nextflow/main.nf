/**
Nextflow main OUTRIDER, FRASER and MAE Workflow
author: T Niemeijer
**/
nextflow.enable.dsl=2

include { Outrider; OutriderCount } from "./outrider/outrider"
include { Fraser; MergeCounts; FraserCount } from "./fraser/fraser"
include { MAEreadCounting; GetMAEresults } from "./MAE/MAE"

workflow Outrider_gene {
    OutriderCount('gene', params.featurecounts.genes_gtf)
    Outrider('gene',OutriderCount.out[0], params.extcounts.blood)
}

workflow Fraser_noext {
    FraserCount()
    Fraser(FraserCounts.out)
}

workflow Fraser_ext {
    FraserCount()
    MergeCounts(FraserCount.out, params.extcounts.blood)
    Fraser(MergeCounts.out)
}

workflow MonoAllelicExpression {
    Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> tuple( row.sampleID, row.vcf, row.bamFile ) }
    .filter { it[1] != null }
    .filter { it[1] != "NA" } | MAEreadCounting
    GetMAEresults(MAEreadCounting.out)
}

workflow {
    Outrider_gene()
    //Fraser_ext()
    //MonoAllelicExpression()
}