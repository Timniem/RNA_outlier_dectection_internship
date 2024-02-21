/**
Nextflow main OUTRIDER, FRASER and MAE Workflow
author: T Niemeijer
**/
nextflow.enable.dsl=2

include { Outrider; OutriderCount; MergeOutridercounts } from "./outrider/outrider"
include { Fraser; MergeCounts; FraserCount } from "./fraser/fraser"
include { MAEreadCounting; GetMAEresults } from "./MAE/MAE"

workflow Outrider_nf {
    /* Gagneurlab Outrider Nextflow implementation */
    Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> tuple( row.sampleID, row.bamFile, row.pairedEnd, row.strandSpecific ) }
    | OutriderCount
    | collect
    | set { merge_ch }

    MergeOutridercounts(merge_ch, params.outrider.mergecountsR)
    Outrider(MergeOutridercounts.out, params.extcounts.blood)
}

workflow Fraser_nf {
    /* Gagneurlab Fraser Nextflow implementation
    Since it was a bit tricky to implement this parallized like Outrider
    It makes sure that symbolic links to the *bam/bai files are included*/
    bamfiles_ch = Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> row.bamFile }
    baifiles_ch = bamfiles_ch.map { bamFile -> "${bamFile}.bai" }
    FraserCount(params.fraser.frasercountsR, params.samplesheet, params.output, bamfiles_ch.collect(), baifiles_ch.collect())
    MergeCounts(FraserCount.out, params.extcounts.blood, params.fraser.mergescriptR, params.output, params.extcounts.amount_fraser)
    Fraser(MergeCounts.out, params.samplesheet, params.output, params.fraser.fraserR)
}

workflow MAE_nf {
    Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> tuple( row.sampleID, row.vcf, row.bamFile ) }
    .filter { it[1] != null }
    .filter { it[1] != "NA" } | MAEreadCounting
    GetMAEresults(MAEreadCounting.out)
}

workflow {
    //Outrider_nf()
    Fraser_nf()
    //MAE_nf()
}