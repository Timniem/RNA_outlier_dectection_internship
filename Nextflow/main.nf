/**
Nextflow main OUTRIDER, FRASER and MAE Workflow
author: T Niemeijer
**/
nextflow.enable.dsl=2

include { Outrider; OutriderCount; MergeOutridercounts } from "./outrider/outrider"
include { Fraser; MergeCounts; FraserCount } from "./fraser/fraser"
include { MAEreadCounting; GetMAEresults } from "./MAE/MAE"

workflow Outrider_nf {
    /* 
    Gagneurlab Outrider Nextflow implementation 
    */
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
    /* 
    Gagneurlab Fraser Nextflow implementation with external counts.
    Since it was a bit tricky to implement this parallized like Outrider
    It makes sure that symbolic links to the *bam/bai files are included
    */
    bamfiles_ch = Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> row.bamFile }

    baifiles_ch = bamfiles_ch.map { bamFile -> "${bamFile}.bai" }

    FraserCount(params.fraser.frasercountsR, params.samplesheet, bamfiles_ch.collect(), baifiles_ch.collect())
    MergeCounts(params.extcounts.blood, params.fraser.mergescriptR, FraserCount.out, params.extcounts.amount_fraser)
    Fraser(params.samplesheet, MergeCounts.out, params.fraser.fraserR)
}

workflow MAE_nf {
    readcount_ch = Channel
    .fromPath( params.samplesheet )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> tuple( row.sampleID, row.vcf, row.bamFile ) }
    .filter { it[1] != null }
    .filter { it[1] != "NA" }

    MAEreadCounting(readcount_ch, tuple(params.fasta, params.fastafolder))
    GetMAEresults(MAEreadCounting.out, params.mae.resultsR)
}

workflow {
    Outrider_nf()
    Fraser_nf()
    MAE_nf()
}