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
File_multiple="input_parameters_multiple_launch_experimentK.csv"

# --- Options used for testing mode only
fake=0 # fix to 1 if you are working with test data 
test_sim=0 # fix to 1 to avoid generating output directories and files (debug purposes)
model.type="stochastic_variable" # one of "deterministic", "stochastic_fixed" or "stochastic_variable"
xi=0.2 # additional reduction in the probability of infection between carers and isolated in tents, considering use of mask, etc and additional distancing

# --- Computational parameters
Ndays=365 # Number of days simulated
Nrealiz=500 # Number of realizations of ALL parameters
Nrand=10000 # number of random values generated per realization for each parameter. Can be fixed to Nrealiz if "deterministic" or
# "stochastic_fixed" but  it is ~30 times larger for "stochastic_var", e.g. 10K for 365 days

# --- Output options
Nfull=10 # Number of simulations whose results will be fully reported (1 to Nrand)


######### STOP EDITING
CompModel="SEPAIHRD" # Only "SEPAIHRD" implemented, but this string is required

#this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
this.dir="~/Nextcloud/Militancia/crowdfightcovid19/Projects/Request550-Syria/req-550-Syria"
dirCodeSpec=paste(this.dir,"/src/",CompModel,sep="") # Directory where code specific to this model
setwd(dirCodeSpec)

params.df=read.table(file=File_multiple,header = TRUE)# col_types=c("cciiiicc"))#c("c","c","i","i","i","i","c","c"))
Nsim=dim(params.df)[1]
cat(" ** Running experiment: ",File_multiple,"\n")

for(i in 1:Nsim){
  descr=as.character(params.df$descr[i])
  class.infected=as.character(params.df$class.infected[i])
  class.carers=class.infected # structure of input file should change with other choices
  Npop=params.df$Npop[i]
  isolation=params.df$isolation[i]
  isoThr=params.df$isoThr[i]
  onset=params.df$onset[i]
  hospitalized2=params.df$hospitalized2[i]
  Tcheck=params.df$Tcheck[i]
  keywordA=as.character(params.df$keywordA[i])
  keywordB=as.character(params.df$keywordB[i])
  lockDown=params.df$lockDown[i]
  self=params.df$self[i]
  cat(" ** Running set of parameters #",i,"\n")
  source("SEPAIHRD-Syria_structured.R")
  setwd(dirCodeSpec)
}

