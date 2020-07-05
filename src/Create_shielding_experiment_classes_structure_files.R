# ****************************************
# Create_shielding_experiment_classes_structure_files.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 5th July 2020
# description = Generates files with population structures for 5 different shielding strategies:  
#        1. Only elderly (over 50) shielded (classes_structure_shieldage3)
#        2. Only vulnerable population (over 50 & 13-50 with comorbidities) shielded (classes_structure_shieldage2)
#        3. Vulnerable population + family (cap = 20% of camp) shielded (classes_structure_shieldpct20)
#        4. Vulnerable population + family (cap = 25% of camp) shielded (classes_structure_shieldpct25)
#        5. Vulnerable population + family (cap = 30% of camp) shielded (classes_structure_shieldpct30)
#         **Remainder of cap after vulnerable shielded: 60% allocated to adults (13-50 wo comorbidities), 40% to children (0-12)**
# usage = script should be run within the folder "data/estimation_parameters/class_structured_data". 
#### Load packages & data ####

library(tidyverse)

setwd("data/estimation_parameters/class_structured_data")
dirOut <- "shielding_scenarios_population_structure"

age_structure <- read.table("classes_structure_mixed", sep = "\t")

# Write rounding function to preserve sum
round_preserve_sum <- function(x, digits = 0) {
  up <- 10 ^ digits
  x <- x * up
  y <- floor(x)
  indices <- tail(order(x-y), round(sum(x)) - sum(y))
  y[indices] <- y[indices] + 1
  y / up
}

#### Compute population structures under different shielding scenarios ####

### Only elderly shielded (age3)

# Create dataframe

classes_structure_shieldage3 <- matrix(nrow = 1, ncol = 5) %>% 
  as.data.frame()
names(classes_structure_shieldage3) <- c("age1_orange", "age2_no_comorbid_orange", "age2_comorbid_orange", 
                                     "age3_no_comorbid_green", "age3_comorbid_green")

## All elderly aged over 50 go in green zone, rest of population in orange zone

classes_structure_shieldage3[, 1:5] <- age_structure[, 1:5]

### Elderly (age3) and adults with comorbidities (age2_comorid) shielded

# Create dataframe

classes_structure_shieldage2 <- matrix(nrow = 1, ncol = 5) %>% 
  as.data.frame()
names(classes_structure_shieldage2) <- c("age1_orange", "age2_no_comorbid_orange", "age2_comorbid_green", 
                                         "age3_no_comorbid_green", "age3_comorbid_green")

## All elderly aged over 50 & comorbid aged 13-50 go in green zone, rest of population in orange zone

classes_structure_shieldage2[, 1:5] <- age_structure[, 1:5]

### Vulnerable pop (all age3 & age_comorbid) + family go to green zone (cap = 20%; 60% remaining cap to age2_no_comorbid, 40% remaining cap to age1)

# Create dataframe

classes_structure_shield20pct <- matrix(nrow = 1, ncol = 7) %>% 
  as.data.frame()
names(classes_structure_shield20pct) <- c("age1_orange", "age1_green", "age2_no_comorbid_orange", "age2_no_comorbid_green", 
                                     "age2_comorbid_green", "age3_no_comorbid_green", "age3_comorbid_green")

## All adults with comorbidities 13-50 and elderly aged over 50 go in green zone

classes_structure_shield20pct[, 5:7] <- age_structure[, 3:5]

## Calculate remainder of capacity in shielded (green) zone (capacity = 20%)

green_rem20pct <- .2-sum(classes_structure_shield20pct[, 5:7])

# Remainder of green zone capacity allocated to age2_no_comorbid

green_rem_ad20pct <- green_rem20pct*.6

# Remainder of green zone capacity allocated to age1

green_rem_chil20pct <- green_rem20pct-green_rem_ad20pct

## Allocate children & non-comorbid adults to orange & green zones

# Green zone

classes_structure_shield20pct[, c(2, 4)] <- c(green_rem_chil20pct, green_rem_ad20pct)

# Orange zone

classes_structure_shield20pct[, c(1, 3)] <- c(age_structure[, 1]-green_rem_chil20pct, age_structure[, 2]-green_rem_ad20pct)

## Round proportions

classes_structure_shield20pct <- classes_structure_shield20pct %>% signif(digits = 3)

### Vulnerable pop (all age3 & age_comorbid) + family go to green zone (cap = 25%; 60% remaining cap to age2_no_comorbid, 40% remaining cap to age1)

# Create dataframe

classes_structure_shield25pct <- matrix(nrow = 1, ncol = 7) %>% 
  as.data.frame()
names(classes_structure_shield25pct) <- c("age1_orange", "age1_green", "age2_no_comorbid_orange", "age2_no_comorbid_green", 
                                          "age2_comorbid_green", "age3_no_comorbid_green", "age3_comorbid_green")

## All adults with comorbidities 13-50 and elderly aged over 50 go in green zone

classes_structure_shield25pct[, 5:7] <- age_structure[, 3:5]

## Calculate remainder of capacity in shielded (green) zone (capacity = 25%)

green_rem25pct <- .25-sum(classes_structure_shield25pct[, 5:7])

# Remainder of green zone capacity allocated to age2_no_comorbid

green_rem_ad25pct <- green_rem25pct*.6

# Remainder of green zone capacity allocated to age1

green_rem_chil25pct <- green_rem25pct-green_rem_ad25pct

## Allocate children & non-comorbid adults to orange & green zones

# Green zone

classes_structure_shield25pct[, c(2, 4)] <- c(green_rem_chil25pct, green_rem_ad25pct)

# Orange zone

classes_structure_shield25pct[, c(1, 3)] <- c(age_structure[, 1]-green_rem_chil25pct, age_structure[, 2]-green_rem_ad25pct)

## Round proportions

classes_structure_shield25pct <- classes_structure_shield25pct %>% signif(digits = 3)

### Vulnerable pop (all age3 & age_comorbid) + family go to green zone (cap = 30%; 60% remaining cap to age2_no_comorbid, 40% remaining cap to age1)

# Create dataframe

classes_structure_shield30pct <- matrix(nrow = 1, ncol = 7) %>% 
  as.data.frame()
names(classes_structure_shield30pct) <- c("age1_orange", "age1_green", "age2_no_comorbid_orange", "age2_no_comorbid_green", 
                                          "age2_comorbid_green", "age3_no_comorbid_green", "age3_comorbid_green")

## All adults with comorbidities 13-50 and elderly aged over 50 go in green zone

classes_structure_shield30pct[, 5:7] <- age_structure[, 3:5]

## Calculate remainder of capacity in shielded (green) zone (capacity = 30%)

green_rem30pct <- .3-sum(classes_structure_shield30pct[, 5:7])

# Remainder of green zone capacity allocated to age2_no_comorbid

green_rem_ad30pct <- green_rem30pct*.6

# Remainder of green zone capacity allocated to age1

green_rem_chil30pct <- green_rem30pct-green_rem_ad30pct

## Allocate children & non-comorbid adults to orange & green zones

# Green zone

classes_structure_shield30pct[, c(2, 4)] <- c(green_rem_chil30pct, green_rem_ad30pct)

# Orange zone

classes_structure_shield30pct[, c(1, 3)] <- c(age_structure[, 1]-green_rem_chil30pct, age_structure[, 2]-green_rem_ad30pct)

## Round proportions

classes_structure_shield30pct <- classes_structure_shield30pct %>% signif(digits = 3)

#### Export data ####

setwd(dirOut)
write.table(classes_structure_shieldage2, "classes_structure_shieldage2", sep = "\t")
write.table(classes_structure_shieldage3, "classes_structure_shieldage3", sep = "\t")
write.table(classes_structure_shield20pct, "classes_structure_shield20pct", sep = "\t")
write.table(classes_structure_shield25pct, "classes_structure_shield25pct", sep = "\t")
write.table(classes_structure_shield30pct, "classes_structure_shield30pct", sep = "\t")
