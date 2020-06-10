# ****************************************
# Age_stucture_parameter_estimation.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 27th May 2020
# description = Generates a file with a simulated population for the model split up into classes 
#        based on age/comorbidity estimates from the entire idp population.
#        Generates files for parameter estimates for each population class: 
#        fraction symptomatic (f), fraction requiring non-ICU hospitalization (h), & fraction requiring ICU (g). 
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

age_structure <- data.frame(age[, 1]-sum(pop_str_NCDs[1, 6:9]), sum(pop_str_NCDs[1, 6:9]), 
                            age[, 2]-sum(pop_str_NCDs[2, 6:9]), sum(pop_str_NCDs[2, 6:9]), 
                            age[, 3]-sum(pop_str_NCDs[3, 6:9]), sum(pop_str_NCDs[3, 6:9])) %>% 
  round_preserve_sum()

names(age_structure) <- c("age1_no_comorbid", "age1_comorbid", "age2_no_comorbid", 
                          "age2_comorbid", "age3_no_comorbid", "age3_comorbid")

#### Parameter estimates ####
## Fraction symptomatic (f)
# Proportion asymptomatic (.16) from meta analysis:
# https://www.medrxiv.org/content/10.1101/2020.05.10.20097543v1

f_structure <- c(rep(1-.2, 6), rep(1-.16, 6), rep(1-.12, 6)) %>% 
  t() %>% 
  as.data.frame()

names(f_structure) <- c(paste0(names(age_structure), "_lowCI"), 
                             names(age_structure), 
                             paste0(names(age_structure), "_highCI"))

## Fraction of sympotatic cases requiring hospitalization (non-ICU, h)
# Data for children:
# https://www.cdc.gov/mmwr/volumes/69/wr/mm6914e4.htm?s_cid=mm6914e4_e&deliveryName=USCDC_921-DM25115#T1_down
# Set proportion requiring hospitalization in age group 0-12 to proportion aged <18
# Data for adults:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7119513/
# Set proportion requiring hospitalization in age group 13-50 w/o comorbidities to proportion aged 19-64 w/o comorbitidies
# Set proportion requiring hospitalization in age group 13-50 w comorbidities to proportion aged 19-64 w comorbitidies
# Set proportion requiring hospitalization in age group over 50 w/o comorbidities to proportion aged 65+ w/o comorbitidies
# Set proportion requiring hospitalization in age group over 50 w comorbidities to proportion aged 65+ w comorbitidies

h_structure <- c(rep(.18, 2), .067, .199, .183, .445) %>% 
  t() %>% 
  as.data.frame()

names(h_structure) <- names(age_structure)

## Fraction of cases requiring ICU (g)
# Data for children:
# https://www.cdc.gov/mmwr/volumes/69/wr/mm6914e4.htm?s_cid=mm6914e4_e&deliveryName=USCDC_921-DM25115#T1_down
# Set proportion requiring hospitalization in age group 0-12 to proportion aged <18
# Data for adults:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7119513/
# Set proportion requiring hospitalization in age group 13-50 w/o comorbidities to proportion aged 19-64 w/o comorbitidies
# Set proportion requiring hospitalization in age group 13-50 w comorbidities to proportion aged 19-64 w comorbitidies
# Set proportion requiring hospitalization in age group over 50 w/o comorbidities to proportion aged 65+ w/o comorbitidies

g_structure <- c(rep(.02, 2), .02, .094, .063, .222) %>% 
  t() %>% 
  as.data.frame()

names(g_structure) <- names(age_structure)

#### Export data ####

setwd(dirOut)
write_csv(age_structure, "age_structure.csv")
write_csv(f_structure, "f_structure.csv")
write_csv(h_structure, "h_structure.csv")
write_csv(g_structure, "g_structure.csv")
