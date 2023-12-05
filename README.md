# RNA_outlier_dectection_internship

## Nextflow RNA-seq pipeline
This pipeline written in Nextflow will yield outlier results for gene expression and splicing. It consists of several modules of the DROP pipeline* (gagneur-lab) and is made to be compatible for VIP** integration in the near future.
The MAE (mono allelic expression) is currently not implemented but is scheduled for a future release.

Input for the pipeline is an annotation file with paths to the BAM files and several processing options.
External counts are/can be added to improve gene/splice outlier significance.

![plot](https://github.com/Timniem/RNA_outlier_dectection_internship/blob/main/flowchart_example_pipeline_analysis.png)

## RNA-seq Outlier Dashboard
The Dashboard accompanies the Nextflow pipeline and provides researchers with a tool for quick analysis of the outlier results based on gene panels/ specific genes (and later perhaps HPO terms/ OMIM morbid filter)
It is written mainly in Panel (Holoviz), and can be accessed by serving the jupyter notebook locally. 

![plot](https://github.com/Timniem/RNA_outlier_dectection_internship/blob/main/RNA-seq%20outlier%20analysis.png)




'* https://github.com/gagneurlab/drop

** https://github.com/molgenis/vip
