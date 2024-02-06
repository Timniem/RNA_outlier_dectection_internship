# RNA_outlier_dectection_internship

For more info and instructions vitit https://timniem.github.io/RNA_outlier_dectection_internship/(https://timniem.github.io/RNA_outlier_dectection_internship/)


## Nextflow RNA-seq pipeline
This pipeline written in Nextflow will yield outlier results for gene expression and splicing. It consists of several modules of the DROP pipeline* the OUTRIDER, FRASER and Mono-allelic-expression modules (gagneur-lab) and is made to be compatible for VIP** integration in the near future.

Input for the pipeline is an annotation file with paths to the BAM files and several processing options.
External counts are/can be added to improve gene/splice outlier significance.

![plot](https://github.com/Timniem/RNA_outlier_dectection_internship/blob/main/flowchart_example_pipeline_analysis.png)

## RNA-seq Outlier Dashboard
The Dashboard accompanies the Nextflow pipeline and provides researchers with a tool for quick analysis of the outlier results based on gene panels/ specific genes and/or HPO terms.
It is written mainly in Panel (Holoviz), and can be accessed by serving the Panel/Bokeh server locally or remotely.

'* https://github.com/gagneurlab/drop | https://github.com/gagneurlab/OUTRIDER | https://github.com/gagneurlab/FRASER | MAE deseq2

** https://github.com/molgenis/vip
