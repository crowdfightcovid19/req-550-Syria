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
* 1/delta_E = average incubation period (5.2 days, 95% CI: 4.1-7.0) - pre-symptomatic period (2.3 days, 95% CI: 0.8-3.0) 
* 1/delta_E = 2.9 days (95% CI: tbd, see https://github.com/crowdfightcovid19/req-550-Syria/issues/8#issuecomment-636537245)

### 1/delta_P (average duration of the pre-symptomatic period P)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/delta_P = 2.3 days (95% CI: 0.8-3.0) 

### 1/gamma (average duration of infection A/I)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/gamma_I = 1/gamma_A = 7-8 days (no 95% IC available, this parameter is very difficult to estimate because there is no test and no temporal event such as hospital discharge). 
* Note: after 8 days, viral RNA from mild cases (not hopitalized) could still be detected by PCR but could not be cultured in vitro anymore [Ref](https://www.nature.com/articles/s41586-020-2196-x)

### 1/delta_H (average time from symptoms onset I to hospitalization H)
* 1/delta_H mean = 7 days (sd = +- 4) [Seattle study](https://www.nejm.org/doi/full/10.1056/NEJMoa2004500)
* 1/delta_H median = 7 days (IQR: 4-8) [Chinese study](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/delta_H median = 11 days (IQR: 8-14) [Second Chinese study](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

### 1/delta_C (average time from hospitalization H to critical care, here considered as death D)
* 1/delta_C = Time from onset to ICU - time from onset to hospitalization
* 1/delta_C = 10 days (IQR: 6-12) - 7 days (IQR: 4-8) = 3 days (IQR or CI tbd) [Chinese study](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/delta_C = 12 days (IQR: 8-15) - 11 days (IQR: 8-14) = 1 day (IQR or CI tbd) [Second Chinese study](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

### 1/gamma_H (average time from hospitalization H to recovery R)
* [Chinese study](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/gamma_H = 10 days (IQR: 7-14)
