# Parameter estimates

## Class-specific (vary according to age group/comorbidity status)

### Fraction of symptomatic requiring hospitalization but not ICU admission (h)
* [Data from a Chinese study](https://pediatrics.aappublications.org/content/pediatrics/early/2020/03/16/peds.2020-0702.full.pdf) (very similar to the [US CDC report on COVID-19 in children](https://www.cdc.gov/mmwr/volumes/69/wr/mm6914e4.htm?s_cid=mm6914e4_e&deliveryName=USCDC_921-DM25115#T1_down) but without missing data) used for children (0-12)
* [Data from US CDC report on underlying health conditions and COVID-19 in adults](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7119513/) used for adults (13+)
* Parameter is fixed with known age and comorbidity specific values, no probability distribution
  * Age 1 (0-12)- set to proportion of all cases severe in age groups <1, 1-5, and 6-10 in [Dong et al](https://pediatrics.aappublications.org/content/pediatrics/early/2020/03/16/peds.2020-0702.full.pdf) (6.4%)
      * Close to, but higher than the lower-bound estimate for the [COVID-19 hospitalization rate in children from the CDC](https://www.cdc.gov/mmwr/volumes/69/wr/mm6914e4.htm?s_cid=mm6914e4_e&deliveryName=USCDC_921-DM25115#T1_down) (5.7%)
  * Age 2 (13-50), no comorbidities- set to proportion hospitalized without ICU admission aged 19-64 with no comorbidities & known outcomes (6.7%)
  * Age 2 (13-50), comorbidities- set to proportion hospitalized without ICU admission aged 19-64 with comorbidities & known outcomes (19.9%)
  * Age 3 (over 50), no comorbidities- set to proportion hospitalized without ICU admission aged 65+ with no comorbidities & known outcomes (18.3%)
  * Age 3 (over 50), comorbidities- set to proportion hospitalized without ICU admission aged 65+ with comorbidities & known outcomes (44.5%)

### Fraction of symptomatic requiring ICU admission (g)
* [Data from a Chinese study](https://pediatrics.aappublications.org/content/pediatrics/early/2020/03/16/peds.2020-0702.full.pdf) (very similar to the [US CDC report on COVID-19 in children](https://www.cdc.gov/mmwr/volumes/69/wr/mm6914e4.htm?s_cid=mm6914e4_e&deliveryName=USCDC_921-DM25115#T1_down) but without missing data) used for children (0-12)
* [Data from US CDC report on underlying health conditions and COVID-19 in adults](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7119513/) used for adults (13+)
* Parameter is fixed with known age and comorbidity specific values, no probability distribution
  * Age 1 (0-12)- set to proportion of all cases critical in age groups <1, 1-5, and 6-10 in [Dong et al](https://pediatrics.aappublications.org/content/pediatrics/early/2020/03/16/peds.2020-0702.full.pdf) (.65%)
      * Close to, but higher than the lower-bound estimate for the [COVID-19 ICU admission rate for children from the CDC](https://www.cdc.gov/mmwr/volumes/69/wr/mm6914e4.htm?s_cid=mm6914e4_e&deliveryName=USCDC_921-DM25115#T1_down) (.58%)
  * Age 2 (13-50), no comorbidities- set to proportion admitted to ICU aged 19-64 with no comorbidities & known outcomes (2.0%)
  * Age 2 (13-50), comorbidities- set to proportion admitted to ICU aged 19-64 with comorbidities & known outcomes (9.4%)
  * Age 3 (over 50), no comorbidities- set to proportion admitted to ICU aged 65+ with no comorbidities & known outcomes (6.3%)
  * Age 3 (over 50), comorbidities- set to proportion admitted to ICU aged 65+ with comorbidities & known outcomes (22.2%)


## Not class-specific

### Fraction symptomatic (f)
* [Meta-analysis](https://www.medrxiv.org/content/10.1101/2020.05.10.20097543v1) estimates .16 asymptomatic (not age-specific)
* We use: fracAI = .84
* 95% CI = (.8, .88)
* Distributed binomially with exact Clopper–Pearson confidence intervals.

### 1/delta_E (average duration of the latent period E)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19, n = 94 patients](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/delta_E = average incubation period (5.2 days, 95% CI: 4.1-7.0, lognormal) - pre-symptomatic period (2.3 days, 95% CI: 0.8-3.0) 
    * Ref. incubation: Li, Q. et al. Early transmission dynamics in Wuhan, China, of novel coronavirus-infected pneumonia. _N. Engl. J. Med._ **382**, 1199–1207 (2020).
* 1/delta_E = 2.9 days (95% CI: tbd, see https://github.com/crowdfightcovid19/req-550-Syria/issues/8#issuecomment-636537245)

### 1/delta_P (average duration of the pre-symptomatic period P)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19, n = 94 patients](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/delta_P = 2.3 days (95% CI: 0.8-3.0) 

### 1/gamma (average duration of infection A/I)
* [Nature paper on temporal dynamics in viral shedding and transmissibility of COVID-19, n = 94 patients](https://www.nature.com/articles/s41591-020-0869-5#citeas)
* 1/gamma_I = 1/gamma_A = 7-8 days (no 95% IC available, this parameter is very difficult to estimate because there is no routine test and no temporal event such as hospital discharge). 
* Note: after 8 days, viral RNA from mild cases (not hopitalized) could still be detected by PCR but could not be cultured in vitro anymore [Ref](https://www.nature.com/articles/s41586-020-2196-x)

### 1/eta (average time from symptoms onset I to hospitalization H)
* 1/eta mean = 7 days (sd = +- 4) [Seattle study, n = 24 patients](https://www.nejm.org/doi/full/10.1056/NEJMoa2004500)
* 1/eta median = 7 days (IQR: 4-8) [Chinese study, n = 138 patients](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/eta median = 11 days (IQR: 8-14) [Other Chinese study, n = 191 patients](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

### 1/alpha (average time from onset to critical care, here considered as death D)
* 1/alpha = Time from onset to ICU
* 1/alpha = 10 days (IQR: 6-12) [Chinese study, n = 138 patients](https://jamanetwork.com/journals/jama/fullarticle/2761044)
* 1/alpha = 12 days (IQR: 8-15) [Other Chinese study, n = 191 patients](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

### 1/gamma_H (average time from hospitalization H to recovery R)
* 1/gamma_H = 10 days (IQR: 7-14) [Chinese study, n = 138 patients](https://jamanetwork.com/journals/jama/fullarticle/2761044)

### Estimation of R0 in densely populated settings
* R0 fitted with real data in Buenos Aires and neighboring cities pre-lockdown measures = 3.33 [Buenos Aires](https://arxiv.org/abs/2005.06297) Note: the area includes favelas but also wealthier neighborhoods. 
* R0 fitted with real data in Nigeria = 2.25 at the national level; R0 = 3.44 in Lagos; R0 = 2.77 in Abuja [Nigeria](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3596095).
