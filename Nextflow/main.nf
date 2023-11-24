/**
Nextflow main OUTRIDER FRASER Workflow

**/
nextflow.enable.dsl=2

include { Outrider_R; FeatureCount } from "./outrider/outrider"
include { Fraser } from "./fraser/fraser"

workflow Outrider_gene {
    FeatureCount('gene', params.featurecounts.genes_gtf)
    Outrider_R('gene',FeatureCount.out)
}
workflow Outrider_intron {
    FeatureCount('intron', params.featurecounts.introns_gtf)
    Outrider_R('intron', FeatureCount.out)
}
workflow Outrider_exon {
    FeatureCount('exon', params.featurecounts.transcripts_gtf)
    Outrider_R('exon', FeatureCount.out)
}

workflow {
    Outrider_gene()
    Outrider_intron()
    Outrider_exon()
    Fraser()
}