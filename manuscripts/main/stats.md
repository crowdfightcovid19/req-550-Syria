# General notes

Assumptions for ANOVA are not met in general. We use non-parametric tests.

# Questions from Things2Do

## Test if the difference between null model and safety interventions (10 and 2 contacts) are significantlt different.

### Total population
All differences are significant. 

`kruskal.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="T",]`
 
Kruskal-Wallis chi-squared = 133.36, df = 2, p-value < 2.2e-16. 

There is a difference in the medians of the groups. We run a pairwise test (Conover)

`posthoc.kruskal.conover.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="T",]`

|                                | null\_model\_mixed  | shield\_cont10\_age3\_age2\_20 |
| shield\_cont10\_age3\_age2\_20 | 1.3e-07             | -                              |
| shield\_cont2\_age3\_age2\_20  | < 2e-16             | 4.3e-11                        |

### Exposed population
No significant differences.

`kruskal.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="E",]`

> Kruskal-Wallis chi-squared = 0.036058, df = 1, p-value = 0.8494

### Safety-zone population
10 contacts per week have less fraction of deaths than 2 contacts per week.

`kruskal.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="S",])`

> Kruskal-Wallis chi-squared = 10.972, df = 1, p-value = 0.0009249

We confirm the relative order with one-sided Wilcoxon.

`wilcox.test(df.shield.S$FracFinalDeaths[df.shield.S$contacts=="shield_cont10_ age3_age2_20"],df.shield.S$FracFinalDeaths[df.shield.S$contacts=="shield_cont 2_age3_age2_20"],paired=FALSE,alternative="less")`

> W = 45153, p-value = 0.0004628.

#### Notes:
 - Although it is significant, the difference in the median is small (0.2075 vs 0.2125).

`aggregate(FracFinalDeaths~contacts,df.shield.S,median)`

 - The mean has the opposite order (0.2074 for 10 contacts/week vs 0.2031 for 2 contacts/week).

`aggregate(FracFinalDeaths~contacts,df.shield.S,mean)`

 - There is no significant difference for CFR.

`kruskal.test(CFR~contacts,df.shield[df.shield$group=="S",])`

> Kruskal-Wallis chi-squared = 3.5753, df = 1, p-value = 0.05864

## Test if the difference in the fraction of deaths is significant for 24h vs. 12h in the Onset variable

All differences are significant.

`kruskal.test( FracFinalDeaths~Onset, df.onset)`

> Kruskal-Wallis chi-squared = 800.74, df = 2, p-value < 2.2e-16

`posthoc.kruskal.conover.test( FracFinalDeaths~Onset, df.onset)`

|         | Onset12 | Onset24 |
| Onset24 | <2e-16  | -       |
| Onset48 | <2e-16  | <2e-16  |

## Posthoc test for isolation tents, increasing numbers the tents reduces significantly the fraction of deaths? What about CFR?

### Fraction of deaths

There are significant differences for different number of tents.

`kruskal.test( FracFinalDeaths~Limit,df.iso)`

> Kruskal-Wallis chi-squared = 1176.5, df = 7, p-value < 2.2e-16

We can do pairwise differences:

`posthoc.kruskal.conover.test( FracFinalDeaths~Limit,df.iso)`

|           | Limit0  | Limit10 | Limit25 | Limit50 | Limit100 | Limit250 | Limit500 |
| Limit10   | < 2e-16 | -       | -       | -       | -        | -        | -        |  
| Limit25   | < 2e-16 | 0.28914 | -       | -       | -        | -        | -        |  
| Limit50   | < 2e-16 | 6.4e-09 | 0.00014 | -       | -        | -        | -        |  
| Limit100  | < 2e-16 | < 2e-16 | < 2e-16 | 3.1e-05 | -        | -        | -        |  
| Limit250  | < 2e-16 | < 2e-16 | < 2e-16 | 0.00014 | 0.72206  | -        | -        |  
| Limit500  | < 2e-16 | < 2e-16 | 3.0e-13 | 0.00535 | 0.52343  | 0.63219  | -        |  
| Limit2000 | < 2e-16 | 0.00129 | 0.28914 | 0.07105 | 7.8e-12  | 8.4e-11  | 4.0e-08  |  

There are no significant differences between 100, 250 and 500 isolation tents. We confirm this with an extra Kruskal-Wallis test.

```
df.iso.low <- subset(df.iso,Limit=="Limit100" | Limit=="Limit250" | Limit == "Limit500");
kruskal.test( FracFinalDeaths~Limit,df.iso.low)
```
> Kruskal-Wallis chi-squared = 2.1826, df = 2, p-value = 0.3358

There are no significant differences between 10 and 25 tents.

100 tents (or 250, or 500) is better than 10, 25, 50 or 2000 tents. We can confirm this with pairwise Wilcoxon test:

`wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit10"],paired=FALSE,alternative="less")`

> W = 48072, p-value < 2.2e-16


`wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit25"],paired=FALSE,alternative="less")`

> W = 48072, p-value < 2.2e-16


`wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit50"],paired=FALSE,alternative="less")`

> W = 65669, p-value = 3.521e-06


`wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit2000"],paired=FALSE,alternative="less")`

> W = 60996, p-value = 3.839e-11

It is better to have 50 tents rather than 25 in terms of fraction of deaths.
Any number of tents is better than not implementing the isolation strategy.

In conclusion, the more tents the better, up to a 100. Going over a 100 tents is not cost-effective (there is no significant difference between 100 and 500), and with even higher number the result is negative (increase in the fraction of deaths).

### CFR

There are significant differences for different number of tents.

`kruskal.test( CFR~Limit,df.iso)`

> Kruskal-Wallis chi-squared = 1091.7, df = 7, p-value < 2.2e-16

We can do pairwise differences:

`posthoc.kruskal.conover.test( CFR~Limit,df.iso)`

|           | Limit0  | Limit10 | Limit25 | Limit50 | Limit100 | Limit250 | Limit500 | 
| Limit10   | < 2e-16 | -       | -       | -       | -        | -        | -        | 
| Limit25   | < 2e-16 | 1.00000 | -       | -       | -        | -        | -        | 
| Limit50   | < 2e-16 | 0.84492 | 0.55349 | -       | -        | -        | -        | 
| Limit100  | < 2e-16 | 0.00526 | 0.00230 | 0.51590 | -        | -        | -        | 
| Limit250  | < 2e-16 | 0.00093 | 0.00038 | 0.17591 | 1.00000  | -        | -        | 
| Limit500  | < 2e-16 | 5.7e-06 | 2.0e-06 | 0.00575 | 0.84492  | 1.00000  | -        | 
| Limit2000 | < 2e-16 | 1.0e-05 | 3.6e-06 | 0.00820 | 0.89606  | 1.00000  | 1.00000  |

There are no significant differences between 100, 250, 500 or 2000 tents.

```
df.iso.aux <- subset(df.iso,Limit=="Limit100" | Limit=="Limit250" | Limit == "Limit500" | Limit == "Limit2000");
kruskal.test( CFR~Limit,df.iso.aux )
```
> Kruskal-Wallis chi-squared = 2.7097, df = 3, p-value = 0.4386

There are no significant differences between 10, 25 and 50 tents.

```
df.iso.aux <- subset(df.iso,Limit=="Limit10" | Limit=="Limit25" | Limit == "Limit50");
kruskal.test( CFR~Limit,df.iso.aux )
```
> Kruskal-Wallis chi-squared = 3.5779, df = 2, p-value = 0.1671

100 tents reduces the CFR in comparison to 10, 25 or 50 tents.

`wilcox.test(df.iso$CFR[df.iso$Limit=="Limit100"],df.iso$CFR[df.iso$Limit=="Limit10"],paired=FALSE,alternative="less")`

> W = 68768, p-value = 0.000654

`wilcox.test(df.iso$CFR[df.iso$Limit=="Limit100"],df.iso$CFR[df.iso$Limit=="Limit25"],paired=FALSE,alternative="less")`

> W = 64850, p-value = 0.0003085

`wilcox.test(df.iso$CFR[df.iso$Limit=="Limit100"],df.iso$CFR[df.iso$Limit=="Limit50"],paired=FALSE,alternative="less")`

> W = 74760, p-value = 0.0428
