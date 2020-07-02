# ****************************************
# model_output_post_processing.R
# ****************************************
# author = Jordan Klein
# email = jdklein@princeton.edu
# date = 2nd July 2020
# description = Imports .dat files from output directories for different models in real_models folder 
#        (currently set to import from null_model_shield, model_1_1, and model_1_2). 
#        Generates tidy dataframes for key variables of interest from imported summary .dat files
#        (currently set to generate dataframes for total number of deaths and proportion dead 
#        from "$DeathTolls_$Model_$options.dat" files and maximum number of infected cases from 
#        "$MaxInfected_$Model_$options.dat" files). 
#        Generates tables of summary statistics, pairwise t-test ouputs, test of normality, 
#        and boxplots to compare models for selected variables of interest.
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

# Get directories

output_dirs <- lapply(c("null_model_shield", "model_1_1", "model_1_2"), get_output_directories) %>% unlist()

### Import output data files

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

# Import dat files for death tolls

death_toll <- import_dat_files(output_dirs, "^DeathToll")
names(death_toll) <- c(output_dirs)

# Import dat files for max infected

max_infected <- import_dat_files(output_dirs, "^MaxInfected")
names(max_infected) <- c(output_dirs)

### Generate tidy dataframes of key variables from models

## Total death toll

death_toll_total <- lapply(death_toll, rowSums) %>% 
  bind_cols() 

death_toll_total_tidy <- gather(death_toll_total, "model", "deaths")

## Proportion of total population dead

# Get total population in each model

total_pop <- names(death_toll_total) %>% 
  str_extract("(?<=PopSize)\\d+") %>% 
  as.numeric()

# Compute proportion dead

prop_total_dead <- mapply("/", death_toll_total, total_pop) %>% 
  as.data.frame()

prop_total_dead_tidy <- gather(prop_total_dead, "model", "prop_dead")

## Max infected in entire pop

max_infected_total <- lapply(max_infected, rowSums) %>% 
  bind_cols()

max_infected_total_tidy <- gather(max_infected_total, "model", "max_infected")

#### Data analysis ####

### Generate plots

# Total death toll

ggplot(death_toll_total_tidy, aes(model, deaths)) + geom_boxplot() + theme(axis.text.x = element_text(angle = 90))

# Proportion dead

ggplot(prop_total_dead_tidy, aes(model, prop_dead)) + geom_boxplot() + theme(axis.text.x = element_text(angle = 90))

# Max infected

ggplot(max_infected_total_tidy, aes(model, max_infected)) + geom_boxplot() + theme(axis.text.x = element_text(angle = 90))

### Statistical analysis of results

## Total death toll

# Summary stats

death_toll_sumstats <- death_toll_total_tidy %>% 
  group_by(model) %>% 
  get_summary_stats(deaths, type = "mean_sd")

# Pairwise t-tests

death_toll_ttest <- death_toll_total_tidy %>% 
  pairwise_t_test(deaths ~ model, p.adjust.method = "BH")

# See if normally distributed

fitdist(death_toll_total_tidy$deaths, "norm") %>% 
  plot()

descdist(death_toll_total_tidy$deaths)

## Proportion dead

# Summary stats

prop_dead_sumstats <- prop_total_dead_tidy %>% 
  group_by(model) %>% 
  get_summary_stats(prop_dead, type = "mean_sd")

# Pairwise t-tests

prop_dead_ttest <- prop_total_dead_tidy %>% 
  pairwise_t_test(prop_dead ~ model, p.adjust.method = "BH")

# See if normally distributed

fitdist(prop_total_dead_tidy$prop_dead, "norm") %>% 
  plot()

descdist(prop_total_dead_tidy$prop_dead)

## Max infected

# Summary stats

max_infected_sumstats <- max_infected_total_tidy %>% 
  group_by(model) %>% 
  get_summary_stats(max_infected, type = "mean_sd")

# Pairwise t-tests

max_infected_ttest <- max_infected_total_tidy %>% 
  pairwise_t_test(max_infected ~ model, p.adjust.method = "BH")

# See if normally distributed

fitdist(max_infected_total_tidy$max_infected, "norm") %>% 
  plot()

descdist(max_infected_total_tidy$max_infected)

