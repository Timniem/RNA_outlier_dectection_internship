#' FRASER count merge
#' Gagneur-lab FRASER (2.0)
#' Processes start from a samplesheet with SampleID's BAM paths featurecount settings etc. 
#' and creates fraser rds object and results .tsv
#' 20-12-2023
#' Argument 1= input path annot file
#' Argument 2= output path
#' Argument 3= external data

library(FRASER)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

# Setup parallelisation
if(.Platform$OS.type == "unix") {
    register(MulticoreParam(workers=min(10, multicoreWorkers())))
} else {
    register(SnowParam(workers=min(10, multicoreWorkers())))
}

fds <- loadFraserDataSet(dir=args[1])
ext_dir <- args[2]

countfiles <- c(k_j=file.path(ext_dir,"k_j_counts.tsv.gz"), k_theta=file.path(ext_dir,"k_theta_counts.tsv.gz"),
                n_psi3=file.path(ext_dir,"n_psi3_counts.tsv.gz"), n_psi5=file.path(ext_dir,"n_psi5_counts.tsv.gz"),
                n_theta=file.path(ext_dir,"n_theta_counts.tsv.gz"))

annot <- fread(file.path(ext_dir,"sampleAnnotation.tsv"))

samples <- annot$sampleID[1:100]
fds <- mergeExternalData(fds = fds ,countFiles = countfiles, sampleIDs = samples, annotation = annot)
fds <- saveFraserDataSet(fds)