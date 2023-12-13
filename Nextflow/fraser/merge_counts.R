#' Fraser merge counts
#' Optional arguments
#' ===================
#' Argument 3= external data annotation file
#' Argument 4= external splitreadcounts
#' Argument 5= external nonsplitreadcounts

library(FRASER)
library(dplyr)
library(tools)

args <- commandArgs(trailingOnly = TRUE)
settingsTable <- fread(args[1])
workdir <- args[2]
nfdir <- getwd()

# read the multiple .rds for splitcounts
setwd(file.path(workdir,'cache/splitCounts/'))
splitfiles <- list.files()

count_dfs <- list()
for (file in splitfiles) {
    df <- as.data.frame(readRDS(file))
    count_name <- file_path_sans_ext(substr(file, 13, nchar(file)))
    colnames(df)[colnames(df) == "count"] <- count_name
    count_dfs[[length(count_dfs) + 1]] <- df
}

splitcounts <- Reduce(function(x, y) merge(x, y, all=TRUE), count_dfs)
splitcounts[is.na(splitcounts)] <- 0 # replace the NA's with 0's

setwd(file.path(workdir,'savedObjects/Data_Analysis/splitCounts/'))

#Add startID and stopID
se <- readRDS("se.rds")
start_end_ID <- as.data.frame(rowData(se))
splitcounts <- cbind(start_end_ID, splitcounts)


# read .rds for nonsplitcounts
setwd(file.path(workdir,'savedObjects/Data_Analysis/nonSplitCounts/'))
se <- readRDS("se.rds")
nonsplitcounts <- as.data.frame(assay(se))
nonsplit_row_annot <- as.data.frame(readRDS(file.path(workdir,'cache/nonSplicedCounts/Data_Analysis/spliceSiteCoordinates.RDS')))
nonsplitcounts <- cbind(nonsplit_row_annot, nonsplitcounts)


# Workflow for the addition of external counts.
# Return to the Nextflow working directory
setwd(nfdir)
extsettingsTable <- fread(args[3])
extsplitcounts <- fread(args[4])
extnonsplitcounts <- fread(args[5])
# for compatibility sake, a sampletable for the external counts is added.

combsettingsTable <- rbind(settingsTable, extsettingsTable)

# remove start and stop IDs from the external splitcounts and SplicesiteID from nonsplitcounts
extsplitcounts$startID <- NULL
extsplitcounts$endID <- NULL
extnonsplitcounts$spliceSiteID <- NULL


# strand to '*' for the time being, strange behaviour because strandedness is used in counting.
# maybe due to the reversed strandedness on some samples?

extsplitcounts$strand <- '*'
extnonsplitcounts$strand <- '*'

# External counts are added to the counts from the samples in the samplesheet.
splitcounts <- merge(x=splitcounts, y=extsplitcounts, by=c("seqnames", "start", "end", "width", "strand"), all=TRUE)
nonsplitcounts <- merge(x=nonsplitcounts, y=extnonsplitcounts, by=c("seqnames", "start", "end", "width", "strand", "type"), all=TRUE)


# NA id's will be dropped and NA count for external counts will be set to 0
splitcounts <- splitcounts[!is.na(splitcounts$startID) & !is.na(splitcounts$endID), ]
nonsplitcounts <- nonsplitcounts[!is.na(nonsplitcounts$spliceSiteID),]

splitcounts[is.na(splitcounts)] <- 0
nonsplitcounts[is.na(nonsplitcounts)] <- 0

splitcounts$startID <- NULL
splitcounts$endID <- NULL
nonsplitcounts$spliceSiteID <- NULL


write.table(combsettingsTable, 'settingstable_fraser.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)
write.table(splitcounts, 'splitcounts_fraser.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)
write.table(nonsplitcounts, 'nonsplitcounts_fraser.tsv', sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)