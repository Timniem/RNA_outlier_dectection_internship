#' featurecounts with strand specificity and combining
#' used in outrider_env
#' Argument 1= samplesheet path
#' Argument 2= annotation file path
#' Argument 3= output path

library(Rsubread)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
samplesheet <- read.table(args[1], header=TRUE, sep="\t")
annot_path <- args[2]
output_path <- args[3]

# Checks samplesheet for strand specificity. 
s0_bams <- samplesheet$bamFile[which(samplesheet$strandSpecific == 0)]
s1_bams <- samplesheet$bamFile[which(samplesheet$strandSpecific == 1)]
s2_bams <- samplesheet$bamFile[which(samplesheet$strandSpecific == 2)]

# Initialize a list for counts
counts <- list()

# Check for strand specificity and append different count matrices to count_matrices
if (length(s0_bams) >= 1 ){
    fc0 <- featureCounts(s0_bams, annot.ext=annot_path, isGTFAnnotationFile=TRUE, nthreads=10, allowMultiOverlap=TRUE, isPairedEnd=TRUE, strandSpecific=0)
    counts[[length(counts) + 1]] <- fc0
}
if (length(s1_bams) >= 1 ){
    fc1 <- featureCounts(s1_bams, annot.ext=annot_path, isGTFAnnotationFile=TRUE, nthreads=10, allowMultiOverlap=TRUE, isPairedEnd=TRUE, strandSpecific=1)
    counts[[length(counts) + 1]] <- fc1
}
if (length(s2_bams) >= 1 ){
    fc2 <- featureCounts(s2_bams, annot.ext=annot_path, isGTFAnnotationFile=TRUE, nthreads=10, allowMultiOverlap=TRUE, isPairedEnd=TRUE, strandSpecific=2)
    counts[[length(counts) + 1]] <- fc2
}


count_matrices <- list()
stat_data <- list()

for (data in counts) {
  GeneID <- data$annotation$GeneID 
  count_matrices[[length(count_matrices) + 1]] <- cbind(GeneID, data$counts)
  stat_data[[length(stat_data) + 1]] <- data$stat
}

# Merge the count files from different stranded samples.
ctsTable <- Reduce(function(x, y) merge(x, y, by.x='GeneID', by.y='GeneID', all.x=TRUE), count_matrices)
statsTable <- Reduce(function(x, y) merge(x, y, by.x='Status', by.y='Status', all.x=TRUE), stat_data)

# Rename sample names with the sample names from the provided .tsv.
range <- 1:length(samplesheet$bamFile)
for (index in range){
    colnames(ctsTable)[colnames(ctsTable) == basename(samplesheet$bamFile[index])] <- samplesheet$sampleID[index]
}

# Write counts to file.
write.table(ctsTable, file=output_path, sep="\t" ,row.names=FALSE, col.names=TRUE)

# Write count summary to file.
write.table(statsTable, file="outrider_count_summary.tsv", sep="\t" ,row.names=FALSE, col.names=TRUE)