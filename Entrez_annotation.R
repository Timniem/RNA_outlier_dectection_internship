#Script to convert Ensembl annotation into Entrez
#First version
#Author T.Niemeijer

library("AnnotationDbi")
library("org.Hs.eg.db")
library("data.table")

args <- commandArgs(trailingOnly = TRUE)
cts_table <- read.table(args[1],header=TRUE, sep="\t")

#remove headers 2-6 
cts_table <- cts_table[,c(1,7:ncol(cts_table))]
Ensembl_stripped <- unlist(lapply(strsplit(as.character(cts_table$Geneid), "[.]"), '[[', 1))

cts_table$EntrezID = mapIds(org.Hs.eg.db,
                    keys=Ensembl_stripped, #Vector containing Ensembl gene ids
                    column="ENTREZID",
                    keytype="ENSEMBL",
                    multiVals="first")

cts_table$GeneSymbol = mapIds(org.Hs.eg.db,
                    keys=Ensembl_stripped, 
                    column="SYMBOL",
                    keytype="ENSEMBL",
                    multiVals="first")

#Rename GeneID to EnsemblID
colnames(cts_table)[colnames(cts_table) == 'Geneid'] <- 'EnsemblID'

# Forced order with Ensembl, Entrez and Symbol first
columns <- colnames(cts_table)
last_columns <- setdiff(columns, c("EnsemblID","EntrezID","GeneSymbol"))
renamed_last_columns <- character()
for (name in last_columns){
    split_name <- strsplit(name, '\\.')[[1]]
    joined_name <- paste(c(split_name[12:14]), collapse='_')
    renamed_last_columns <- c(renamed_last_columns, joined_name)
    }

cts_table <- cts_table[,c("EnsemblID","EntrezID","GeneSymbol", last_columns)]

setnames(cts_table, last_columns, renamed_last_columns)

write.table(cts_table,  file = args[2], sep ="\t" ,row.names = FALSE, col.names = TRUE)
