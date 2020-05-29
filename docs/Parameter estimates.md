# Parameter estimates

### Proportion symptomatic (fracAI)
* [Meta-analysis](https://www.medrxiv.org/content/10.1101/2020.05.10.20097543v1) estimates .16 asymptomatic (not age-specific)
* We use: fracAI = .84

### Hospitalization rate/proportion of symptomatic requiring hospitalization (zeta)
* [ICL paper](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf) used as source
* Age group 1 = .001, age group 2 = .012, age group 3 = .166

### CFR/fatality rate among hospitalized (alpha)
* [ICL paper](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf) used estimates for proportion of hospitalized cases requiring critical care (assuming all cases requiring critical care will die)
* Age group 1 = .05, age group 2 = .05, age group 3 = .274

### 1/delta_E (average duration of the latent period E)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* [Paper on incubation period](https://www.acpjournals.org/doi/10.7326/M20-0504)
* 1/delta_E = average incubation period (5 days, range: 4-6) - pre-symptomatic period (2-3 days) 
*           = 2-3 days (range: 1-4)

### 1/delta_P (average duration of the pre-symptomatic period P)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/delta_P = 2-3 days 

### 1/gamma (average duration of infection A/I)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/gamma = 7-8 days 
* Note: after 8 days, viral RNA from mild cases (not hopitalized) could still be detected by PCR but could not infect cells in vitro anymore [Ref](https://www.nature.com/articles/s41586-020-2196-x)
