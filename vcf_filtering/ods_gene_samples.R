#' OUTRIDER to genelist
#' Script creates gene of interest list from ods file.
#' 25-09-2023
#' Argument 1= input path .ods file
#' Argument 2= output folder path for all files

library(OUTRIDER)
library("AnnotationDbi")
library("org.Hs.eg.db")
library("data.table")

args <- commandArgs(trailingOnly = TRUE)
ods <- readRDS(args[1])
ods <- computePvalues(ods, alternative="two.sided", method="BY")
ods <- computeZscores(ods)
res <- results(ods)

#Keep only outliers with low expression
filtered_res <- res[res$normcounts < res$meanCorrected,]

Ensembl_stripped <- unlist(lapply(strsplit(as.character(filtered_res$geneID), "[.]"), '[[', 1))

filtered_res$EntrezID = mapIds(org.Hs.eg.db,
                    keys=Ensembl_stripped, #Vector containing Ensembl gene ids
                    column="ENTREZID",
                    keytype="ENSEMBL",
                    multiVals="first")

filtered_res$GeneSymbol = mapIds(org.Hs.eg.db,
                    keys=Ensembl_stripped, 
                    column="SYMBOL",
                    keytype="ENSEMBL",
                    multiVals="first")

#Rename GeneID to EnsemblID
colnames(filtered_res)[colnames(filtered_res) == 'geneID'] <- 'EnsemblID'


#Generate gene of interest .txt files for every sample.
samplenames <- unique(filtered_res$sampleID)
for (sample in samplenames){
    out_name <- paste(sample, "genelist.txt", sep='_')
    out_name <- paste(args[2], out_name, sep='')
    out_res <- filtered_res[filtered_res$sampleID == sample,]
    out_res <- out_res[!(is.na(out_res$GeneSymbol)),]
    write.table(out_res$GeneSymbol, out_name,
                    sep='\t', row.names=FALSE, col.names=FALSE,
                    quote=FALSE)
    }

