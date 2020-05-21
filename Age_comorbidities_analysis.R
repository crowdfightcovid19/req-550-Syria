#### Load packages & data ####

library(readxl)
library(tidyverse)

camps <- read_excel("idps_in_camps_syria_april_2020.xlsx")

#### Clean data ####

# Select relevant variables

camps_cl <- select(camps, Governorate:Camp, 
                   `Total number of individuals living in the camp`:
                     `Females above 50 years of age`, 
                   Diabetes:`Chronic kidney failure`)

colnames(camps_cl)[7] <- c("Total_pop")

# Population by age group for both sexes

age_groups <- c("0 to 6", "6 to 12 m", "1 to 2", "3 to 5", "6 to 12 y", "13 to 17", "18 to 50", "above 50")

ages_both_sexes <- lapply(age_groups, function(x) {
  select(camps_cl, contains(x)) %>% 
    rowSums()
}) %>% 
  cbind.data.frame()

names(ages_both_sexes) <- c("total_0_6_months", "total_6_12_months", "total_1_2", "total_3_5", "total_6_12", 
                            "total_13_17", "total_18_50", "total_over50")

# Add total pop counts back to dataframe

camps_cl <- cbind(select(camps_cl, Governorate:`Females above 50 years of age`), ages_both_sexes, 
                   select(camps_cl, Diabetes:`Chronic kidney failure`))

#### Population structure @ different administrative levels ####

## Camp level

camps_prop <- cbind(select(camps_cl, matches("Total number of males"), matches("Total number of females"), 
             matches("total_0_6_months"):matches("Chronic kidney failure"))/camps_cl$Total_pop, 
      select(camps_cl, matches("Males from 0 to 6 months of age"):matches("Males above 50 years of age"))/camps_cl$`Total number of males`, 
      select(camps_cl, matches("Females from 0 to 6 months of age"):matches("Females above 50 years of age"))/camps_cl$`Total number of females`)

names(camps_prop) <- paste("Prop", names(camps_prop), sep = "_")

camps_pop <- cbind(camps_cl, camps_prop)

## Community level

community_pop <- aggregate(camps_cl[, 7:dim(camps_cl)[2]], 
          by = list(camps_cl$Governorate, camps_cl$District, 
                    camps_cl$`Sub-district`, camps_cl$Cluster, camps_cl$Community), FUN = sum)

names(community_pop)[1:5] <- names(camps_cl)[1:5]

community_prop <- cbind(select(community_pop, matches("Total number of males"), matches("Total number of females"), 
                           matches("total_0_6_months"):matches("Chronic kidney failure"))/community_pop$Total_pop, 
                    select(community_pop, matches("Males from 0 to 6 months of age"):matches("Males above 50 years of age"))/community_pop$`Total number of males`, 
                    select(community_pop, matches("Females from 0 to 6 months of age"):matches("Females above 50 years of age"))/community_pop$`Total number of females`)

names(community_prop) <- paste("Prop", names(community_prop), sep = "_")

community_pop <- cbind(community_pop, community_prop)

## Cluster level

cluster_pop <- aggregate(camps_cl[, 7:dim(camps_cl)[2]], 
                           by = list(camps_cl$Governorate, camps_cl$District, 
                                     camps_cl$`Sub-district`, camps_cl$Cluster), FUN = sum)

names(cluster_pop)[1:4] <- names(camps_cl)[1:4]

cluster_prop <- cbind(select(cluster_pop, matches("Total number of males"), matches("Total number of females"), 
                               matches("total_0_6_months"):matches("Chronic kidney failure"))/cluster_pop$Total_pop, 
                        select(cluster_pop, matches("Males from 0 to 6 months of age"):matches("Males above 50 years of age"))/cluster_pop$`Total number of males`, 
                        select(cluster_pop, matches("Females from 0 to 6 months of age"):matches("Females above 50 years of age"))/cluster_pop$`Total number of females`)

names(cluster_prop) <- paste("Prop", names(cluster_prop), sep = "_")

cluster_pop <- cbind(cluster_pop, cluster_prop)

## District/Sub-district level

sub_district_pop <- aggregate(camps_cl[, 7:dim(camps_cl)[2]], 
                         by = list(camps_cl$Governorate, camps_cl$District, 
                                   camps_cl$`Sub-district`), FUN = sum)

names(sub_district_pop)[1:3] <- names(camps_cl)[1:3]

sub_district_prop <- cbind(select(sub_district_pop, matches("Total number of males"), matches("Total number of females"), 
                             matches("total_0_6_months"):matches("Chronic kidney failure"))/sub_district_pop$Total_pop, 
                      select(sub_district_pop, matches("Males from 0 to 6 months of age"):matches("Males above 50 years of age"))/sub_district_pop$`Total number of males`, 
                      select(sub_district_pop, matches("Females from 0 to 6 months of age"):matches("Females above 50 years of age"))/sub_district_pop$`Total number of females`)

names(sub_district_prop) <- paste("Prop", names(sub_district_prop), sep = "_")

sub_district_pop <- cbind(sub_district_pop, sub_district_prop)

## Governorate level

governorate_pop <- aggregate(camps_cl[, 7:dim(camps_cl)[2]], 
                              by = list(camps_cl$Governorate), FUN = sum)

names(governorate_pop)[1] <- names(camps_cl)[1]

governorate_prop <- cbind(select(governorate_pop, matches("Total number of males"), matches("Total number of females"), 
                                  matches("total_0_6_months"):matches("Chronic kidney failure"))/governorate_pop$Total_pop, 
                           select(governorate_pop, matches("Males from 0 to 6 months of age"):matches("Males above 50 years of age"))/governorate_pop$`Total number of males`, 
                           select(governorate_pop, matches("Females from 0 to 6 months of age"):matches("Females above 50 years of age"))/governorate_pop$`Total number of females`)

names(governorate_prop) <- paste("Prop", names(governorate_prop), sep = "_")

governorate_pop <- cbind(governorate_pop, governorate_prop)

## All camps

all_pop <- camps_cl[, 7:dim(camps_cl)[2]] %>% 
  colSums() %>% 
  t() %>% 
  as_tibble()

all_prop <- cbind(select(all_pop, matches("Total number of males"), matches("Total number of females"), 
                                 matches("total_0_6_months"):matches("Chronic kidney failure"))/all_pop$Total_pop, 
                          select(all_pop, matches("Males from 0 to 6 months of age"):matches("Males above 50 years of age"))/all_pop$`Total number of males`, 
                          select(all_pop, matches("Females from 0 to 6 months of age"):matches("Females above 50 years of age"))/all_pop$`Total number of females`)

names(all_prop) <- paste("Prop", names(all_prop), sep = "_")

all_pop <- cbind(all_pop, all_prop)

#### Export data ####

write_csv(camps_pop, "Age structure and NCD prevalence aggregated data/camp_level.csv")
write_csv(community_pop, "Age structure and NCD prevalence aggregated data/community_level.csv")
write_csv(cluster_pop, "Age structure and NCD prevalence aggregated data/cluster_level.csv")
write_csv(sub_district_pop, "Age structure and NCD prevalence aggregated data/district_level.csv")
write_csv(governorate_pop, "Age structure and NCD prevalence aggregated data/governorate_level.csv")
write_csv(all_pop, "Age structure and NCD prevalence aggregated data/entire_population.csv")

