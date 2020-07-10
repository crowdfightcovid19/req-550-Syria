# ****************************************
# calculate_CFR.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu 
# date = 10th July, 2020
# description = Calculates CFR for post-processed results for experiments A & B.
#        Created tables of summary statistics and conducts pairwise t tests.
#        Input files = All files denoted "exp_A" or "exp_B1" in "Final_fraction_dead" and "Final_fraction_recovered" directories
#        Output files = "CFR_summarystats_allexperiments_A_B.csv", "CFR_summarystats_fateD_limitedIsocap.csv", "Isolation_effect_on_CFR_ttests.csv", "Shield_effect_on_CFR_ttests.csv"
# usage = Run in directory "data/real_models/results_post_processing".
#### Setup ####

setwd("data/real_models/results_post_processing")

library(tidyverse)
library(readr)
library(rstatix)
library(ggpubr)

### Write function to import files from directories & calculate CFR

get_CFR_data <- function(x) {
  dead_file <- paste0("Final_fraction_dead/", x, ".csv")
  recovered_file <- paste0("Final_fraction_recovered/", x, ".csv")
  
  dead <- read_csv(dead_file)[, -1]
  recovered <- read_csv(recovered_file)[, -1]
  
  combined_df <- cbind(dead, recovered[, 2]) %>% 
    mutate(CFR = Fraction_Dead/Fraction_Recovered)
  
  combined_df <- mutate(combined_df, Experiment = 
                          if_else(grepl("Limit0_", Model), "Experiment A", "Experiment B"), 
                        Structure = 
                          case_when(grepl("null", Model) ~ "null", 
                                    grepl("cont2", Model) ~ "shield 2 conts/week", 
                                    grepl("cont10", Model) ~ "shield 10 conts/week"), 
                        Isolation_cap_numeric = as.numeric(str_extract(Model, "(?<=Limit)\\d+")), 
                        Isolation_cap = paste0("isocap", Isolation_cap_numeric), 
                        Fate = case_when(grepl("FateD", Model) ~ "FateD", 
                                         grepl("FateR", Model) ~ "FateR"))
  
  combined_df <- mutate(combined_df, Model = paste(Experiment, Structure, Isolation_cap, Fate, 
                                                   sep = ", "))
  
  return(combined_df)
}

#### Import & analyze data ####

### Calculate CFR for all models in experiments A & B

CFR_data <- lapply(c("exp_A_fateD_varShieldStrategy", "exp_A_fateR_varShieldStrategy", "exp_B1_null_varLimit", 
                     "exp_B1_2conts_varLimit", "exp_B1_10conts_varLimit"), get_CFR_data) %>% 
  rbind_list()

CFR_data <- CFR_data[order(CFR_data$Isolation_cap_numeric), ]

# Calculate summary states

CFR_full_sumstats <- CFR_data %>% 
  group_by(Model) %>% 
  get_summary_stats(CFR, type = "mean_sd")

## Filter for models with Fate = D & isolation capacity <= 25

CFR_data_filtered <- dplyr::filter(CFR_data, Isolation_cap_numeric <= 25 & Fate == "FateD")

# Calculate summary stats

CFR_filtered_sumstats <- CFR_data_filtered %>% 
  group_by(Model) %>% 
  get_summary_stats(CFR, type = "mean_sd")

## Pairwise t-tests of effect of isolation capacity

CFR_iso_test <- CFR_data_filtered %>% 
  group_by(Structure) %>% 
  pairwise_t_test(CFR ~ Isolation_cap, p.adjust.method = "bonferroni")

## Pairwise t-tests of effect of shielding

CFR_shield_test <- CFR_data_filtered %>% 
  group_by(Isolation_cap) %>% 
  pairwise_t_test(CFR ~ Structure, p.adjust.method = "bonferroni")

#### Export data ####

write_csv(CFR_full_sumstats, "CFR_summarystats_allexperiments_A_B.csv")
write_csv(CFR_filtered_sumstats, "CFR_summarystats_fateD_limitedIsocap.csv")
write_csv(CFR_iso_test, "Isolation_effect_on_CFR_ttests.csv")
write_csv(CFR_shield_test, "Shield_effect_on_CFR_ttests.csv")
