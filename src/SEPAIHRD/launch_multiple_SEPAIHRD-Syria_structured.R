# ****************************************
# launch_multiple_SEPAIHRD-Syria_structured.R
# ****************************************
# 
# 
# author = Alberto Pascual-García 
# email = alberto.pascual.garcia@gmail.com 
# date = 6th July 2020
# description = This script is a variation of the script launch_multiple_SEPAIHRD-Syria_structured.R
#   to launch several simulations with different input parameters. The input parameters are encoded
#   in a file in which each line contains the parameters to be considered in the simulation. Then
#   some additional parameters such as the number of realizations per simulation should be fixed
#   below and are common to all simulations. The description of the parameters is provided in
#   "launch_multiple_SEPAIHRD-Syria_structured.R, and an example of the input file required is  
#   input_parameters_multiple_launch_experimentA.csv."
# usage = Create the required input file in the same diretory in which this script is located, and
#     fix the parameters below, then simply source.
#
rm(list=ls())

###### START EDITING

# --- Name of the input file with parameters
File_multiple="input_parameters_multiple_launch_experimentC.csv"

# --- Options used for testing mode only
fake=0 # fix to 1 if you are working with test data 
test_sim=0 # fix to 1 to avoid generating output directories and files (debug purposes)

# --- Computational parameters
Ndays=365 # Number of days simulated
Nrand=500 # number of realizations of parameters

# --- Output options
Nfull=10 # Number of simulations whose results will be fully reported (1 to Nrand)


######### STOP EDITING
CompModel="SEPAIHRD" # Only "SEPAIHRD" implemented, but this string is required

this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
dirCodeSpec=paste(this.dir,"/src/",CompModel,sep="") # Directory where code specific to this model
setwd(dirCodeSpec)

params.df=read.table(file=File_multiple,header = TRUE)# col_types=c("cciiiicc"))#c("c","c","i","i","i","i","c","c"))
Nsim=dim(params.df)[1]

for(i in 1:Nsim){
  descr=as.character(params.df$descr[i])
  class.infected=as.character(params.df$class.infected[i])
  Npop=params.df$Npop[i]
  isolation=params.df$isolation[i]
  isoThr=params.df$isoThr[i]
  hospitalized2=params.df$hospitalized2[i]
  Tcheck=params.df$Tcheck[i]
  keywordA=as.character(params.df$keywordA[i])
  keywordB=as.character(params.df$keywordB[i])
  cat(" ** Running set of parameters #",i,"\n")
  source("SEPAIHRD-Syria_structured.R")
  setwd(dirCodeSpec)
}

