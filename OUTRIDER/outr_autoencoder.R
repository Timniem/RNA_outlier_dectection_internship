#' OUTRIDER autoencoder find q
#' Script creates ods objects
#' 25-09-2023
#' Argument 1= input path counts file
#' Argument 2= output path

library(OUTRIDER)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
ctsTable <- read.table(args[1], header=TRUE, sep="\t")
#qint <- strtoi(args[3])
iter <- 15

#Keep the most complete annotation: Ensemble column 1

#because entrez ID's and gene symbols are added, these need to be dropped.
count_data_Ensembl <- ctsTable[,c(1,4:ncol(ctsTable))]

#convert NA values to 0
count_data_Ensembl[is.na(count_data_Ensembl)] <- 0

countDataMatrix <- as.matrix(count_data_Ensembl[ , -1])

rownames(countDataMatrix) <- count_data_Ensembl[ , 1]

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

saveRDS(ods, file=args[2])
