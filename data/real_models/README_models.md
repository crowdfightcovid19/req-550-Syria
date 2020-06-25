## Description of the models and directory contents

* **null_model**
  * Description: 7 population classes, well-mixed (age1_orange = 0-12 in orange zone, age1_green = 0-12 in green zone, age2_no_comorbid_orange = 13-50 no comorbidities in orange zone, age2_no_comorbid_green = 13-50 no comorbidities in green zone, age2_comorbid_green = 13-50 with comorbidities in green zone, age3_no_comorbid_green = over 50 no comorbidities in green zone, age3_comorbid = over 50 with comorbidities in green zone). No intervention. Green and orange zones do not exist under no intervention but including them in the population structure makes it easier to directly translate the null model into models with interventions.
  * Directory contents: 
    * **classes_structure**- proportion of the population in each class (N_j/N)
    * **fracItoH_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require hospitalization, but not severe enough to require ICU admission in each class
    * **fracItoD_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require ICU admission in each class; in this setting these cases will all die
    * **classes_contacts**- average number of contacts of individuals in class i per day (cbar_i)
    * **Contacts_matrix_construction.R**- uses **classes_structure** and **classes_contacts** to compute the contact matrix (C_ij) for the null model as described [here](https://github.com/crowdfightcovid19/req-550-Syria/blob/master/manuscripts/DerivationOfR0_APG.pdf)
    * **contacts_structure**- the contact matrix (average number of contacts of an individual of class i with an individual of class j, C_ij)
    
* **model_1_1**
* Shielding with shielded population permitted to have visits from 2 family members per week
  * Description: Population divided into 2 zones, "orange" and "green". Population classes in the "green" zone, people aged 50+ and people aged 13-50 with comorbidities, are considered more vulnerable/higher risk than population classes in the "orange"" zone, people aged 13-50 without comorbidities and people aged 0-13, and will live in a separate "shielded" part of the camp. People aged 13-50 with comorbidities in the "orange" zone are permitted to bring some family members with them from the lower risk population classes, with the maximum capacity of the "green" zone being 20% of the camp's population. People in the "green" zone are permitted to meet 2 family members per week from the "orange" zone in a defined neutral zone- an open tent where all family members will be required to wear masks and keep 2 meters apart.  
  * 7 population classes, same as null model: (age1_orange = 0-12 in orange zone, age1_green = 0-12 in green zone, age2_no_comorbid_orange = 13-50 no comorbidities in orange zone, age2_no_comorbid_green = 13-50 no comorbidities in green zone, age2_comorbid_green = 13-50 with comorbidities in green zone, age3_no_comorbid_green = over 50 no comorbidities in green zone, age3_comorbid = over 50 with comorbidities in green zone).  
  * Directory contents: 
    * **classes_structure**- proportion of the population in each class (N_j/N)
    * **fracItoH_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require hospitalization, but not severe enough to require ICU admission in each class
    * **fracItoD_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require ICU admission in each class; in this setting these cases will all die
    * **classes_contacts**- average number of contacts of individuals in class i per day, under null model (cbar_i)
    * **Management_matrix_construction.R**- uses **classes_structure** and **classes_contacts** to compute **management_matrix**, **contacts_structure_null**, and **contacts_structure_intervention**
    * **management_matrix**- the proportional change in class i's contact rate with class j resulting from the intervention (m_ij)
    * **contacts_structure_null**- the contact matrix under the null model without the intervention (average number of contacts of an individual of class i with an individual of class j, C_ij)
    * **contacts_structure_intervention**- (C_ij_interv) the contact matrix resulting from the effect of the intervention, m_ij, on the contacts in the null model, C_ij. Computed by-  **(diag(as.vector(m_ij)) %*% diag(as.vector(C_ij)) %>% diag() %>% matrix(ncol = 7))**
    
* **model_1_2**
* Shielding with shielded population permitted to have visits from 10 family members per week
  * Description: Same as **model_1_1** except with visits from 10 family members per week permitted instead of 2. 
  * Population divided into 2 zones, "orange" and "green". Population classes in the "green" zone, people aged 50+ and people aged 13-50 with comorbidities, are considered more vulnerable/higher risk than population classes in the "orange"" zone, people aged 13-50 without comorbidities and people aged 0-13, and will live in a separate "shielded" part of the camp. People aged 13-50 with comorbidities in the "orange" zone are permitted to bring some family members with them from the lower risk population classes, with the maximum capacity of the "green" zone being 20% of the camp's population. People in the "green" zone are permitted to meet 10 family members per week from the "orange" zone in a defined neutral zone- an open tent where all family members will be required to wear masks and keep 2 meters apart.  
  * 7 population classes, same as null model/model 1.1: (age1_orange = 0-12 in orange zone, age1_green = 0-12 in green zone, age2_no_comorbid_orange = 13-50 no comorbidities in orange zone, age2_no_comorbid_green = 13-50 no comorbidities in green zone, age2_comorbid_green = 13-50 with comorbidities in green zone, age3_no_comorbid_green = over 50 no comorbidities in green zone, age3_comorbid = over 50 with comorbidities in green zone).  
  * Directory contents: 
    * **classes_structure**- proportion of the population in each class (N_j/N)
    * **fracItoH_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require hospitalization, but not severe enough to require ICU admission in each class
    * **fracItoD_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require ICU admission in each class; in this setting these cases will all die
    * **classes_contacts**- average number of contacts of individuals in class i per day, under null model (cbar_i)
    * **Management_matrix_construction.R**- uses **classes_structure** and **classes_contacts** to compute **management_matrix**, **contacts_structure_null**, and **contacts_structure_intervention**
    * **management_matrix**- the proportional change in class i's contact rate with class j resulting from the intervention (m_ij)
    * **contacts_structure_null**- the contact matrix under the null model without the intervention (average number of contacts of an individual of class i with an individual of class j, C_ij)
    * **contacts_structure_intervention**- (C_ij_interv) the contact matrix resulting from the effect of the intervention, m_ij, on the contacts in the null model, C_ij. Computed by-  **(diag(as.vector(m_ij)) %*% diag(as.vector(C_ij)) %>% diag() %>% matrix(ncol = 7))**
    
