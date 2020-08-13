


## Tables and figures

* Create panels for composite figures.
    * Option 1:
    * Table + scheme of the interventions
    * Panel 1. A 3rows x 4cols figures. 
        * Columns: Prob. Outbreak, fraction of deaths, Time to peak, number recovered.
        * Rows: Self-distance, self-isolation, shielding (basic).
    * Panel 2. 
        * 4 rows with each combination of interventions, with a single x axis.

    * Option 2:
    * Table + scheme of the interventions
    * Panel 1. A 3rows x 4cols figures. 
        * Columns: Prob. Outbreak, fraction of deaths, Time to peak, number recovered.
        * Rows: Self-distance, self-isolation, shielding (basic).
    * Panel 2. 
        * Columns: Prob. Outbreak, fraction of deaths, Time to peak, number recovered.
        * Rows: Shielding+lockdown, Shielding+effect type pop shielded, Shielding+effect pop size.
    * Panel 3. 
        * 4 rows with each combination of interventions, with a single x axis.

* Create a nice Table summarizing the interventions, as the Table 1 in Zandvoort et al. Ours has more details though.
* Double check the diagram in Fig. 1 of the SM
* Create a decent diagram illustrating the creation of a safety zone, isolation and evacuation.
* Create new figures if needed.


## Results review and statistical analysis.
* Have a look at the figures and look for potential issues. Simplified version of all figures are located at  `data/real_models/results_post_processing/Summary_figures`. There is a README file explaining the names convention.
* From these figures, double check all percentages of increase/decrease of variables stated in the text. We could consider as a possibility creating a summary table.
* Test if the difference in the fraction of deaths is significant for 24h vs. 12h in the Onset variable
* Posthoc test for isolation tents, increasing numbers the tents reduces significantly the fraction of deaths? What about CFR?
* Identify any other differences in the intervention 
* Understand why CFR for shielding increases for the shielded population, remains constant  for the exposed population and decreases for all population.

## Format
* Incorporating literature (e.g. parametrizations) into the bib file. Search for more literature if needed and add the bibs.
* Include refs in the manuscript.
* Include cross references of figures between SM and MS and double check.
* Check formulas. More specifically, there are many commands internally defined, e.g. subindexes that should appear with mathrm format, and if they are typed incorrectly may generate errors in the formulas.
* Correct spelling and reduction word numbers (last thing to do)

## Contents
(APG -- working on SM)
(Chamsy -- working on Intro and Discussion of MS)

* Control the use of "camp"
* Reduce text in general, methods in particular. (>800 words now)
* Avoid repeating contents across sections.
* Pay more attention to herd immunity
* More focused discussion.
* Supplementary Material
	* Double check safety zone implementation, was f saturated?
	* review subindexes, remove family and look for something more neutral.
