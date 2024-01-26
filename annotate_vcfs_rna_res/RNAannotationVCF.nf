#!/usr/bin/env nextflow
/**
Nextflow workflow for adding annotation to DNA VCF from RNA outlier results
**/

nextflow.enable.dsl=2

params.resfiles="/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/resources/test_data"
params.fraser_hdr="/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/resources/FRASER_annots.hdr"
params.mae_hdr="/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/resources/MAE_annots.hdr"
params.outrider_hdr="/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/resources/OUTRIDER_annots.hdr"
params.vcf="/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/sorted_input.vcf"
params.output="/groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/test_output"

process ResultsToBED {
    time '30m'
    memory '4 GB'
    cpus 1

    input:
        path sample_folder

    output:
        path "*.bed"

    script:
    """
    eval "\$(conda shell.bash hook)"
    source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
    mamba activate dashboard_env
    python /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/convert_res_to_bed.py $sample_folder "results.bed"
    """
}

process AddAnnotationToVCF {
    time '1h'
    memory '4 GB'
    cpus 1

    publishDir "$params.output/vcf", mode: 'copy'

    input:
        path resultsbed
        path vcf
        path header_file
        val type

    output:
        path "annotated_vcf.vcf"
        

    script:
    """
    bash /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/annotate_vcfs_rna_res/add_result_to_vcf.sh -b $resultsbed -v $vcf -o annotated_vcf.vcf -h $header_file -t $type
    """
}

workflow FraserVCF {
    take:
        vcf
    main:
        ResultsToBED("${params.resfiles}/*fraser.tsv")
        AddAnnotationToVCF(ResultsToBED.out, vcf, params.fraser_hdr, "fraser")
    emit:
        AddAnnotationToVCF.out
}

workflow OutriderVCF {
    take:
        vcf
    main:
        ResultsToBED("${params.resfiles}/*outrider.tsv")
        AddAnnotationToVCF(ResultsToBED.out, vcf, params.outrider_hdr, "outrider")
    emit:
        AddAnnotationToVCF.out
}

workflow MaeVCF {
    take:
        vcf
    main:
        ResultsToBED("${params.resfiles}/*mae.tsv")
        AddAnnotationToVCF(ResultsToBED.out, vcf, params.mae_hdr, "mae")
    emit:
        AddAnnotationToVCF.out
}



workflow {
    FraserVCF(params.vcf)
    MaeVCF(FraserVCF.out)
    OutriderVCF(MaeVCF.out)
}