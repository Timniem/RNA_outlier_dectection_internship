/**
Nextflow main OUTRIDER and FRASER Workflow

**/
nextflow.enable.dsl=2

include { Outrider; OutriderCount } from "./outrider/outrider"
include { Fraser; MergeCounts; FraserCount } from "./fraser/fraser"

workflow Outrider_gene {
    OutriderCount('gene', params.featurecounts.genes_gtf)
    Outrider('gene',OutriderCount.out, params.extcounts.blood.genes)
}

workflow Fraser_ext {
    FraserCount()
    MergeCounts(FraserCount.out, params.extcounts.blood.annotation_file, params.extcounts.blood.split_counts, params.extcounts.blood.non_split_counts)
    Fraser(MergeCounts.out.settingstable_fraser, MergeCounts.out.splitcounts_fraser, MergeCounts.out.nonsplitcounts_fraser)
}

workflow {
    //Outrider_gene()
    Fraser_ext()
}