# ****************************************
# Age_stucture_parameter_estimation.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 27th May 2020
# description = Generates a file with a simulated population for the model split up into classes 
#        based on age/sex/comorbidity estimates from the entire idp population.
#        Generates files for age-dependent parameter estimates for each population class: 
#        proportion symptomatic (fracAI), recovery rate (gamma), & case-fatality rate (alpha). 
# usage = script should be run within the folder "data/fake_models". 
#### Load packages & data ####

library(tidyverse)
library(rvest)

setwd("data/fake_models")
dirOut="age3_gender2_com2_v2_by_jordan"

pop <- read.csv("data/age_structure_and_NCDprevalence/entire_population.csv")
pop_structure <- read.table(file="data/fake_models/age3_gender2_com2/age_structure.csv",sep="\t",header = T)

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
## Age & sex groups 
# Estimate pop size in each age & sex group in simulated refugee population of 2000
# (6 groups: sex = M/F, age = 0-12/13-50/over 50)

age_sex <- list(select(pop, Males.from.0.to.6.months.of.age:Males.from.6.to.12.years.of.age), 
                     select(pop, Females.from.0.to.6.months.of.age:Females.from.6.to.12.years.of.age), 
                     select(pop, Males.from.13.to.17.years.of.age:Males.from.18.to.50.years.of.age), 
                     select(pop, Females.from.13.to.17.years.of.age:Females.from.18.to.50.years.of.age), 
                     select(pop, Males.above.50.years.of.age), select(pop, Females.above.50.years.of.age)) %>% 
  lapply(function(x) {
    sum(x)/pop$Total_pop*2000
  }) %>% cbind.data.frame()

# Estimate NCD prevalence in simulated population

NCD <- select(pop, Diabetes:Chronic.kidney.failure) %>% 
  sum()/pop$Total_pop*2000

## Generate dataframe with age, sex, comorbidity structure

age_structure <- data.frame(age_sex[, 1:2], 0, 0, age_sex[, 3]-.1*NCD*(age_sex[, 3]/sum(age_sex[, 3:4])), 
                                age_sex[, 4]-.1*NCD*(age_sex[, 4]/sum(age_sex[, 3:4])), 
                                .1*NCD*(age_sex[, 3]/sum(age_sex[, 3:4])), 
                                .1*NCD*(age_sex[, 4]/sum(age_sex[, 3:4])), 0, 0, age_sex[, 5:6]) %>% 
  round_preserve_sum()

names(age_structure) <- names(pop_structure)

#### Parameter estimates ####
## Proportion symptomatic (fracAI)
# Estimated using age-specific data from the Diamond princess (https://www.niid.go.jp/niid/en/2019-ncov-e/9417-covid-dp-fe-02.html)
# Adjusted for median estimate of the proportion of asymptomatic cases that are true asymptomatic: 
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7078829/

# Scrape NIID Japan Diamond Princess website (https://www.niid.go.jp/niid/en/2019-ncov-e/9417-covid-dp-fe-02.html)

read_html("https://www.niid.go.jp/niid/en/2019-ncov-e/9417-covid-dp-fe-02.html") %>% 
  html_nodes(".item-page > div:nth-child(4) > table:nth-child(22)") %>% 
  html_table(header = TRUE) %>% 
  .[[1]] -> DP_cases

# Clean data & aggregate by age group

DP_cases[, 2:4] <- select(DP_cases, `Symptomatic confirmed cases (%)`:`Total confirmed cases (%)`) %>% 
  sapply(function(x) {
    as.character(x) %>% 
      gsub("\\s*\\([^\\)]+\\)","", .) %>% 
      as.numeric()
  })

DP_cases$age_grp <- c(rep("age1", 2), rep("age2", 3), rep("age3", 5), NA)

# Calculate fracAI

fracAI_vals <- 1-(aggregate(DP_cases$`Asymptomatic confirmed cases (%)`, by = list(DP_cases$age_grp), FUN = sum)[, 2]/
  aggregate(DP_cases$`Total confirmed cases (%)`, by = list(DP_cases$age_grp), FUN = sum)[, 2]*.35)

fracAI_structure <- c(rep(fracAI_vals[1], 4), rep(fracAI_vals[2], 4), rep(fracAI_vals[3], 4)) %>% 
  t() %>% 
  as.data.frame()

names(fracAI_structure) <- names(pop_structure)

## Case fatality rate (alpha)
# Using estimates from the ICL report:
# https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf
# Assume all cases requiring hospitalization will die
# Assume average CFR in age group 0-12 approx % aged 0-9 requiring hospitalization in ICL report
# Assume average CFR in age group 13-50 approx % aged 20-29 requiring hospitalization in ICL report
# Assume average CFR in age group over 50 approx % aged 60-69 requiring hospitalization in ICL report

alpha_structure <- c(rep(.001, 4), rep(.012, 4), rep(.166, 4)) %>% 
  t() %>% 
  as.data.frame()

names(alpha_structure) <- names(pop_structure)

## Recovery rate (gamma)
## * To complete * ##

#### Export data ####

setwd(dirOut)
write_csv(age_structure, "age_structure.csv")
write_csv(fracAI_structure, "fracAI_structure.csv")
write_csv(alpha_structure, "alpha_structure.csv")
