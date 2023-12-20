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
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/fraser/frasercounts.R ${params.samplesheet} "${params.output}"
        touch "./count.done" 
        """
}


process MergeCounts {
    time '1h'
    memory '32 GB'
    cpus 10

    input:
        path count_check
        path ext_counts
        

    output:

        path "./merge.done" 

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/fraser/merge_counts.R "${params.output}" ${ext_counts}
        touch "./merge.done"
        """

}

process Fraser {
    time '6h'
    memory '100 GB'
    cpus 10

    publishDir "$params.output/fraser", mode: 'copy'

    input:
        path merge_check

    output:

        path "result_table_fraser.tsv"

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/RNA_outlier_dectection_internship/Nextflow/fraser/fraser.R ${params.samplesheet} ${params.output}
        """
}