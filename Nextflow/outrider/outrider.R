#' OUTRIDER autoencoder find q
#' Script creates ods objects
#' 25-09-2023
#' Argument 1= input path counts file
#' Argument 2= output path ods
#' Argument 3= output path res

library(OUTRIDER)
library(dplyr)

if(.Platform$OS.type == "unix") {
    register(MulticoreParam(workers=min(10, multicoreWorkers())))
} else {
    register(SnowParam(workers=min(10, multicoreWorkers())))
}

args <- commandArgs(trailingOnly = TRUE)
ctsTable <- read.table(args[1], header=TRUE, sep="\t")
rds_out <- args[2]
res_out <- args[3]
iter <- 15

#External counts will be added in a different script, before this one.
#extctsTable <- read.table(args[3], header=TRUE, sep="\t")

#Rename GeneID to EnsemblID
#colnames(extctsTable)[colnames(extctsTable) == 'geneID'] <- 'EnsemblID'

#add external counts
#ctsTable <- merge(x=ctsTable, y=extctsTable, by=c("EnsemblID"), all=TRUE)

#Keep the most complete annotation: Ensemble column 1
#convert NA values to 0

count_data_Ensembl <- ctsTable #[,c(1:101)]
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

ods <- computePvalues(ods, alternative="two.sided", method="BY")
ods <- computeZscores(ods)
res <- results(ods, all=TRUE)

#Output the outrider dataset file, and the results table. 
saveRDS(ods, file=rds_out)
write.table(res, res_out, append = FALSE)