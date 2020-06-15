# ****************************************
# Theta_matrix_computation.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 15th June 2020
# description = Allows the user to set values for individuals from each population class' contact with other 
#        population classes (relative to contact with their own, 1). Then computes the "Theta matrix" using 
#        this contact matrix and the relative sizes of each population class, necessary for the computation 
#        of R0 as described here: https://github.com/crowdfightcovid19/req-550-Syria/blob/master/manuscripts/DerivationOfR0_jordan.pdf
#        Outputs files for the contact matrix and Theta matrix.
# usage = script should be run within the folder "data/real_models". 
### Setup

library(tidyverse)
library(matlib)
setwd("data/real_models")

### Contact/mixing matrix

# Set values for relative contact rate between population classes
# *User can change*
# *Set to 1 for perfectly well-mixed population*
#        *(contact rate with each other class = contact rate with own class)*

mix_age1_age2 <- 1
mix_age1_age2comorbid <- 1
mix_age1_age3 <- 1
mix_age1_age3comorbid <- 1
mix_age2_age2comorbid <- 1
mix_age2_age3 <- 1
mix_age2_age3comorbid <- 1
mix_age2comorbid_age3 <- 1
mix_age2comorbid_age3comorbid <- 1
mix_age3_age3comorbid <- 1

class_contacts <- c(mix_age1_age2, mix_age1_age2comorbid, 
                    mix_age1_age3, mix_age1_age3comorbid, 
                    mix_age2_age2comorbid, mix_age2_age3, 
                    mix_age2_age3comorbid, mix_age2comorbid_age3, 
                    mix_age2comorbid_age3comorbid, mix_age3_age3comorbid)

# Generate unscaled mixing/contact matrix

contact_unscaled <- matrix(rep(1, 5*5), ncol = 5)
contact_unscaled[lower.tri(contact_unscaled)] <- c(class_contacts)
contact_unscaled <- t(contact_unscaled)
contact_unscaled[lower.tri(contact_unscaled)] <- c(class_contacts)

# Generate scaling matrix

scaling_matrix <- 1/rowSums(contact_unscaled) %>% 
  diag()
scaling_matrix[upper.tri(scaling_matrix)] <- 0
scaling_matrix[lower.tri(scaling_matrix)] <- 0

# Compute contact matrix

contact_matrix <- scaling_matrix %*% contact_unscaled

### Population class matrix

# Import population class data

pop_classes <- read.csv("age_structure.csv")

# Generate population class matrix

pop_matrix <- diag(pop_classes)

### Compute theta matrix

Theta_matrix <- pop_matrix %*% contact_matrix %*% inv(pop_matrix)

### Output files

# Reformat matrices for export

contact_matrix <- as.data.frame(contact_matrix)
colnames(contact_matrix) <- names(pop_classes)
rownames(contact_matrix) <- names(pop_classes)

Theta_matrix <- as.data.frame(Theta_matrix)
colnames(Theta_matrix) <- names(pop_classes)
rownames(Theta_matrix) <- names(pop_classes)

# Export files

write_csv(contact_matrix, "contact_matrix.csv")
write_csv(Theta_matrix, "Theta_matrix.csv")
