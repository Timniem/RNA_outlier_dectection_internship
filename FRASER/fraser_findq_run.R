#' FRASER autoencoder find q
#' Script creates ods objects
#' 28-10-2023
#' Argument 1= input path counts file
#' Argument 2= output path

library(FRASER)
library(dplyr)

if(.Platform$OS.type == "unix") {
    register(MulticoreParam(workers=min(10, multicoreWorkers())))
} else {
    register(SnowParam(workers=min(10, multicoreWorkers())))
}

args <- commandArgs(trailingOnly = TRUE)
settingsTable <- fread(args[1])
settings <- FraserDataSet(colData=settingsTable, workingDir=args[2])
fds <- countRNAData(settings)
fds <- calculatePSIValues(fds)
fds <- filterExpressionAndVariability(fds, minDeltaPsi=0.1, filter=FALSE)
fds <- fds[mcols(fds, type="j")[,"passed"],]

#Hyperparam optim
set.seed(42)

for(i in psiTypes){
    fds <- optimHyperParams(fds, type=i, plot=FALSE)
    bestQ(fds, i)
}
fds <- FRASER(fds, implementation="PCA", iterations=15)
fds <- calculatePadjValues(fds, method="BY")
fds <- calculateZscore(fds)

saveFraserDataSet(fds, dir=args[2], name=args[3])