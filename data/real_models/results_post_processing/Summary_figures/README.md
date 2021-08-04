## Description of files

Files are described using the format `interventionVsVariable.pdf` where:

* **intervention** can be:
    * self = self-distancing
    * Limit = self-isolation of symptomatic with mild symptoms
    * Onset = time that an individual takes to recognize symptoms and self-isolate.
    * Isolate = evacuation of symptomatic that would require hospitalization.
    * contacts = safety-zone: number of contacts per week and individual that can occur in the buffering zone.
    * popShielded = population classes that are moved to the safety zone.
    * Tcheck = influence of having health checks that exclude symptomatic cases for getting into the buffering zone.
    * lock = lockdown of the safety zone after one symptomatic case appears in the exposed zone.
    * popSize = how the safety zone intervention behaves for different population sizes.
    * Combined = combinations of interventions.

* **Variable** can be:

Note that the following values are means across all simulations in which at least one death was observed, and this may vary between population classes. Hence, a correct interpretation of results requires considering both the probability of outbreak and any of the remainder variables listed below.
    * P.outbrk: Probability of observing at least one death in the class.
    * NumFinalDeaths.mean: Fraction of the population class dying.
    * NumFinalRecovered.mean: Fraction of the population recovering after the infection.
    * CFR: Case Fatality Rate.
    * TimePeakSymptomatic.mean: Time that the symptomatic population takes to peak after an outbreak. 

In addition, we add the label "byClass" when results are split for each specific population class, the figure refers to the whole population otherwise.
