#' FRASER count merge
#' Gagneur-lab FRASER (2.0)
#' Processes start from a samplesheet with SampleID's BAM paths featurecount settings etc. 
#' and creates fraser rds object and results .tsv
#' 20-12-2023
#' Argument 1= input path annot file
#' Argument 2= output path
#' Argument 3= external data
#' Argument 4= ecternal data amount

library(FRASER)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

fds <- loadFraserDataSet(dir=args[1])
ext_dir <- args[2]
ext_amount <- as.numeric(args[3]) + 1 #+1 to account for the geneID

countfiles <- c(k_j=file.path(ext_dir,"k_j_counts.tsv.gz"), k_theta=file.path(ext_dir,"k_theta_counts.tsv.gz"),
                n_psi3=file.path(ext_dir,"n_psi3_counts.tsv.gz"), n_psi5=file.path(ext_dir,"n_psi5_counts.tsv.gz"),
                n_theta=file.path(ext_dir,"n_theta_counts.tsv.gz"))

annot <- fread(file.path(ext_dir,"sampleAnnotation.tsv"))

samples <- annot$sampleID[1:ext_amount]
fds <- mergeExternalData(fds = fds ,countFiles = countfiles, sampleIDs = samples, annotation = annot)
fds <- saveFraserDataSet(fds)