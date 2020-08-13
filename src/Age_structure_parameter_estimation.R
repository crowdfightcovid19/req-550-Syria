# ****************************************
# Age_stucture_parameter_estimation.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 13th August 2020
# ***New version, old version = Age_stucture_parameter_estimation_old.R***
# description = Generates files with simulated populations for a model with a well-mixed (classes_structure_mixed) and  
#        shielded population (classes_structure_shield) split up into classes based on age/comorbidity estimates from the entire idp population. 
#        Provides a description of how to simulate population structures for models of camps with different population sizes. 
#        Generates files for parameter estimates for each population class: 
#        fraction requiring non-ICU hospitalization (fracItoH), 
#        & fraction requiring ICU (fracItoD). 
# usage = script should be run within the folder "data". 
#### Load packages & data ####

library(tidyverse)
library(readxl)

setwd("data")
dirOut="estimation_parameters/class_structured_data"

pop <- read.csv("age_structure_and_NCDprevalence/entire_population.csv")
camps <- read_excel("idps_in_camps_syria_april_2020.xlsx")
census <- read.csv("Jordan_refugee_census_2015.csv")[, -5]

#*Set capacity of green zone*
green_cap <- .2

# Write rounding function to preserve sum
round_preserve_sum <- function(x, digits = 0) {
  up <- 10 ^ digits
  x <- x * up
  y <- floor(x)
  indices <- tail(order(x-y), round(sum(x)) - sum(y))
  y[indices] <- y[indices] + 1
  y / up
}

#### Population structure/simulated pop ####
## Age groups 
# Estimate proportion of population in each age group in idp pop
# (3 groups: age = 0-12/13-50/over 50)

age <- list(select(pop, total_0_6_months:total_6_12), 
                     select(pop, total_13_17:total_18_50), 
                     select(pop, total_over50)) %>% 
  lapply(function(x) {
    sum(x)/pop$Total_pop
  }) %>% cbind.data.frame()

names(age) <- c("age1", "age2", "age3")

#### Estimate NCD prevalence in simulated population
### Use age-specific prevalence estimates from Jordan: https://reliefweb.int/sites/reliefweb.int/files/resources/Hidden%20victims%20of%20the%20Syrian%20Crisis%20April%202014%20-%20Embargoed%2000.01%209April.pdf
## Approximate age distribution in the 18-50 interval using census of Syrian refugees in Jordan

age_dist_18_50 <- data.frame(Age = c("18-19", as.character(census[6:11, 1]), "50"), 
                             Pop = c(.4*census[5, 3], census[6:11, 3], .2*census[12, 3]))

age_dist_18_50 <- mutate(age_dist_18_50, Proportion = Pop/sum(Pop))

## Combine 18-50 age distribution approximation with 13-17 age group to approximate age distribution in entire 13-50 interval (age2)

age_dist_13_50 <- data.frame(Age = c("13-17", as.character(age_dist_18_50$Age)), 
                             Pop = c(pop$total_13_17, pop$total_18_50*age_dist_18_50$Proportion))

# Estimate NCD prevalence in each age interval 13-50- (13-29 = .1, 30-50 = .3)

age_dist_13_50 <- mutate(age_dist_13_50, Proportion = Pop/sum(Pop), NCD_prev = c(rep(.1,4), rep(.3, 5)))

### Set values of NCD prevalence estimates in age2 (13-50) and age3 (>50)

age2_NCD <- sum(age_dist_13_50$NCD_prev*age_dist_13_50$Proportion)
age3_NCD <- .5

## Generate dataframe with age & comorbidity structure

age_structure <- data.frame(age[, 1], 
                            age[, 2]-age[, 2]*age2_NCD, age[, 2]*age2_NCD, 
                            age[, 3]-age[, 3]*age3_NCD, age[, 3]*age3_NCD) %>% 
  signif(digits = 3)

names(age_structure) <- c("age1", "age2_no_comorbid", 
                          "age2_comorbid", "age3_no_comorbid", "age3_comorbid")

### Population structure of a well-mixed population with 5 population classes

classes_structure_mixed <- age_structure

### Population structure of a shielded population with 7 classes

# Create dataframe

classes_structure_shield <- matrix(nrow = 1, ncol = 7) %>% 
  as.data.frame()
names(classes_structure_shield) <- c("age1_orange", "age1_green", "age2_no_comorbid_orange", "age2_no_comorbid_green", 
                                     "age2_comorbid_green", "age3_no_comorbid_green", "age3_comorbid_green")

## All adults with comorbidities 13-50 and elderly aged over 50 go in green zone

classes_structure_shield[, 5:7] <- age_structure[, 3:5]

## Calculate remainder of capacity in shielded (green) zone

green_rem <- green_cap-sum(classes_structure_shield[, 5:7])

### Remainder of green zone: children = 40%, adults = 60%
# Remainder of green zone capacity allocated to age2_no_comorbid

green_rem_ad <- green_rem*.6

## Calculate proportion of children that will go to green zone
# Remainder of green zone capacity allocated to age1

green_rem_chil <- green_rem-green_rem_ad

## Allocate children & non-comorbid adults to orange & green zones

# Green zone

classes_structure_shield[, c(2, 4)] <- c(green_rem_chil, green_rem_ad)

# Orange zone

classes_structure_shield[, c(1, 3)] <- c(age_structure[, 1]-green_rem_chil, age_structure[, 2]-green_rem_ad)

## Round proportions

classes_structure_shield <- classes_structure_shield %>% signif(digits = 3)

# Well-mixed 5 class population structure

fracItoH_structure_mixed <- c(.064, .067, .199, .183, .445) %>% 
  t() %>% 
  as.data.frame()

names(fracItoH_structure_mixed) <- names(classes_structure_mixed)

# 7 class population structure with shielding

fracItoH_structure_shield <- c(.064, .064, .067, .067, .199, .183, .445) %>% 
  t() %>% 
  as.data.frame()

names(fracItoH_structure_shield) <- names(classes_structure_shield)

## Fraction of cases requiring ICU (fracItoD)
# Data for children:
# https://pediatrics.aappublications.org/content/pediatrics/early/2020/03/16/peds.2020-0702.full.pdf
# Set proportion requiring ICU in age group 0-12 to proportion critical aged <11
# Data for adults:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7119513/
# Set proportion requiring ICU in age group 13-50 w/o comorbidities to proportion aged 19-64 w/o comorbitidies
# Set proportion requiring ICU in age group 13-50 w comorbidities to proportion aged 19-64 w comorbitidies
# Set proportion requiring ICU in age group over 50 w/o comorbidities to proportion aged 65+ w/o comorbitidies

# Well-mixed 5 class population structure

fracItoD_structure_mixed <- c(.0065, .02, .094, .063, .222) %>% 
  t() %>% 
  as.data.frame()

names(fracItoD_structure_mixed) <- names(classes_structure_mixed)

# 7 class population structure with shielding

fracItoD_structure_shield <- c(.0065, .0065, .02, .02, .094, .063, .222) %>% 
  t() %>% 
  as.data.frame()

names(fracItoD_structure_shield) <- names(classes_structure_shield)

#### Export data ####

setwd(dirOut)
write.table(classes_structure_mixed, "classes_structure_mixed", sep = "\t")
write.table(classes_structure_shield, "classes_structure_shield", sep = "\t")
write.table(fracItoH_structure_mixed, "fracItoH_structure_mixed", sep = "\t")
write.table(fracItoH_structure_shield, "fracItoH_structure_shield", sep = "\t")
write.table(fracItoD_structure_mixed, "fracItoD_structure_mixed", sep = "\t")
write.table(fracItoD_structure_shield, "fracItoD_structure_shield", sep = "\t")
