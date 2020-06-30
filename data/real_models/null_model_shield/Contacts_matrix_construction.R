# ****************************************
# Contacts_matrix_construction.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 17th June 2020
# description = Creates a matrix describing the average number of contacts of an individual 
#        of class i with an individual of class j, the contact matrix C_ij as described 
#        here: https://github.com/crowdfightcovid19/req-550-Syria/blob/master/manuscripts/DerivationOfR0_APG.pdf
#        for the null model.
#        Input files = classes_structure.tsv (N_j/N) and classes_contacts.tsv (cbar_i) 
#        Output file = contacts_structuve.tsv (C_ij)
# usage = script should be run within the folder "data/real_models/null_model". 
### Setup

library(tidyverse)
setwd("data/real_models/null_model")

cbar_i <- read.table("classes_contacts", sep = "\t")
`N_j/N` <- read.table("classes_structure", sep = "\t")

### Generate contact matrix (C_ij)

C_ij <- as.numeric(cbar_i) %*% t(as.numeric(`N_j/N`))

colnames(C_ij) <- names(cbar_i)
rownames(C_ij) <- names(cbar_i)

### Export file

write.table(C_ij, "contacts_structure", sep = "\t")
