## Description of the models

These folders contain input and outputs for the script `SIR-Syria_structured.R`

* **healthy_vs_vulnerable**
    * Two population classes only, healthy vs. vulnerable. 
    * Mean field contact matrix

* **healthy_vs_vulnerableShielded**
    * Two population classes only, healthy vs. vulnerable. 
    * A "shielded" contact matrix in which the contacts between both populations are reduced to half the value of the previous model   

* **age3_gender2_com2**
    * Three ages considered, both genders split and comorbidities yes or no (12 levels)
    * Ages are roughly taken from the proportions found for the whole dataset
    * Parameters are arbitrary, but there is a reasonable hierarchy from young to elderly and health/vulnerable
* **age3_gender2_com2_FC**
    * Three ages considered, both genders split and comorbidities yes or no (12 levels)
    * Ages are roughly taken from the proportions found for the whole dataset
    * Parameters are arbitrary, but there is a reasonable hierarchy from young to elderly and health/vulnerable
    * Contacts are structured, in a way in which adult women only interact with few adult men (e.g. women partners) and age3 only interact with women (who play the role of carers)
