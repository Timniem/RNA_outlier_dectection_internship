#' FRASER autoencoder 
#' Gagneur-lab FRASER (2.0)
#' Processes start from a samplesheet with SampleID's BAM paths featurecount settings etc. 
#' and creates fraser rds object and results .tsv
#' 28-10-2023
#' Argument 1= input path annot file
#' Argument 2= output path
#'
#' Optional arguments
#' ===================
#' Argument 3= external data annotation file
#' Argument 4= external splitreadcounts
#' Argument 5= external nonsplitreadcounts

library(FRASER)
library(dplyr)


# Setup parallelisation
if(.Platform$OS.type == "unix") {
    register(MulticoreParam(workers=min(10, multicoreWorkers())))
} else {
    register(SnowParam(workers=min(10, multicoreWorkers())))
}


# Load original sample table
args <- commandArgs(trailingOnly = TRUE)
settingsTable <- fread(args[1])
fds <- FraserDataSet(colData=settingsTable, workingDir=args[2])

# Read counts separately and save in case of future use. 
splitcounts <- getSplitReadCountsForAllSamples(fds)
write.table(splitcounts, 'splitcounts.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)

nonsplitcounts <- getNonSplitReadCountsForAllSamples(fds)
write.table(nonsplitcounts, 'nonsplitcounts.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)

if (length(args) > 2) {
    # Workflow for the addition of external counts.
    extsettingsTable <- fread(args[3])
    extsplitcounts <- fread(args[4])
    extnonsplitcounts <- fread(args[5])
    # for compatibility sake, a sampletable for the external counts is added.

    combsettingsTable <- rbind(settingsTable, extsettingsTable)
    # External counts are added to the counts from the samples in the samplesheet.
    splitcounts <- merge(x=splitcounts, y=extsplitcounts, by=c("seqnames", "start", "end", "width", "strand", "startID", "endID"), all=TRUE)
    nonsplitcounts <- merge(x=nonsplitcounts, y=extctsTable, by=c("seqnames", "start", "end", "width", "strand", "spliceSiteID", "type"), all=TRUE)

    fds <- FraserDataSet(colData=combsettingsTable, workingDir=args[2])
} 


fds <- addCountsToFraserDataSet(fds, splitcounts, nonsplitcounts)
fds <- calculatePSIValues(fds)
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

saveFraserDataSet(fds, dir=args[2], name="fraser_out")

res <- res[res$sampleID %in% settingsTable$sampleID]

write.table(res, 'result_table_fraser.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)