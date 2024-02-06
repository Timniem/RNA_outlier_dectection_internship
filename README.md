# RNA_outlier_dectection_internship

For more info and instructions vitit [https://timniem.github.io/RNA_outlier_dectection_internship/](https://timniem.github.io/RNA_outlier_dectection_internship/)


## Nextflow RNA-seq pipeline
This pipeline written in Nextflow will yield outlier results for gene expression and splicing. It consists of several modules of the DROP pipeline* the OUTRIDER, FRASER and Mono-allelic-expression modules (gagneur-lab) and is made to be compatible for VIP** integration in the near future.

Input for the pipeline is an annotation file with paths to the BAM files and several processing options.
External counts are/can be added to improve gene/splice outlier significance.

![plot](https://github.com/Timniem/RNA_outlier_dectection_internship/blob/main/flowchart_example_pipeline_analysis.png)

## RNA-seq Outlier Dashboard
The Dashboard accompanies the Nextflow pipeline and provides researchers with a tool for quick analysis of the outlier results based on gene panels/ specific genes and/or HPO terms.
It is written mainly in Panel (Holoviz), and can be accessed by serving the Panel/Bokeh server locally or remotely.

'* https://github.com/gagneurlab/drop  https://www.nature.com/articles/s41596-020-00462-5 | https://github.com/gagneurlab/OUTRIDER https://www.cell.com/ajhg/fulltext/S0002-9297(18)30401-4 | https://github.com/gagneurlab/FRASER https://www.nature.com/articles/s41467-020-20573-7 | MAE deseq2 https://www.nature.com/articles/ncomms15824 https://genomebiology.biomedcentral.com/articles/10.1186/s13059-014-0550-8

** https://github.com/molgenis/vip
