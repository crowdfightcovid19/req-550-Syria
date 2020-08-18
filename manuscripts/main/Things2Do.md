


## Tables and figures

* Fix figures --> DONE
    * Box plots figures do not render well in the panels, change to something like geom ribbon or similar: it is needed to see the trend.
    * Isolation Figures are wrong. For number of deaths if there are no tents it should be around a 10%
    * I have also doubts on whether simulations with no deaths are excluded from the statistics.
    * The time to peak for isolation shows fraction of deaths.
    * Remove the theme with grey background
    * Increase fonts, remove titles.
    * If it is possible, create directly a panel with a faceting function to have a single legend and grid/wrap titles.
   
* Create same version of figures for SM.
* Create a nice Table summarizing the interventions, as the Table 1 in Zandvoort et al. Ours has more details though.
	* Perhaps combined with a decent diagram illustrating the creation of a safety zone, isolation and evacuation.
* Double check the diagram in Fig. 1 of the SM --> Jordan, DONE


## Results review and statistical analysis.
* Have a look at the figures and look for potential issues. Simplified version of all figures are located at  `data/real_models/results_post_processing/Summary_figures`. There is a README file explaining the names convention.
* From these figures, double check all percentages of increase/decrease of variables stated in the text. We could consider as a possibility creating a summary table.
* Test if the difference between null model and safety interventions (10 and 2 contacts) are significantlt different.
* Test if the difference in the fraction of deaths is significant for 24h vs. 12h in the Onset variable
* Posthoc test for isolation tents, increasing numbers the tents reduces significantly the fraction of deaths? What about CFR?
* Identify any other differences in the interventions to test.
* Understand why CFR for shielding increases for the shielded population, remains constant  for the exposed population and decreases for all population. --> Alberto, DONE, because there are cases with an outbreak in the orange zone in which there is no outbreak in the green zone. 
* Clarify the previous point in the legends of the figures.

## Format
* Incorporating literature (e.g. parametrizations) into the bib file. Search for more literature if needed and add the bibs.
* Include refs in the manuscript. (APG working on this)
* Include cross references of figures between SM and MS and double check. (APG working on this)
* Check formulas. More specifically, there are many commands internally defined, e.g. subindexes that should appear with mathrm format, and if they are typed incorrectly may generate errors in the formulas.
* Correct spelling and reduction word numbers (last thing to do)

## Contents

* Control the use of "camp"
* Reduce text in general, methods in particular. (>1000 words now)
* Avoid repeating contents across sections.
* Pay more attention to herd immunity
* More focused discussion.
* Supplementary Material
	* Double check safety zone implementation, was f saturated?
	* review subindexes, remove family and look for something more neutral.
