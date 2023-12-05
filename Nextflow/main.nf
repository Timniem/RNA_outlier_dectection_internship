/**
Nextflow main OUTRIDER and FRASER Workflow

**/
nextflow.enable.dsl=2

include { Outrider_R; OutriderCount } from "./outrider/outrider"
include { Fraser } from "./fraser/fraser"

workflow Outrider_gene {
    OutriderCount('gene', params.featurecounts.genes_gtf)
    Outrider_R('gene',OutriderCount.out, params.extcounts.blood.genes)
}

workflow {
    Outrider_gene()
    Fraser()
}