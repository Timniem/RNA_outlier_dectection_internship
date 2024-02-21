/**
Nextflow FRASER workflow

**/
nextflow.enable.dsl=2


process FraserCount {
    time '2h'
    memory '16 GB'
    cpus 10

    input:
        path frasercountR
        path samplesheet
        path output
        path bamFiles
        path baiFiles
    output:
        path "./count.done" 

    script: 
        """
        Rscript ${frasercountR} ${samplesheet} "${output}"
        touch "./count.done" 
        """
}


process MergeCounts {
    time '1h'
    memory '8 GB'
    cpus 4

    input:
        path count_check
        path ext_counts
        path mergescriptR
        path output
        val ext_amount_fraser
        

    output:

        path "./merge.done" 

    script: 
        """
        Rscript ${mergescriptR} "${output}" "${ext_counts}" "${ext_amount_fraser}"
        touch "./merge.done"
        """

}

process Fraser {
    time '8h'
    memory '64 GB'
    cpus 4

    publishDir "$params.output/fraser", mode: 'copy'

    input:
        path merge_check
        path samplesheet
        path output
        path fraserR

    output:

        path "*.tsv"

    script: 
        """
        Rscript ${fraserR} ${samplesheet} ${output}
        """
}