/**
Nextflow FRASER workflow

**/
nextflow.enable.dsl=2

process Fraser {
    time '6h'
    memory '64 GB'
    cpus 10

    publishDir "$params.output/fraser", mode: 'copy'

    input:
        path ext_sampletable
        path ext_splitcounts
        path ext_nonsplitcounts

    output:

        path "splitcounts.tsv"
        path "nonsplitcounts.tsv"
        path "result_table_fraser.tsv"

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/Nextflow/fraser/fraser.R ${params.samplesheet} ${params.output} ${ext_sampletable} ${ext_splitcounts} ${ext_nonsplitcounts}
        """
}