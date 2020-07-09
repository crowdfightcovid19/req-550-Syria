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
#       **Currently performs post-processing for experiments A, B, and C**
# usage = script should be run within the folder "data/real_models". 
#### Setup ####

setwd("data/real_models")

library(readr)
library(tidyverse)
library(miscset)

##*List names of directories to pull from & character strings to match subdirectories*##

## Experiment A (fate R/D constant, vary shielding strategy)

exp_A_dirs <- c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20")

# Fate D (simulations 1, 3, 5)

exp_A_fateD_char_match <- c("IsolateNO", "FateD")

# Fate R (simulations 2, 4, 6)

exp_A_fateR_char_match <- c("IsolateNO", "FateR")

## Experiment B.1 (shielding strategy constant, vary isolation capacity)

exp_B1_char_match <- c("IsolateYES")

# Null Mixed pop structure (simulations 7-13)

exp_B1_null_dirs <- c("null_model_mixed")

# Shielding w 2 contacts per week (simulations 14-20)

exp_B1_2conts_dirs <- c("shield_cont2_age3_age2_20")

# Shielding w 10 contacts per week (simulations 21-27)

exp_B1_10conts_dirs <- c("shield_cont10_age3_age2_20")

## Experiment B.2 (isolation capacity constant, vary shielding strategy)

exp_B2_dirs <- c("null_model_mixed", "shield_cont10_age3_age2_20", "shield_cont2_age3_age2_20")

# Isolation capacity = 10 (simulations 7, 14, 21)

exp_B2_Limit10_char_match <- c("Limit10_")

# Isolation capacity = 25 (simulations 8, 15, 22)

exp_B2_Limit25_char_match <- c("Limit25_")

# Isolation capacity = 50 (simulations 9, 16, 23)

exp_B2_Limit50_char_match <- c("Limit50_")

# Isolation capacity = 100 (simulations 10, 17, 24)

exp_B2_Limit100_char_match <- c("Limit100_")

# Isolation capacity = 250 (simulations 11, 18, 25)

exp_B2_Limit250_char_match <- c("Limit250_")

# Isolation capacity = 500 (simulations 12, 19, 26)

exp_B2_Limit500_char_match <- c("Limit500_")

# Isolation capacity = 2000 (simulations 13, 20, 27)

exp_B2_Limit2000_char_match <- c("Limit2000_")

## Experiment C (vary percent of population shielded, simulations 28-32)

exp_C_dirs <- c("shield_cont2_age3_age2_20", "shield_cont2_age3_age2_25", "shield_cont2_age3_age2_30", "shield_cont2_age3_age2", "shield_cont2_age3")

exp_C_char_match <- c("IsolateNO", "FateD")

#### Data wrangling ####

### Get model output directories

# Function to get output directories

get_output_directories <- function(directory) {
  list.dirs(directory) %>% 
    .[grepl("/", .) & !grepl("figures", .)]
}

# Function to get character vector of output directories

get_dir_char <- function(dir_names, subdir_char_match) {
  lapply(dir_names, get_output_directories) %>% unlist() %>% 
    .[mgrepl(subdir_char_match, .)]
}

## Get directories

# Experiment A

exp_A_fateD_varShieldStrategy <- get_dir_char(exp_A_dirs, exp_A_fateD_char_match)

exp_A_fateR_varShieldStrategy <- get_dir_char(exp_A_dirs, exp_A_fateR_char_match)

# Experiment B.1

exp_B1_null_varLimit <- get_dir_char(exp_B1_null_dirs, exp_B1_char_match)
exp_B1_2conts_varLimit <- get_dir_char(exp_B1_2conts_dirs, exp_B1_char_match)
exp_B1_10conts_varLimit <- get_dir_char(exp_B1_10conts_dirs, exp_B1_char_match)

# Experiment B.2

exp_B2_Limit10_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit10_char_match)
exp_B2_Limit25_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit25_char_match)
exp_B2_Limit50_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit50_char_match)
exp_B2_Limit100_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit100_char_match)
exp_B2_Limit250_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit250_char_match)
exp_B2_Limit500_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit500_char_match)
exp_B2_Limit2000_varShieldStrategy <- get_dir_char(exp_B2_dirs, exp_B2_Limit2000_char_match)

# Experiment C

exp_C_varPercentShielded <- get_dir_char(exp_C_dirs, exp_C_char_match)

## List of all experiments

exp_list <- list(exp_A_fateD_varShieldStrategy, exp_A_fateR_varShieldStrategy, 
                 exp_B1_null_varLimit, exp_B1_2conts_varLimit, exp_B1_10conts_varLimit, 
                 exp_B2_Limit10_varShieldStrategy, exp_B2_Limit25_varShieldStrategy, exp_B2_Limit50_varShieldStrategy, 
                 exp_B2_Limit100_varShieldStrategy, exp_B2_Limit250_varShieldStrategy, exp_B2_Limit500_varShieldStrategy, exp_B2_Limit2000_varShieldStrategy, 
                 exp_C_varPercentShielded)

names(exp_list) <- c("exp_A_fateD_varShieldStrategy", "exp_A_fateR_varShieldStrategy", 
                     "exp_B1_null_varLimit", "exp_B1_2conts_varLimit", "exp_B1_10conts_varLimit", 
                     "exp_B2_Limit10_varShieldStrategy", "exp_B2_Limit25_varShieldStrategy", "exp_B2_Limit50_varShieldStrategy", 
                     "exp_B2_Limit100_varShieldStrategy", "exp_B2_Limit250_varShieldStrategy", "exp_B2_Limit500_varShieldStrategy", "exp_B2_Limit2000_varShieldStrategy", 
                     "exp_C_varPercentShielded")

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
