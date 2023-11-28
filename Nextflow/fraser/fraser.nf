/**
Nextflow OUTRIDER workflow

**/
nextflow.enable.dsl=2

process Fraser {
    time '6h'
    memory '100 GB'
    cpus 10

    publishDir "$params.output/fraser", mode: 'copy'

    script: 
        """
        eval "\$(conda shell.bash hook)"
        source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
        mamba activate fraser_env
        Rscript /groups/umcg-gdio/tmp01/umcg-tniemeijer/Nextflow/fraser/fraser.R ${params.samplesheet} ${params.output}
        """
}