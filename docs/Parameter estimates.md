# Parameter estimates

### Proportion symptomatic (fracAI)
* [Meta-analysis](https://www.medrxiv.org/content/10.1101/2020.05.10.20097543v1) estimates .16 asymptomatic (not age-specific)
* We use: fracAI = .84
* 95% CI = (.8, .88)
* Distributed binomially with exact Clopper–Pearson confidence intervals.

### Hospitalization rate/proportion of symptomatic requiring hospitalization (zeta)
* [Data from Spanish ministry of health](https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov-China/documentos/Actualizacion_52_COVID-19.pdf) used as source (known parameter, no probability distribution- data covers all cases in Spain where age is known as of 22.03)
* Age specific
  * Age 1 (0-12)- assume hospitalization rate for the age group as a whole follows a distribution most similar to the 0-9 age group in Spain: .50%
  * Age 2 (13-50)- assume hospitalization rate for the age group as a whole follows a distribution most similar to the 20-29 age group in Spain: 2.69%
  * Age 3 (over 50)- assume hospitalization rate for the age group as a whole follows a distribution most similar to the 60-69 age group in Spain: 18.05%

### CFR/fatality rate among hospitalized (alpha- may not need for our purposes)
* [ICL paper](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf) used estimates for proportion of hospitalized cases requiring critical care (assuming all cases requiring critical care will die)
* Age group 1 = .05, age group 2 = .05, age group 3 = .274

### 1/delta_E (average duration of the latent period E)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19, n = 94 patients](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/delta_E = average incubation period (5.2 days, 95% CI: 4.1-7.0, lognormal) - pre-symptomatic period (2.3 days, 95% CI: 0.8-3.0) 
* 1/delta_E = 2.9 days (95% CI: tbd, see https://github.com/crowdfightcovid19/req-550-Syria/issues/8#issuecomment-636537245)

### 1/delta_P (average duration of the pre-symptomatic period P)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19, n = 94 patients](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/delta_P = 2.3 days (95% CI: 0.8-3.0) 

### 1/gamma (average duration of infection A/I)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19, n = 94 patients](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/gamma_I = 1/gamma_A = 7-8 days (no 95% IC available, this parameter is very difficult to estimate because there is no routine test and no temporal event such as hospital discharge). 
* Note: after 8 days, viral RNA from mild cases (not hopitalized) could still be detected by PCR but could not be cultured in vitro anymore [Ref](https://www.nature.com/articles/s41586-020-2196-x)

### 1/delta_H (average time from symptoms onset I to hospitalization H)
* 1/delta_H mean = 7 days (sd = +- 4) [Seattle study, n = 24 patients](https://www.nejm.org/doi/full/10.1056/NEJMoa2004500)
* 1/delta_H median = 7 days (IQR: 4-8) [Chinese study, n = 138 patients](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/delta_H median = 11 days (IQR: 8-14) [Other Chinese study, n = 191 patients](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

### 1/delta_C (average time from hospitalization H to critical care, here considered as death D)
* 1/delta_C = Time from onset to ICU - time from onset to hospitalization
* 1/delta_C = 10 days (IQR: 6-12) - 7 days (IQR: 4-8) = 3 days (IQR or CI tbd) [Chinese study, n = 138 patients](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/delta_C = 12 days (IQR: 8-15) - 11 days (IQR: 8-14) = 1 day (IQR or CI tbd) [Other Chinese study, n = 191 patients](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

### 1/gamma_H (average time from hospitalization H to recovery R)
* 1/gamma_H = 10 days (IQR: 7-14) [Chinese study, n = 138 patients](https://jamanetwork.com/journals/jama/fullarticle/2761044)

### Estimation of R0 in densely populated settings
* R0 fitted with real data in Buenos Aires and neighboring cities pre-lockdown measures = 3.33 [Buenos Aires](https://arxiv.org/abs/2005.06297) Note: the area includes favelas but also wealthier neighborhoods. 
* R0 fitted with real data in Nigeria = 2.25 at the national level; R0 = 3.44 in Lagos; R0 = 2.77 in Abuja [Nigeria](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3596095).
