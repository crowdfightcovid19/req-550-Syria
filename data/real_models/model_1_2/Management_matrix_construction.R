# ****************************************
# Management_matrix_construction.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 24th June 2020
# description = Management/contact matrices for model with shielding strategy- people in the green zone can visit with 10 family members per week
# Creates 3 matrices:  
#        1. Management matrix (m_ij)- the proportional change in population class `i`'s exposure to population class `j` from the intervention
#        2. Contact matrix-null (C_ij)- average number of contacts of an individual of class `i` with an individual of class `j` if the intervention were not implemented (same as the null model)
#        3. Contact matrix-intervention (C_ij_interv)- average number of contacts of an individual of class `i` with an individual of class `j` resulting from the intervention parametrized by the management matrix
#        Input files = "classes_structure" (N_j/N) and "classes_contacts" (cbar_i) 
#        Output files = "management_matrix" (m_ij), "contacts_structuve_null" (C_ij), "contacts_structure_intervention" (C_ij_interv)
# usage = script should be run within the folder "data/real_models/model_1_2". 
### Setup

library(tidyverse)
setwd("data/real_models/model_1_2")

cbar_i <- read.table("classes_contacts", sep = "\t")
`N_j/N` <- read.table("classes_structure", sep = "\t")

### Define parameters

# Relative risk of infection from contact in neutral zone compared to contacts in orange/green zones
# (Assumed .2, lack of consensus in literature of precise effect of masks/distance on transmission)

RR <- .2

# Family members people in green zone can visit per week

fam_vis <- 10

# Proportion of population in orange & green zones

N_o <- `N_j/N`[, grepl("orange", names(`N_j/N`))] %>% 
  sum()
N_g <- `N_j/N`[, grepl("green", names(`N_j/N`))] %>% 
  sum()

### Derivation of m_ij values
## m_ig,jo = RR * cbar_ig,o/cbar_i * N/N_o
## m_ig,jg = N/N_g
## m_io,jg = RR * cbar_io,g/cbar_i * N/N_g
## m_io,jo = N/N_o
## `ig`/`jg` = any population class `i` or `j` in green zone, `io`/`jo` = any population class `i` or `j` in orange zone

# cbar_ig,o = average daily contacts of people in class `i` in green zone with people in orange zone (2 family members/week)

cbar_ig_o <- fam_vis/7

# cbar_io,g = average daily contacts of people in class `i` in orange zone with people in green zone (account for ratio of population in orange zone to green zone)

cbar_io_g <- cbar_ig_o/(N_o/N_g)

### Generate manamgement matrix (m_ij)

m_ij <- matrix(nrow = 7, ncol = 7)
rownames(m_ij) <- names(cbar_i)
colnames(m_ij) <- names(cbar_i)

## m_io,jo

m_ij[grepl("orange", rownames(m_ij)), grepl("orange", colnames(m_ij))] <- 1/N_o

## m_ig,jg

m_ij[grepl("green", rownames(m_ij)), grepl("green", colnames(m_ij))] <- 1/N_g

## m_ig,jo

m_ij[grepl("green", rownames(m_ij)), grepl("orange", colnames(m_ij))] <- as.numeric(RR*(cbar_ig_o/cbar_i[grep("green", rownames(m_ij))])*(1/N_o))

## m_io,jg

m_ij[grepl("orange", rownames(m_ij)), grepl("green", colnames(m_ij))] <- as.numeric(RR*(cbar_io_g/cbar_i[grep("orange", rownames(m_ij))])*(1/N_g))

### Generate null contact matrix (C_ij)

C_ij <- as.numeric(cbar_i) %*% t(as.numeric(`N_j/N`))

colnames(C_ij) <- names(cbar_i)
rownames(C_ij) <- names(cbar_i)

### Generate intervention contact matrix (C_ij_interv)

C_ij_interv <- diag(as.vector(m_ij)) %*% diag(as.vector(C_ij)) %>% diag() %>% matrix(ncol = 7)

colnames(C_ij_interv) <- colnames(C_ij)
rownames(C_ij_interv) <- rownames(C_ij)

### Export file

write.table(m_ij, "management_matrix", sep = "\t")
write.table(C_ij, "contacts_structure_null", sep = "\t")
write.table(C_ij_interv, "contacts_structure_intervention", sep = "\t")

