## Description of the files

These files contain outputs from the scripts `Age_stucture_parameter_estimation.R` and `Theta_matrix_computation.R`

* **age_structure.csv**
    * 5 population classes: ages (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)

* **contact_matrix.csv**
    * 5 population classes: ages (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
    * Rows are the contact probabilities for each population class, each summing to 1
    * User can change [here](https://github.com/crowdfightcovid19/req-550-Syria/blob/master/src/Theta_matrix_computation.R)

* **fracItoD_structure.csv**
    * Fraction requiring ICU
    * 5 population classes: ages (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
    * Age & comorbidity dependent
    * No confidence intervals
    
* **fracPtoI_structure.csv**
    * Fraction symptomatic estimates
    * 5 population classes: ages (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
    * Not age nor comorbidity dependent
    * Confidence intervals

* **fracItoH_structure.csv**
    * Fraction requiring hospitalization but not ICU estimates
    * 5 population classes: ages (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
    * Age & comorbidity dependent
    * No confidence intervals

* **Theta_matrix.csv**
    * A 5x5 matrix where Theta = NC(N)^(-1), N is a diagonal matrix whose nonzero elements are the values in age_structure.csv, and C is contact_matrix.csv
    * This matrix is used for computing R0 as described [here](https://github.com/crowdfightcovid19/req-550-Syria/blob/master/manuscripts/DerivationOfR0_jordan.pdf)
    * 5 population classes: ages (0-12, 13-50 no comorbidities, 13-50 comorbidities, over 50 no comorbidities, over 50 comorbidities)
