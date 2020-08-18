#***************************************
#extend_table_results.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 30th July 2020
#description = Extends the results table to include secondary statistics (population sizes, fraction deaths). Uses Alberto's code for E/S population sizes.
#usage = Run from src/

library(rlang)
library(dplyr)
library(stringi)
library(stringr)


currentDir <- getwd()
setwd("/home/ec365/workbench/req-550-Syria/src")

#Directories
setwd("..")
baseDir <- getwd()
codeDir <- paste(baseDir,"/src",sep="")
dataDir <- paste(baseDir,"/data/real_models",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")

idDir="modSV" # this is a string contained in all the directories that should be processed
fileResults=paste("results_table_",idDir,".csv",sep="")
fileOut=paste("extended_results_table_",idDir,".csv",sep="")

df.results <- read.csv(paste(outDir,"/",fileResults,sep=""))

#By Alberto
get_relative_sizes <- function(PopStructure,PopSize){
  if(PopStructure == "null_model_mixed"){
    PopSize.E=1
    PopSize.S=0 
  }else if(PopStructure == "shield_cont2_age3"){
    PopSize.E=0.9406
    PopSize.S=0.0594
  }else if(PopStructure == "shield_cont2_age3_age2"){
    PopSize.E=0.878
    PopSize.S=0.122
  }else if((PopStructure == "shield_cont2_age3_age2_20")||
           (PopStructure == "shield_cont0_age3_age2_20")||
           (PopStructure == "shield_cont10_age3_age2_20")){
    PopSize.E=0.8
    PopSize.S=0.2
  }else if(PopStructure == "shield_cont2_age3_age2_25"){
    PopSize.E=0.75
    PopSize.S=0.25
  }else if(PopStructure == "shield_cont2_age3_age2_30"){
    PopSize.E=0.7
    PopSize.S=0.3
  }
  PopSize.E=PopSize.E*PopSize
  PopSize.S=PopSize.S*PopSize
  PopSize.sub=c(PopSize.E,PopSize.S)
  names(PopSize.sub)=c("PopSize.E","PopSize.S")
  return(PopSize.sub)
}

df.Summary <- read.csv("/home/ec365/workbench/req-550-Syria/data/real_models/results_post_processing/Summary_interventions_modSV.csv")

#Going to do a for loop, this should not run often. Terribly slow.
popSize.col <- c()
POutbreak.col <- c()
for(i in 1:length(df.results$group)){
    str.PopSize=stri_split_fixed(df.results$PopSize[i],"PopSize")[[1]][2]
    PopSize.T=as.numeric(str.PopSize)
    poplist = get_relative_sizes(df.results$contacts[i],PopSize.T)

    df.aux <- subset(df.Summary, contacts == df.results$contacts[i] & Isolate == df.results$Isolate[i] &  Limit == df.results$Limit[i] &  Onset == df.results$Onset[i] & Fate == df.results$Fate[i] & Tcheck == df.results$Tcheck[i] & lock == df.results$lock[i] & self == df.results$self[i] & mod==df.results$mod[i])

    g <- df.results$group[i]

    if( g == "T" ){
        popSize.col <- c(popSize.col, PopSize.T)
        POutbreak.col <- c(POutbreak.col, df.aux$P.outbrk[1])
    }
    else if (g == "S"){
        popSize.col <- c(popSize.col, poplist[2])
        POutbreak.col <- c(POutbreak.col, df.aux$P.outbrk.S[1])
    }
    else{
        popSize.col <- c(popSize.col, poplist[1])
        POutbreak.col <- c(POutbreak.col, df.aux$P.outbrk.E[1])
    }

}

FracFinalDeaths <- df.results$NumFinalDeaths / popSize.col
FracFinalRecovered <- df.results$NumFinalRecovered/ popSize.col

CFR <- df.results$NumFinalDeaths / (df.results$NumFinalDeaths + df.results$NumFinalRecovered)

cnames <- colnames(df.results)

df.output <- bind_cols(df.results,popSize.col,FracFinalDeaths,FracFinalRecovered,CFR,POutbreak.col)
colnames(df.output) <- c(cnames,"PopSizeNum","FracFinalDeaths","FracFinalRecovered","CFR","POutbreak")

setwd(outDir)
write.csv(df.output,file=fileOut)

setwd(currentDir) #Let's finish where we started.
