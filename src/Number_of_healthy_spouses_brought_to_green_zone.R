# *************************************************
# Number_of_healthy_spouses_brought_to_green_zone.R
# *************************************************


## Demographic data from idps_in_camps_syria_april_2020

Men_50plus <- 0.029732089
Women_50plus <- 0.03286583
Men_13_49 <- 0.250443191
Women_13_49 <- 0.277147952
Elderly <- 0.0593                                 # age_structure (https://github.com/crowdfightcovid19/req-550-Syria/blob/master/data/estimation_parameters/class_structured_data/classes_structure_mixed)
Adults_13_49_with_comorbidities <- 0.0626         # age_structure (https://github.com/crowdfightcovid19/req-550-Syria/blob/master/data/estimation_parameters/class_structured_data/classes_structure_mixed)



## Probabilities of having a comorbidity, and of being widowed or single by age group

Proba_Widowed_if_woman_50plus <- 0.31              #https://erf.org.eg/wp-content/uploads/2018/05/WP-1187_Final.pdf
Proba_Single_if_woman_35_49 <- 0.2                 #https://erf.org.eg/wp-content/uploads/2018/05/WP-1187_Final.pdf
Proba_Widowed_if_man_50plus <- 0                   #https://erf.org.eg/wp-content/uploads/2018/05/WP-1187_Final.pdf
Proba_Single_if_man_35_49 <- 0                     #https://erf.org.eg/wp-content/uploads/2018/05/WP-1187_Final.pdf
Proba_comorbidities_if_aged_13_49 <- 0.1173163     # age_structure (https://github.com/crowdfightcovid19/req-550-Syria/blob/master/data/estimation_parameters/class_structured_data/classes_structure_mixed)



## Calculating proportion of population that are women aged 50+ (either widowed or married with a man aged 50+)
# Because men are on average 5 years older than their wife (#https://erf.org.eg/wp-content/uploads/2018/05/WP-1187_Final.pdf),
# we assumed that women aged 50+ can only be married to men aged 50+ 

Widowed_Women_50plus <- Women_50plus * Proba_Widowed_if_woman_50plus        # widowed
Married_Women_50plus <- Women_50plus - Widowed_Women_50plus                 # married with a man aged 50+



## Calculating proportion of population that are men aged 50+ (married with a woman aged either 50+ or 13-49)

Men_50plus_married_to_a_50plus_woman <- Married_Women_50plus                # married with a woman aged 50+
Men_50plus_married_to_a_13_49_woman <- Men_50plus - Married_Women_50plus    # married with a woman aged 13-49

# Calculating proportion of population that are men aged 50+ married with a woman aged 13-49 with comorbidities (already in the green zone)
Men_50plus_married_to_a_13_49_COM_woman <- Men_50plus_married_to_a_13_49_woman * Proba_comorbidities_if_ages_13_49 

# Calculating proportion of population that are women aged 13-49 without comorbidities brought from the orange zone by a 50+ spouse
Men_50plus_married_to_a_13_49_healthy_woman <- Men_50plus_married_to_a_13_49_woman - Men_50plus_married_to_a_13_49_COM_woman   



## Calculating proportion of population that are women aged 13_49 with comorbidities that are single or married 

COM_Women_13_49 <- Women_13_49 * Proba_comorbidities_if_ages_13_49        
Single_COM_Women_13_49 <- COM_Women_13_49 * Proba_Single_if_woman_35_49     # single
Married_COM_Women_13_49 <- COM_Women_13_49 - Single_COM_Women_13_49         # married

# Calculating proportion of population that are women aged 13_49 with comorbidities that are married to a 50+ man (already in the green zone)
COM_Women_13_49_married_to_man_50plus <- Men_50plus_married_to_a_13_49_COM_woman

# Calculating proportion of population that are women aged 13_49 with comorbidities that are married to a 13-49 man
COM_Women_13_49_married_to_man_13_49 <- Married_COM_Women_13_49 - COM_Women_13_49_married_to_man_50plus

# Calculating proportion of population that are women aged 13_49 with comorbidities that are married to a 13-49 man with comorbidities (already in the green zone)
COM_Women_13_49_married_to_COM_man_13_49 <- COM_Women_13_49_married_to_man_13_49 * Proba_comorbidities_if_ages_13_49

#Calculating proportion of population that are men aged 13-49 without comorbidities brought from the orange zone by a comorbid spouse aged 13-49
COM_Women_13_49_married_to_healthy_man_13_49 <- COM_Women_13_49_married_to_man_13_49 - COM_Women_13_49_married_to_COM_man_13_49



## Calculating proportion of population that are men aged 13-49 with comorbidities that are married to a 13-49 woman 

COM_Men_13_49 <- Men_13_49 * Proba_comorbidities_if_ages_13_49

# Calculating proportion of population that are men aged 13-49 with comorbidities that are married to a 13-49 woman with comorbidities (already in the green zone)
COM_Men_13_49_married_to_COM_woman_13_49 <- COM_Women_13_49_married_to_COM_man_13_49

# Calculating proportion of population that are women aged 13-49 without comorbidities brought from the orange zone by a comorbid spouse aged 13-49
COM_Men_13_49_married_to_healthy_woman_13_49 <- COM_Men_13_49 - COM_Men_13_49_married_to_COM_woman_13_49



## Calculating proportion of population that are healthy people aged 13-49 and are brought to the green zone by a 50+ spouse or a comorbid spouse aged 13-49

Total_healthy_spouses_brought_to_green_zone <- COM_Men_13_49_married_to_healthy_woman_13_49 + COM_Women_13_49_married_to_healthy_man_13_49 + Men_50plus_married_to_a_13_49_healthy_woman


## Calculating proportion of adult population that would live in the green zone

Total_adults_green_zone <- Total_healthy_spouses_brought_to_green_zone + Elderly + Adults_13_49_with_comorbidities 
