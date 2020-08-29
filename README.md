# req-550-Syria
This repository hosts the code and results of crowdfightCOVID-19 request 550 coming from the Pax Syriana Foundation.

## Cite

If you use the code or results of this repository, please cite:

Pascual-García, A., Klein, J., Villers, J., Campillo-Funollet, E. and Sarkis, C. Empowering the crowd: Feasible strategies to minimize the spread of COVID-19 in high-density informal settlements. (2020) medRxiv, [doi: ]()


### Participants

#### Modellers

* Eduard Campillo-Funollet, University of Sussex, UK. 
* Jennifer Villers, Princeton University 
* Jordan Klein, Princeton University 
* Judith Bouman, ETH-Zürich 
* Alberto Pascual-García, ETH-Zürich and Board of Crowdfight 

#### Pax Syriana Foundation

* Chamsy Sarkis, Chairman Pax Syriana Foundation 
* Jean Jaques Py, IT Pax Syriana Foundation 

#### Public dissemination

* Megan Naidoo, University of Stellenbosch.	
* Juan A. Garcia, French National Institute of Health and Medical Research.
* Om Chabra.
* Cynthia A. Shelton.

### Contents

**File conventions**:
* Please avoid the use of blanks or special characters in ALL filenames. The safest separator is "_".

**Contents of the folders**:

* `docs`: Documents related to the model (e.g. documentation).
    * `papers`: Modelling-related scientific papers, it would be better looking for an external folder.
* `manuscripts`: For the moment  there is just a bib file. We may consider working in Overleaf.
* `src`: Source files. Create a directory for your script if a local environment must be loaded
* `bin`: Binary files
* `data`: Data used for the study
    * `age_structure_and_NCDprevalence`: Split of the table `idps_in_camps_syria_april_2020.xlsx` into age structure and administrative levels.


### Scripts

* `Age_comorbidities_analysis.R`:  The script splits the table `idps_in_camps_syria_april_2020.xlsx` into age structure and administrative levels.
*  `SimpleSIR.R`: Minimal SIR model
*  `SIR-Syria.R`: Minimal SIR model with some Syrian parameters.
*  `SIR-Syria_structured.R`: 
    * _Description_: SEAIRQD model including the possibility of defining population classes. The transition probabilities from one compartment to another depend on features of the population that the user may want to define, for instance related to age, sex, comorbidities of the individuals, roles like "carers" or "shielded". These are named population "classes" in the script.
    * _Usage_: Usage, input and output files are described in the header of the file.

#### Figures and statistics
All the scripts in this section run from their current folder. More details in the header of the file.
* `boxplots/generate_table_results.R`: compiles a tidy table of all the simulations.
* `boxplots/extend_table_results.R`: extends the tidy table with derived variables (e.g CFR).
* `boxplots/panel_plot_Fig2.R`: Generates Fig. 2 of the manuscript. Requires the tidy table.
* `boxplots/panel_plot_Fig3.R`: Generates Fig. 3 of the manuscript. Requires the tidy table.
* `boxplots/supp_figures.R`: Generates the figures for the supplementary material. Requires the tidy table.
* `boxplots/safety_age_groups.R`: Generates the Supplementary Figure 8 (safety zone and age groups). 
* `stats/all_stats.R`: Generates a table with basic tests for the results. 
* `stats/posthoc.R`: Runs a series of posthoc tests for particular questions about the results.
