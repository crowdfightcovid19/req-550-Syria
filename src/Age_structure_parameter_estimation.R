# ****************************************
# Age_stucture_parameter_estimation.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 27th May 2020
# description = Generates a file with a simulated population for the model split up into classes 
#        based on age/comorbidity estimates from the entire idp population.
#        Generates files for parameter estimates for each population class: 
#        proportion symptomatic (fracAI), hospitalization rate (), & case-fatality rate (alpha). 
# usage = script should be run within the folder "data". 
#### Load packages & data ####

library(tidyverse)
library(rvest)

setwd("data")
dirOut="real_models"

pop <- read.csv("age_structure_and_NCDprevalence/entire_population.csv")

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
# Estimate pop size in each age group in simulated refugee population of 2000
# (6 groups: age = 0-12/13-50/over 50)

age <- list(select(pop, total_0_6_months:total_6_12), 
                     select(pop, total_13_17:total_18_50), 
                     select(pop, total_over50)) %>% 
  lapply(function(x) {
    sum(x)/pop$Total_pop*2000
  }) %>% cbind.data.frame()

## Estimate NCD prevalence in simulated population

## NCD <- select(pop, Diabetes:Chronic.kidney.failure) %>% 
##  sum()/pop$Total_pop*2000

## Generate dataframe with age & comorbidity structure

age_structure <- data.frame(age[, 1], 0, age[, 2], 0, 0, age[, 3]) %>% 
  round_preserve_sum()

names(age_structure) <- c("age1_healthy", "age1_vulnerable", "age2_healthy", 
                          "age2_vulnerable", "age3_healthy", "age3_vulnerable")

#### Parameter estimates ####
## Proportion symptomatic (fracAI)
# Proportion asymptomatic (.16) from meta analysis:
# https://www.medrxiv.org/content/10.1101/2020.05.10.20097543v1

fracAI_structure <- rep(1-.16, 6) %>% 
  t() %>% 
  as.data.frame()

names(fracAI_structure) <- names(age_structure)

## Hospitalization rate/proportion of sympotatic cases requiring hospitalization (zeta)
# Using estimates from the ICL report:
# https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf
# Assume average in age group 0-12 approx % aged 0-9 requiring hospitalization in ICL report
# Assume average in age group 13-50 approx % aged 20-29 requiring hospitalization in ICL report
# Assume average in age group over 50 approx % aged 60-69 requiring hospitalization in ICL report
zeta_structure <- c(rep(.001, 2), rep(.012, 2), rep(.166, 2)) %>% 
  t() %>% 
  as.data.frame()

names(zeta_structure) <- names(age_structure)


## Case fatality rate (alpha)
# Using estimates from the ICL report:
# https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf
# Assume all hospitalized cases requiring critical care will die
# Assume average CFR in age group 0-12 approx % hospitalized aged 0-9 requiring critical care
# Assume average CFR in age group 13-50 approx % hospitalized aged 20-29 requiring critical care
# Assume average CFR in age group over 50 approx % hospitalized aged 60-69 requiring critical care

alpha_structure <- c(rep(.05, 4), rep(.274, 2)) %>% 
  t() %>% 
  as.data.frame()

names(alpha_structure) <- names(age_structure)

#### Export data ####

setwd(dirOut)
write_csv(age_structure, "age_structure.csv")
write_csv(fracAI_structure, "fracAI_structure.csv")
write_csv(zeta_structure, "zeta_structure.csv")
write_csv(alpha_structure, "alpha_structure.csv")
