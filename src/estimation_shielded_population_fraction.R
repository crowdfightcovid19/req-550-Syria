# ****************************************
# estimation_shielded_population_fraction.R
# ****************************************
# 
# 
# author = Alberto Pascual-García
# email = alberto.pascual.garcia@gmail.com 
# date = 3rd July 2020
# description = This script aims to estimate the fraction of the total population that would
#   be shielded considering that age2 with comorbidities plus their spouses and their kids < 13
#   are moved to the green zone
########

# --- Fix the probability of getting married

P_married=0.95

# --- Set up working directories
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
descr="null_model_mixed" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
dirTmp="/real_models/"
dirDataIn=paste(this.dir,"/data",dirTmp,descr,sep="") # Directory for the input data
dirCodeBase=paste(this.dir,"/src",sep="") # Directory where the function with the basic code is found

# Read input data ---------
setwd(dirCodeBase)
source("read_classStructuredData_function.R")
struct.param=read_classStructuredData_function(dirDataIn)
class.str=unlist(struct.param["class.str"][[1]])
class.names=names(class.str)
class.str=t(as.matrix(class.str))
colnames(class.str)=class.names
class.str=as.data.frame(class.str)

# Estimate the fraction of age2 and age 3 shielded ----
# .... For age2 we consider those comorbidities and their spouses
frac_age2_green = class.str$age2_comorbid*( 1 + P_married*(1-class.str$age2_comorbid)) # fraction of adults shielded
# .... For age3 we consider all
frac_age3_green = class.str$age3_comorbid + class.str$age3_no_comorbid

# Now estimate the number of married women 
frac_married_women = P_married * (class.str$age2_comorbid+class.str$age2_no_comorbid)/2
# If all kids in age1 have theirs moms alive, we can estimate the number of kids per woman 
Nage1=class.str$age1/frac_married_women
# Now simply estimate the number of married woman in the green subpopulation
frac_married_women_green = (frac_age2_green * P_married)/2
# And which is the fraction of the total population that their kids represent
frac_age1_green = frac_married_women_green*Nage1

# Sum them all:
frac_green = frac_age2_green + frac_age1_green + frac_age3_green

# test for Jordan's argument
P_sp = P_married*(1-(class.str$age2_comorbid*class.str$age2_comorbid))

