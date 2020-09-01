# README 

This repository contains the code and results of the article: 

 
>Empowering the crowd: Feasible strategies to minimize the spread of COVID-19 in high-density informal settlements (2020)
Alberto Pascual-García, Jordan Klein, Jennifer Villers, Eduard Campillo-Funollet, Chamsy Sarkis
_medRxiv_ 2020.08.26.20181990; doi: https://doi.org/10.1101/2020.08.26.20181990 

Which is the **crowdfightCOVID19** request number 550,  from the **Pax Syriana Foundation.**

### Participants

All participants in this request are volunteers.

#### Modellers

* Eduard Campillo-Funollet, University of Sussex, UK. 
* Jennifer Villers, Princeton University 
* Jordan Klein, Princeton University 
* Judith Bouman, ETH-Zürich 
* Alberto Pascual-García, ETH-Zürich and crowdfight 

#### Pax Syriana Foundation

* Chamsy Sarkis, Chairman Pax Syriana Foundation 
* Jean Jaques Py, IT Pax Syriana Foundation

#### Public dissemination

* Megan Naidoo, University of Stellenbosch.
* Juan A. Garcia, French National Institute of Health and Medical Research.
* Salma Amzil, designer, Canada.
* Om Chabra, assistance edition, USA.
* Cynthia A. Shelton, designer, USA.


### Contents

**Contents of the folders**:

* `docs`: Documents related with this research.
* `manuscripts`: Theoretical developments and final manuscripts.
* `src`: Source code. Most of the code was written in R, so the code is directly executable.
* `data`: Input and output data of the study.

### Data

 * `real_models`: Directory with all simulations presented in the model and post-processing results. See README file in that directory for further details. 
  * `estimation_parameters`: This folder contains estimations of the parameters of the model. Particularly relevant to note that the dynamical model contains in the code most of the parameters that should be generated from probability distributions, but then it requires to read from an input file a vector describing the proportion of individuals that each population class represent in the whole population, and the matrix of contacts. These files are located in this directory, and symbolic links are created to the appropriate file in each case (see section `code` below for more details).
 * `class_structured_data`: Fraction of each population class and other class-dependent parameters.
 * `contact_matrices`: Contacts matrices generated for the different interventions simulated.
* `figures_prob_distros`: Probability distributions of the different parameters (used and investigated).
* `age_structure_and_NCDprevalence`: Split of the table `idps_in_camps_syria_april_2020.xlsx` into age structure and administrative levels.
* `fake_models`: Directory where tests were performed for a preliminary version of the code. See Readme file.
    

### Scripts

The scripts are divided in three types: i) those required to specify the model (e.g. estimation of parameters), ii) the dynamical model, iii) post-processing scripts. The names of some scripts are self-contain, see header of scripts for further descriptions.

#### Specification of the model

* `Age_structure_parameter_estimation.R`
* `Age_comorbidities_analysis.R`:  The script splits the table `idps_in_camps_syria_april_2020.xlsx` into age structure and administrative levels.
* `estimation_shielded_population_fraction.R`
* `estimation_tau_from_modelParameters.R`: Computation of the infectivity parameter from the NGM and R0. Requires `estimation_R0_function.R`.
* `estimation_distribution_from_quantiles.R`: Script to estimate specific parameters of a known probability distribution when quantiles are provided.
* `Management_matrix_construction.R`: Estimates how the contact matrix would be affected when an intervention is implemented (via the management matrix)

#### Dynamical model

There are some scripts from previous versions of the model:

*  `SimpleSIR.R`: Minimal SIR model
*  `SIR-Syria.R`: Minimal SIR model with some Syrian parameters.
*  `SIR-Syria_structured.R`: 
    * _Description_: SEAIRQD model including the possibility of defining population classes. The transition probabilities from one compartment to another depend on features of the population that the user may want to define, for instance related to age, sex, comorbidities of the individuals, roles like "carers" or "shielded". These are named population "classes" in the script.

The final model is located in the folder `SEPAIHRD`, and contains among other scripts:

* `launch_SEPAIHRD-Syria_structured.R`: Script to launch one simulation (which runs N realizations of teh model) for specified parameters.
* `launch_multiple_SEPAIHRD-Syria_structured.R`: Script to launch a set of simulations, each with different parameters. Each set of parameters should be specified in one line (see the files `input_parameters_multiple_launch_experiment$label.csv` for examples)
* `SEPAIHRD-Syria_structured.R` main code, which has these functions:
    * `make_transitions.R`: Function to estimate transitions between states.
    * `rates_SEPAIHRD_str.R`: integration routine stochastic model.
    * `dxdt_SEPAIHRD_str.R`: integration routine deterministic model.
    * `input_parameters_SEPAIHRD.R`: Generation of random realizations for hard-coded parameters.

#### Post-processing, figures and statistics

Note that each simulation already generates figures specific of that simulation. So the fillowing scripts generate figures or perform statistical analysis across simulations with different sets of parameters.

* `model_output_summaries.R`: Creates a table with means and stdv of all the variables for different population classes.

* `model_output_summaries_plotMaster.R`: Main script to simultaneously plot different experiments (i.e. combinations of simulations with different parameters). Several experiments can be plot in a single run, each described in a file called `input_parameters_multiple_output_summaries_$label.csv`. Dependencies:
    * `extract_subtable_output_summaries.R`: Extracts the subset of simulations correspondent to the experiment.
    * `model_output_summaries_plotSingle.R`: Plots for classes aggregated
    * `model_output_summaries_plotDouble.R` : Plots for classes split
    * `model_output_summaries_plotParams.R`: Parameters for the plots specific of each experiment.

All the following scripts run from their current folder. More details in the header of the file.
* `boxplots/generate_table_results.R`: compiles a tidy table of all the simulations.
* `boxplots/extend_table_results.R`: extends the tidy table with derived variables (e.g CFR).
* `boxplots/panel_plot_Fig2.R`: Generates Fig. 2 of the manuscript. Requires the tidy table.
* `boxplots/panel_plot_Fig3.R`: Generates Fig. 3 of the manuscript. Requires the tidy table.
* `boxplots/supp_figures.R`: Generates the figures for the supplementary material. Requires the tidy table.
* `boxplots/safety_age_groups.R`: Generates the Supplementary Figure 8 (safety zone and age groups). 
* `stats/all_stats.R`: Generates a table with basic tests for the results. 
* `stats/posthoc.R`: Runs a series of posthoc tests for particular questions about the results.
