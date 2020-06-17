## Description of the models and directory contents

* **null_model**
  * Description: 5 population classes, well-mixed (age1 = 0-12, age2_no_comorbid = 13-50 no comorbidities, age2_comorbid = 13-50 with comorbidities, age3_no_comorbid = over 50 no comorbidities, age3_comorbid = over 50 with comorbidities). No intervention.
  * Directory contents: 
    * **classes_structure**- proportion of the population in each class (N_j/N)
    * **fracItoH_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require hospitalization, but not severe enough to require ICU admission in each class
    * **fracItoD_structure**- proportion of symptomatic cases who will have symptoms that are severe enough to require ICU admission in each class; in this setting these cases will all die
    * **classes_contacts**- average number of contacts of individuals in class i per day (cbar_i)
    * **Contacts_matrix_construction.R**- uses **classes_structure** and **classes_contacts** to compute the contact matrix (C_ij) for the null model as described [here](https://github.com/crowdfightcovid19/req-550-Syria/blob/master/manuscripts/DerivationOfR0_APG.pdf)
    * **contacts_structure**- the contact matrix (average number of contacts of an individual of class i with an individual of class j, C_ij)
    