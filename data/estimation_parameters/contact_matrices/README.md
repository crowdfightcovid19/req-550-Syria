
## Contact matrices

Outputs from the script `Management_matrix_construction.R`

### Files found in this folder:

* `epsilon_matrix`: epsilon matrix generated for the different interventions
* `management_matrix`: management matrix generated for the different interventions (in the last doc this matrix is called m_ij and epsilon_ij * m_ij=management matrix but I wrote this script before that change unfortunately)
* `contacts_matrix`: contacts matrix. If it has the label `intervention` it is the matrix after the intervention was implemented (so already multiplied by epsilon and the management matrix) and it corresponds to the null model otherwise. Each scenario has its own null model matrix which corresponds to the matrix having the same number of classes than in the intervention considered, and hence they are labelled. These null matrices, however, are not used elsewhere except for the case `shieldpct20` when we estimate **document**. The null model will be considered otherwise the one with five classes well mixed.
* `heatmap`: Plots of the two contacts matrices with the same labels. Note that these matrices are **NOT** symmetric, the values in the cells represent the number of contacts that a class i (rows) has with class j (columns)


### Labels used in this folder:

* `null_mixed`: Null model with 5 classes
* `shield`: any of the shielded inteventions
    * `age3`: only elderly
    * `age2`: elderly + comorbid age2
    * `pct$Num`: elderly + comorbid age2 + adults and kids in proportion 60%/40% up to $Num% of total population ($Num=number).
    * `fam_vis$Num`: family visits allowed in the neutral zone ($Num=number)
