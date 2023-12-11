/**
Nextflow FRASER workflow

**/
nextflow.enable.dsl=2


process FraserCount {
    time '2h'
    memory '32 GB'
    cpus 10

    output:
    path "./count.done" 

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/fraser/frasercounts.R ${params.samplesheet} ${params.output}
        touch "./count.done" 
        """
}


process MergeCounts {
    time '1h'
    memory '32 GB'
    cpus 10

    publishDir "$params.output/fraser", mode: 'copy'

    input:
        path countcheck
        path ext_sampletable
        path ext_splitcounts
        path ext_nonsplitcounts
        

    output:

        path "settingstable_fraser.tsv", emit: settingstable_fraser
        path "splitcounts_fraser.tsv", emit: splitcounts_fraser
        path "nonsplitcounts_fraser.tsv", emit: nonsplitcounts_fraser

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/fraser/merge_counts.R ${params.samplesheet} ${params.output} ${ext_sampletable} ${ext_splitcounts} ${ext_nonsplitcounts}
        """

}

process Fraser {
    time '6h'
    memory '100 GB'
    cpus 10

    publishDir "$params.output/fraser", mode: 'copy'

    input:
        path sampletable
        path splitcounts
        path nonsplitcounts

    output:

        path "result_table_fraser.tsv"

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/fraser/fraser.R ${params.samplesheet} ${params.output} ${sampletable} ${splitcounts} ${nonsplitcounts}
        """
}