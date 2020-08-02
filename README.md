# req-550-Syria
Repository to host the code of request 550 coming from the Pax Syriana Foundation.

### Participants

#### Modellers

* Eduard Campillo-Funollet, University of Sussex, UK. (e.campillo-funollet@sussex.ac.uk)
* Jennifer Villers, Princeton University (villers.jennifer@gmail.com)
* Jordan Klein, Princeton University (jdklein@princeton.edu)
* Judith Bouman, ETH-Zürich (judith.bouman@env.ethz.ch)
* Alberto Pascual-García, ETH-Zürich and crowdfight (alberto.pascual.garcia@gmail.com)

#### Pax Syriana Foundation

* Chamsy Sarkis, Chairman Pax Syriana Foundation (chamsy.sarkis@paxsyriana.com)
* Jean Jaques Py, IT Pax Syriana Foundation (jean-jacques.py@paxsyriana.com)

#### Public dissemination

* Megan Naidoo, University of Stellenbosch.	(megan.naidoo4266@gmail.com)
* Laure Gicquel, (logicquel@hotmail.com)
* Juan A. Garcia, French National Institute of Health and Medical Research. (jags4595@gmail.com)
* Om Chabra, (omchabra@gmail.com)

### Tools at your disposal

Please add here any URL address to other tools you may be using (e.g. Google docs). 

* _github_: Store code and articles to share. Please keep data and heavy documents stored elsewhere **TBD**.
* _slack_: Quick communication.
* _Google drive_:
     * Shared documents: [link](https://drive.google.com/drive/folders/1aIYpuSEaXgdNS8Z-7KTMhpNNWWzQqvg4)
* _Overleaf_: More detailed documentation of the methods and results.

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

