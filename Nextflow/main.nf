/**
Nextflow main OUTRIDER and FRASER Workflow

**/
nextflow.enable.dsl=2

include { Outrider; OutriderCount } from "./outrider/outrider"
include { Fraser; MergeCounts; FraserCount } from "./fraser/fraser"

workflow Outrider_gene {
    OutriderCount('gene', params.featurecounts.genes_gtf)
    Outrider('gene',OutriderCount.out, params.extcounts.blood)
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

workflow {
    Outrider_gene()
    Fraser_ext()
}