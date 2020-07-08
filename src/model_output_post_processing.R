# ****************************************
# model_output_post_processing.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 2nd July 2020
# description = Imports .dat files from output directories for different models in real_models folder 
#        Generates tidy dataframes for key variables of interest from imported summary .dat files. 
#        Exports results to directory "data/real_models/results_post_processing"
#        Exports results for the following variables to the denoted subdirectories:
#         1. Fraction of final total population dead- "Final_fraction_dead"
#         2. Fraction of final total population recovered- "Final_fraction_recovered"
#         3. Time to peak number of infections in age3 with comorbidities- "Time_to_peak_infections_age3_comorbid"
#         4. Time to steady state of susceptibles, maximum out of all pop classes- "Time_to_steady_state"
#       **Currently performs post-processing for experiments A, B, and C
# usage = script should be run within the folder "data/real_models". 
#### Setup ####

setwd("data/real_models")

library(readr)
library(tidyverse)
library(rstatix)
library(ggpubr)
library(fitdistrplus)

#### Data wrangling ####

### Get model output directories

# Function to get output directories

get_output_directories <- function(directory) {
  list.dirs(directory) %>% 
    .[grepl("/", .) & !grepl("figures", .)]
}

## Get directories
#*List names of directories to pull from*

# Experiment A

exp_A_fateD <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("IsolateNO", .) & grepl("FateD", .)]

exp_A_fateR <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("IsolateNO", .) & grepl("FateR", .)]

# Experiment B

exp_B_null <- get_output_directories("null_model_mixed") %>%
  .[grepl("IsolateYES", .)]
exp_B_2conts <- get_output_directories("shield_cont2_age3_age2_20") %>%
  .[grepl("IsolateYES", .)]
exp_B_10conts <- get_output_directories("shield_cont10_age3_age2_20") %>%
  .[grepl("IsolateYES", .)]

exp_b_isocap10 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit10_", .)]
exp_b_isocap25 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit25_", .)]
exp_b_isocap50 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit50_", .)]
exp_b_isocap100 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit100_", .)]
exp_b_isocap250 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit250_", .)]
exp_b_isocap500 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit500_", .)]
exp_b_isocap2000 <- lapply(c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20"), get_output_directories) %>% unlist() %>% 
  .[grepl("Limit2000_", .)]

# Experiment C

exp_C <- lapply(c("shield_cont2_age3_age2_20", "shield_cont2_age3_age2_25", "shield_cont2_age3_age2_30", "shield_cont2_age3_age2", "shield_cont2_age3"), 
                get_output_directories) %>% unlist() %>% 
  .[grepl("IsolateNO", .)& grepl("FateD", .)]

## List of all experiments

exp_list <- list(exp_A_fateD, exp_A_fateR, 
                 exp_B_null, exp_B_2conts, exp_B_10conts, 
                 exp_b_isocap10, exp_b_isocap25, exp_b_isocap50, exp_b_isocap100, exp_b_isocap250, exp_b_isocap500, exp_b_isocap2000, 
                 exp_C)
names(exp_list) <- c("exp_A_fateD", "exp_A_fateR", 
                "exp_B_null", "exp_B_2conts", "exp_B_10conts", 
                "exp_b_isocap10", "exp_b_isocap25", "exp_b_isocap50", "exp_b_isocap100", "exp_b_isocap250", "exp_b_isocap500", "exp_b_isocap2000",
                "exp_C")

### Import output data files & generate tidy dataframes of key variables from models

# Write function to import dat files

import_dat_files <- function(directories, variable) {
  list.files(directories, pattern = ".dat") %>% 
    .[grepl(variable, .)] %>% 
    paste0(directories, "/", .) %>% 
    file.path() %>% 
    lapply(function(path) {
      read_delim(path, delim = ",")[, -1]
    })
}

### Fraction of total population dead

death_toll <- lapply(exp_list, function(x) {
  data <- import_dat_files(x, "^NumFinalDeaths")
  names(data) <- c(x)
  
  data_total <- lapply(data, rowSums) %>% 
    bind_cols()
  
  data_tidy <- gather(data_total, "Model", "Fraction_Dead")
  
  data_tidy <- mutate(data_tidy, Fraction_Dead = Fraction_Dead/2000)
  
  return(data_tidy)
})

### Time to peak number of infections (elderly comorbid)

time_peak_infected <- lapply(exp_list, function(x) {
  data <- import_dat_files(x, "^TimePeakInfected")
  names(data) <- c(x)
  
  data_age3c <- sapply(data, function(x) {
    x[, grep("age3_comorbid", names(x))]
  }) %>% 
    bind_cols()
  
  data_tidy <- gather(data_age3c, "Model", "Time_peak_infected")
  
  return(data_tidy)
})

### Time to steady state susceptibles (last population class in each model to reach)

time_steady_s <- lapply(exp_list, function(x) {
  data <- import_dat_files(x, "^TimeS")
  names(data) <- c(x)
  
  data_max_t <- lapply(data, function(x) {
      apply(x, 1, max)
    }) %>% 
    bind_cols()
  
  data_tidy <- gather(data_max_t, "Model", "Time_to_steady_state")
  
  return(data_tidy)
})

### Fraction of total population recovered

final_recover <- lapply(exp_list, function(x) {
  data <- import_dat_files(x, "^NumFinalRecovered")
  names(data) <- c(x)
  
  data_total <- lapply(data, rowSums) %>% 
    bind_cols()
  
  data_tidy <- gather(data_total, "Model", "Fraction_Recovered")
  
  data_tidy <- mutate(data_tidy, Fraction_Recovered = Fraction_Recovered/2000)
  
  return(data_tidy)
})

#### Export files ####

setwd("results_post_processing")

mapply(write.csv, death_toll, file=paste0("Final_fraction_dead/", names(death_toll), ".csv"))
mapply(write.csv, final_recover, file=paste0("Final_fraction_recovered/", names(final_recover), ".csv"))
mapply(write.csv, time_peak_infected, file=paste0("Time_to_peak_infections_age3_comorbid/", names(time_peak_infected), ".csv"))
mapply(write.csv, time_steady_s, file=paste0("Time_to_steady_state/", names(time_steady_s), ".csv"))
