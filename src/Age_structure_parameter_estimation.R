# ****************************************
# Age_stucture_parameter_estimation.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 27th May 2020
# description = Generates files with simulated populations for a model with a well-mixed (classes_structure_mixed) and  
#        shielded population (classes_structure_shield) split up into classes based on age/comorbidity estimates from the entire idp population. 
#        Provides a description of how to simulate population structures for models of camps with different population sizes. 
#        Generates files for parameter estimates for each population class: 
#        fraction requiring non-ICU hospitalization (fracItoH), 
#        & fraction requiring ICU (fracItoD). 
# usage = script should be run within the folder "data". 
#### Load packages & data ####

library(tidyverse)
library(rvest)
library(readxl)

setwd("data")
dirOut="estimation_parameters/class_structured_data"

pop <- read.csv("age_structure_and_NCDprevalence/entire_population.csv")
camps <- read_excel("idps_in_camps_syria_april_2020.xlsx")

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
# Estimate proportion of population in each age group
# (3 groups: age = 0-12/13-50/over 50)

age <- list(select(pop, total_0_6_months:total_6_12), 
                     select(pop, total_13_17:total_18_50), 
                     select(pop, total_over50)) %>% 
  lapply(function(x) {
    sum(x)/pop$Total_pop
  }) %>% cbind.data.frame()

names(age) <- c("age1", "age2", "age3")

#### Estimate NCD prevalence in simulated population
## 4 NCDs = hypertension, cardiovascular disease, diabetes, chronic respiratory disease

## Jordan data (https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-015-2429-3)

jor_data <- read_html("https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-015-2429-3/tables/1") %>% 
  html_nodes(".data") %>%
  html_table(header = T, fill = T) %>% 
  .[[1]]

# Clean

jor_data[1, ] <- NA

jor_data[, 2:12] <- sapply(jor_data[, 2:12], function(x) {
  gsub(" [(](.*)", "", x) %>% 
    as.numeric()
})

## Lebanon data (https://conflictandhealth.biomedcentral.com/articles/10.1186/s13031-016-0088-3)

leb_data <- read_html("https://conflictandhealth.biomedcentral.com/articles/10.1186/s13031-016-0088-3/tables/1") %>% 
  html_nodes(".data") %>%
  html_table(header = T, fill = T) %>% 
  .[[1]]

# Clean

leb_data[c(1, 5, 10, 14, 18, 22, 26), ] <- NA

leb_data[, c(2, 4, 6, 8, 10)] <- sapply(leb_data[, c(2, 4, 6, 8, 10)], function(x) {
  substr(x, 1, nchar(x)-2) %>% 
    as.numeric()
})

## Estimate percent with each NCD in age groups 0-17, 18-50, over 50
## *Assume 50% of population & NCDs in 40-59 age group are at ages 40-50 & 50% at ages 51-59*
# Jordan

Jordan_ages <- data.frame(Age = c("0-17", "18-50", "50+"), 
                          N = c(jor_data[4, 2], jor_data[5,2]+jor_data[6,2]/2, jor_data[7,2]+jor_data[6,2]/2), 
                          Hyp = NA, CVD = NA, Dia = NA, Resp = NA)
Jordan_ages[1, 3:6] <- jor_data[4, c(4, 6, 8, 10)]/100

Jordan_ages[2, 3:6] <- c((jor_data[5, 3]+jor_data[6, 3]/2)/Jordan_ages[2, 2], 
                         (jor_data[5, 5]+jor_data[6, 5]/2)/Jordan_ages[2, 2], 
                         (jor_data[5, 7]+jor_data[6, 7]/2)/Jordan_ages[2, 2], 
                         (jor_data[5, 9]+jor_data[6, 9]/2)/Jordan_ages[2, 2])
Jordan_ages[3, 3:6] <- c((jor_data[7, 3]+jor_data[6, 3]/2)/Jordan_ages[3, 2], 
                         (jor_data[7, 5]+jor_data[6, 5]/2)/Jordan_ages[3, 2], 
                         (jor_data[7, 7]+jor_data[6, 7]/2)/Jordan_ages[3, 2], 
                         (jor_data[7, 9]+jor_data[6, 9]/2)/Jordan_ages[3, 2])

# Lebanon

Lebanon_ages <- data.frame(Age = c("0-17", "18-50", "50+"), 
                           N = c(4371, 2731+915/2, 915/2+240), 
                           Hyp = NA, CVD = NA, Dia = NA, Resp = NA)
Lebanon_ages[1, 3:6] <- leb_data[8, c(2, 4, 6, 8)]/100

Lebanon_ages[2, 3:6] <- c((2731*leb_data[12,2]/100+915*leb_data[16, 2]/100/2)/Lebanon_ages[2, 2], 
                          (2731*leb_data[12,4]/100+915*leb_data[16, 4]/100/2)/Lebanon_ages[2, 2], 
                          (2731*leb_data[12,6]/100+915*leb_data[16, 6]/100/2)/Lebanon_ages[2, 2], 
                          (2731*leb_data[12,8]/100+915*leb_data[16, 8]/100/2)/Lebanon_ages[2, 2])
Lebanon_ages[3, 3:6] <- c((240*leb_data[20,2]/100+915*leb_data[16, 2]/100/2)/Lebanon_ages[3, 2], 
                          (240*leb_data[20,4]/100+915*leb_data[16, 4]/100/2)/Lebanon_ages[3, 2], 
                          (240*leb_data[20,6]/100+915*leb_data[16, 6]/100/2)/Lebanon_ages[3, 2], 
                          (240*leb_data[20,8]/100+915*leb_data[16, 8]/100/2)/Lebanon_ages[3, 2])

## Weighted average of NCD prevalence from Jordan & Lebanon

weight_avg <- data.frame(Age = c("0-17", "18-50", "50+"), 
                         N_Jor = Jordan_ages$N, N_Leb = Lebanon_ages$N, 
                         N = Jordan_ages$N + Lebanon_ages$N)

weight_avg <- mutate(weight_avg, Hyp = (N_Jor*Jordan_ages$Hyp+N_Leb*Lebanon_ages$Hyp)/N, 
                     CVD = (N_Jor*Jordan_ages$CVD+N_Leb*Lebanon_ages$CVD)/N, 
                     Dia = (N_Jor*Jordan_ages$Dia+N_Leb*Lebanon_ages$Dia)/N, 
                     Resp = (N_Jor*Jordan_ages$Resp+N_Leb*Lebanon_ages$Resp)/N)

## Estimated cases of NCDs in Syrian refugee camps 
## *Assuming prevalence is equal to the weighted average of Syrian refugees in Jordan & Lebaon*

camps_NCDs <- data.frame(Age = c("0-17", "18-50", "50+"), 
                         N = c(sum(select(pop, total_0_6_months:total_13_17)), 
                               pop$total_18_50, pop$total_over50))

camps_NCDs <- mutate(camps_NCDs, Hyp = N*weight_avg$Hyp, CVD = N*weight_avg$CVD, 
                     Dia = N*weight_avg$Dia, Resp = N*weight_avg$Resp)

## Estimated prevalence of NCDs in model population structure- age groups 0-12, 13-50, over 50
## *Assuming all NCDs in the 0-17 age group are in those older than 12*

pop_str_NCDs <- data.frame(Age = c("0-12", "13-50", "50+"), Hyp_prop = NA, CVD_prop = NA, 
                           Dia_prop = NA, Resp_prop = NA, Hyp = NA, CVD = NA, 
                           Dia = NA, Resp = NA)

pop_str_NCDs[1, 2:9] <- c(0)
pop_str_NCDs[2, 2:5] <- c(sum(camps_NCDs$Hyp[1:2]), sum(camps_NCDs$CVD[1:2]), 
                          sum(camps_NCDs$Dia[1:2]), sum(camps_NCDs$Resp[1:2]))/
  sum(select(pop, total_13_17:total_18_50))
pop_str_NCDs[3, 2:5] <- camps_NCDs[3, 3:6]/pop$total_over50

pop_str_NCDs[2, 6:9] <- pop_str_NCDs[2, 2:5]*age[1, 2]
pop_str_NCDs[3, 6:9] <- pop_str_NCDs[3, 2:5]*age[1, 3]

## Generate dataframe with age & comorbidity structure

age_structure <- data.frame(age[, 1], 
                            age[, 2]-sum(pop_str_NCDs[2, 6:9]), sum(pop_str_NCDs[2, 6:9]), 
                            age[, 3]-sum(pop_str_NCDs[3, 6:9]), sum(pop_str_NCDs[3, 6:9])) %>% 
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

## Calculate proportion of non-comorbid adults that will go to green zone

# Calculate P(married)

P_married <- 1- sum(camps$`Female-headed households`)/sum(camps$`Total number of households living in the camp`)

# Calculate P(age2 = comorbid)

P_comorbid <- age_structure[, 3]/sum(age_structure[, 2:3])

# Calculate P(age2_comorbid bring age2_no_comorbid spouse)

P_bringspouse <- P_married*(1-P_comorbid)

# Remainder of green zone capacity allocated to age2_no_comorbid

green_rem_ad <- age_structure[, 3]*P_bringspouse

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

# #### To produce a simulated population structure for the model, for a camp with population size n ####
# ## With camp n lognormally distributed with mean = 6.886 & sd = .611
# # Well-mixed population with 5 classes
# rlnorm(n, 6.886, .611) %>% 
#   round() %>% 
#   lapply(function(x) {
#     x*classes_structure_mixed
#     }) %>% 
#   lapply(round_preserve_sum)
# # Shielded population with 7 classes
# rlnorm(n, 6.886, .611) %>% 
#   round() %>% 
#   lapply(function(x) {
#     x*classes_structure_shield
#     }) %>% 
#   lapply(round_preserve_sum)

#### Parameter estimates ####
# ## Fraction symptomatic (fracPtoI) (*not a class-specific parameter in final version of model*)
# # Proportion asymptomatic (.16) from meta analysis:
# # https://www.medrxiv.org/content/10.1101/2020.05.10.20097543v1
# 
# fracPtoI_structure <- c(rep(1-.2, 5), rep(1-.16, 5), rep(1-.12, 5)) %>% 
#   t() %>% 
#   as.data.frame()
# 
# names(fracPtoI_structure) <- c(paste0(names(age_structure), "_lowCI"), 
#                              names(age_structure), 
#                              paste0(names(age_structure), "_highCI"))

## Fraction of sympotatic cases requiring hospitalization (non-ICU, fracItoH)
# Data for children:
# https://pediatrics.aappublications.org/content/pediatrics/early/2020/03/16/peds.2020-0702.full.pdf
# Set proportion requiring hospitalization in age group 0-12 to proportion severe aged <11
# Data for adults:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7119513/
# Set proportion requiring hospitalization in age group 13-50 w/o comorbidities to proportion aged 19-64 w/o comorbitidies
# Set proportion requiring hospitalization in age group 13-50 w comorbidities to proportion aged 19-64 w comorbitidies
# Set proportion requiring hospitalization in age group over 50 w/o comorbidities to proportion aged 65+ w/o comorbitidies
# Set proportion requiring hospitalization in age group over 50 w comorbidities to proportion aged 65+ w comorbitidies

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
