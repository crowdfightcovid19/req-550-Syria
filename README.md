# req-550-Syria
Repository to host the code and results of request 550 coming from the Pax Syriana Foundation.

# Cite

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

