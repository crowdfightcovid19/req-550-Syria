## Description of the files

These files contain outputs from the script `Age_stucture_parameter_estimation.R`

* **classes_structure_mixed**
    * 5 population classes, for well-mixed null model: (age1 = 0-12, age2_no_comorbid = 13-50 no comorbidities, age2_comorbid = 13-50 with comorbidities, age3_no_comorbid = over 50 no comorbidities, age3_comorbid = over 50 with comorbidities)

* **classes_structure_shield**
    * 7 population classes, for null model with shielded population structure and intervention models: (age1_orange = 0-12 in orange zone, age1_green = 0-12 in green zone, age2_no_comorbid_orange = 13-50 no comorbidities in orange zone, age2_no_comorbid_green = 13-50 no comorbidities in green zone, age2_comorbid_green = 13-50 with comorbidities in green zone, age3_no_comorbid_green = over 50 no comorbidities in green zone, age3_comorbid = over 50 with comorbidities in green zone)

* **fracItoD_structure_mixed**
    * Parameters g_i in the Main Text, which adjust the rates to obtain the correct proportion of cases requiring ICU. The actual proportions can be found in a file with the same name located in the folder `actual_frac_structures`.
    * 5 population classes, for well-mixed null model: (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
    * Age & comorbidity dependent
    * No confidence intervals
    
* **fracItoD_structure_shield**
    * Parameters g_i in the Main Text, which adjust the rates to obtain the correct proportion of cases requiring ICU. The actual proportions can be found in a file with the same name located in the folder `actual_frac_structures`.
    * 7 population classes, for null model with shielded population structure and intervention models: (age1_orange = 0-12 in orange zone, age1_green = 0-12 in green zone, age2_no_comorbid_orange = 13-50 no comorbidities in orange zone, age2_no_comorbid_green = 13-50 no comorbidities in green zone, age2_comorbid_green = 13-50 with comorbidities in green zone, age3_no_comorbid_green = over 50 no comorbidities in green zone, age3_comorbid = over 50 with comorbidities in green zone)
    * Age & comorbidity dependent
    * No confidence intervals
    * Files with the same name but with a different number, simply change the labels according to the interventions.

* **fracItoH_structure_mixed**
    * Parameters h_i in the Main Text, which adjust the rates to obtain the correct proportion of cases requiring hospitalization but not ICU. The actual proportions can be found in a file with the same name located in the folder `actual_frac_structures`.
    * 5 population classes, for well-mixed null model: (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
    * Age & comorbidity dependent
    * No confidence intervals

* **fracItoH_structure_shield**
    * Parameters h_i in the Main Text, which adjust the rates to obtain the correct proportion of cases requiring hospitalization but not ICU. The actual proportions can be found in a file with the same name located in the folder `actual_frac_structures`.
    * 7 population classes, for null model with shielded population structure and intervention models: (age1_orange = 0-12 in orange zone, age1_green = 0-12 in green zone, age2_no_comorbid_orange = 13-50 no comorbidities in orange zone, age2_no_comorbid_green = 13-50 no comorbidities in green zone, age2_comorbid_green = 13-50 with comorbidities in green zone, age3_no_comorbid_green = over 50 no comorbidities in green zone, age3_comorbid = over 50 with comorbidities in green zone)
    * Age & comorbidity dependent
    * No confidence intervals
    * Files with the same name but with a different number, simply change the labels according to the interventions.
    * Files with the same name but with a different number, simply change the labels according to the interventions.
