#' OUTRIDER autoencoder find q
#' Script creates ods objects
#' 25-09-2023
#' Argument 1= input path counts file
#' Argument 2= output path ods
#' Argument 3= output path res
#' Argument 4= samplesheet
#' Argument 5= external count path

library(OUTRIDER)
library(dplyr)
library(tidyr)
library("AnnotationDbi")
library("org.Hs.eg.db")
library("data.table")
library(TxDb.Hsapiens.UCSC.hg19.knownGene)

if(.Platform$OS.type == "unix") {
    register(MulticoreParam(workers=min(20, multicoreWorkers())))
} else {
    register(SnowParam(workers=min(20, multicoreWorkers())))
}

args <- commandArgs(trailingOnly = TRUE)
ctsTable <- read.table(args[1], header=TRUE, sep="\t")
samplesheet <- read.table(args[4], header=TRUE, sep="\t")
rds_out_path <- args[2]
res_out_path <- args[3]
iter <- 15

extctspath <- file.path(args[5],"geneCounts.tsv.gz")

# Add external Counts
if (length(args) == 5){
    extctsTable <- read.table(gzfile(extctspath), header=TRUE, sep="\t")
    ctsTable <- merge(x=ctsTable, y=extctsTable, by=c("GeneID"), all=TRUE)
}

count_data <- ctsTable[,c(1:101)] #max=100
count_data[is.na(count_data)] <- 0

countDataMatrix <- as.matrix(count_data[ , -1])
rownames(countDataMatrix) <- count_data[ , 1]

ods <- OutriderDataSet(countData=countDataMatrix)
ods <- filterExpression(ods, minCounts=TRUE, filterGenes=TRUE)
ods <- estimateSizeFactors(ods)

a <- 5 
b <- min(ncol(ods), nrow(ods)) / 3
maxSteps <- 20
Nsteps <- min(maxSteps, b) 
pars_q <- round(exp(seq(log(a),log(b),length.out = Nsteps))) %>% unique

ods <- findEncodingDim(ods, params=pars_q, implementation='autoencoder')
opt_q <- getBestQ(ods)

ods <- controlForConfounders(ods, q=opt_q, iterations=iter)

ods <- computePvalues(ods, alternative="two.sided", method="BY")
ods <- computeZscores(ods)
res <- results(ods, all=TRUE)

# Output the outrider dataset file, and the results table. 
saveRDS(ods, file=rds_out_path)

# Filter data based on samples present in samplesheet
res <- res[res$sampleID %in% samplesheet$sampleID]

# Get genesymbols and reorder the dataframe
Ensembl_stripped <- unlist(lapply(strsplit(as.character(res$geneID), "[.]"), '[[', 1))

res$hgncSymbol = mapIds(org.Hs.eg.db,
                    keys=Ensembl_stripped, 
                    column="SYMBOL",
                    keytype="ENSEMBL",
                    multiVals="first")

res$entrezid = mapIds(org.Hs.eg.db,
                    keys=Ensembl_stripped, 
                    column="ENTREZID",
                    keytype="ENSEMBL",
                    multiVals="first")

names(res)[names(res) == 'geneID'] <- 'EnsemblID'

# Annotate chr start end.
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene

res$chr = mapIds(txdb,
                    keys=res$entrezid, 
                    column="TXCHROM",
                    keytype="GENEID",
                    multiVals="first")

res$start = mapIds(txdb,
                    keys=res$entrezid, 
                    column="TXSTART",
                    keytype="GENEID",
                    multiVals="first")

res$end = mapIds(txdb,
                    keys=res$entrezid, 
                    column="TXEND",
                    keytype="GENEID",
                    multiVals="first")

# remove chr, to match the other results.
res$chr <- sub('^\\chr', '', res$chr)

# For now, drop all NA's. No this is left for the other script.
#res <- drop_na(res)
#res <- apply(res,2,as.character)

for (sampleid in unique(res$sampleID)){
    sample_out_path = paste(sampleid, res_out_path, sep='_')
    write.table(res[res$sampleID == sampleid], sample_out_path, sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)
}
