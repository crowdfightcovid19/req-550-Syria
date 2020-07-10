# ****************************************
# launch_SEPAIHRD-Syria_structured.R
# ****************************************
# 
# 
# author = Alberto Pascual-García 
# email = alberto.pascual.garcia@gmail.com 
# date = 6th July 2020
# description = This script simply provides the input for the parameters of the script 
#    SEPAIHRD-Syria_structured.R. These parameters are related to input and output files
#    some simulation options and computational variables such as the number of realizations.
#    Details about the simulations are described in the header of SEPAIHRD-Syria_structured.R
#    and a script to run simulations under different scenarios is launch_multiple_SEPAIHRD-Syria_structured.R
# usage = Fix the parameters below and source.
#
# Fix parameters ----------------------
# .... These are the parameters related to input and output of files and computational
# .... options. Epidemiological parameters are hardcoded in the file "input_parameters_$model.R"
# .... and are not expected to be changed.

rm(list=ls())
###### START EDITING

# --- Options used for testing mode only
fake=0 # fix to 1 if you are working with test data 
test_sim=0 # fix to 1 to avoid generating output directories and files (debug purposes)

# --- Structure of directories and labelling 
descr="shield_cont2_age3_age2_20" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
class.infected="age2_no_comorbid_orange" # string with the name of the class in which the first infection is detected

# --- Computational parameters
Npop=2000 # Population size
Ndays=365 # Number of days simulated
Nrand=50 # number of realizations of parameters


# --- Model type
isolation=0 # if hospitalized leaves the camp =1, stays in the camp = 0.
isoThr=0 # If isolation=1, maximum capacity of H people isolation, the difference H-isoThr becomes infectious
hospitalized2=1 # if hospitalized2 = 0, all hospitalized will recover, if = 1 all will die.
Tcheck=1 # if tests are implemented, symptomatic individuals will be excluded from the interaction between two classes
lockDown=1 # if there is one infection, apply lockdown to the shielded zone
keywordA="orange" # keyword to identify the first population class affected by Tcheck.
keywordB="green" # keyword to identify the second population class affected by Tcheck.
# The following are obsolete options, can be recovered from SIRQ model if needed
#ContMatType="mean" # one of "mean"= mean field, "external"= read from file
#strat=0 # if ContMatType="mean" and strat= 1 it will source contact_matrix.R, where you can create manually a contacts matrix

# --- Output options
Nfull=2 # Number of simulations whose results will be fully reported (1 to Nrand)

######### STOP EDITING

CompModel="SEPAIHRD" # Only "SEPAIHRD" implemented, but this string is required

this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
dirCodeSpec=paste(this.dir,"/src/",CompModel,sep="") # Directory where code specific to this model
setwd(dirCodeSpec)
source("SEPAIHRD-Syria_structured.R")

