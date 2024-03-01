/**
Nextflow FRASER workflow

**/
nextflow.enable.dsl=2


process FraserCount {
    time '4h'
    memory '32 GB'
    cpus 4

    input:
        path frasercountR
        path samplesheet
        path bamFiles
        path baiFiles
    output:
        path "fraser_output"

    script: 
        """
        mkdir "fraser_output"
        Rscript "${frasercountR}" "${samplesheet}" "fraser_output"
        """
}


process MergeCounts {
    time '1h'
    memory '8 GB'
    cpus 4

    input:
        path ext_counts
        path mergescriptR
        path fraser_output
        val ext_amount_fraser
        

    output:

        path fraser_output

    script: 
        """
        Rscript ${mergescriptR} "${fraser_output}" "${ext_counts}" "${ext_amount_fraser}"
        """

}

process Fraser {
    time '8h'
    memory '64 GB'
    cpus 4

    publishDir "$params.output/fraser", mode: 'copy'

    input:
        path samplesheet
        path output
        path fraserR

    output:

        path "*.tsv"

    script: 
        """
        Rscript "${fraserR}" "${samplesheet}" "${output}"
        """
}