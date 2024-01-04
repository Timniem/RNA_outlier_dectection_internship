#' FRASER autoencoder 
#' Gagneur-lab FRASER (2.0)
#' Processes start from a samplesheet with SampleID's BAM paths featurecount settings etc. 
#' and creates fraser rds object and results .tsv
#' 28-10-2023
#' Argument 1: Samplesheet
#' Argument 2= input/output folder

library(FRASER)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

# Setup parallelisation
if(.Platform$OS.type == "unix") {
    register(MulticoreParam(workers=min(10, multicoreWorkers())))
} else {
    register(SnowParam(workers=min(10, multicoreWorkers())))
}

workdir <- args[2]

# Load original sample table

original_settingsTable <- fread(args[1])

fds <- loadFraserDataSet(dir=workdir)
fds <- filterExpressionAndVariability(fds, minDeltaPsi=0, filter=FALSE)
fds <- fds[mcols(fds, type="j")[,"passed"],]

# Hyperparam optim
set.seed(42)
fds <- optimHyperParams(fds, type="jaccard", plot=FALSE)
best_q <- bestQ(fds, type="jaccard")
fds <- FRASER(fds, q=c(jaccard=best_q))
fds <- annotateRanges(fds)
fds <- calculatePadjValues(fds, type="jaccard", geneLevel=TRUE)

register(SerialParam())
res <- as.data.table(results(fds,aggregate=TRUE, all=TRUE))

saveFraserDataSet(fds, dir=workdir, name="fraser_out")

res <- res[res$sampleID %in% original_settingsTable$sampleID]

write.table(res, 'result_table_fraser.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)