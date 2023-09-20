#Script to convert Ensembl annotation into Entrez
#First version
#Author T.Niemeijer

library("AnnotationDbi")
library("org.Hs.eg.db")
args <- commandArgs(trailingOnly = TRUE)
cts_table <- read.table(args[1],header=TRUE, sep="\t")
cts_table$Geneid <- unlist(lapply(strsplit(as.character(cts_table$Geneid), "[.]"), '[[', 1))
cts_table$entrez = mapIds(org.Hs.eg.db,
                    keys=cts_table$Geneid, #Column containing Ensembl gene ids
                    column="ENTREZID",
                    keytype="ENSEMBL",
                    multiVals="first")
columns <- colnames(cts_table)
cts_table <- cts_table[,c("entrez",columns[columns != "entrez"])]
write.table(cts_table,  file = args[1], sep ="\t" ,row.names = FALSE, col.names = TRUE)
