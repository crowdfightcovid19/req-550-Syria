#***************************************
#posthoc.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 19th August 2020
#description = Posthoc stats. Just random questions we decided to test. 
#usage = Run panel_plot.R (src/boxplots) to load the data tables. Then run this script. It is just a list of the tests.
#TODO: reorganise scripts so this one loads the data itself.

library(PMCMR)

source("../boxplots/plot_routines.R")

baseDir <- "/home/ecam/workbench/req-550-Syria"
codeDir <- paste(baseDir,"/src",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")
idDir="modSV" # this is a string contained in all the directories that should be processed
fileIn=paste("extended_results_table_",idDir,".csv",sep="")


df.all <- read.csv(paste(outDir,"/",fileIn,sep=""))
params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_B.csv",sep=""),header = TRUE, sep=",")
df.iso <- extract_subtable_output_summaries(df.all,params.df)

idx.limit<- c(1,2,5,7,3,6,8,4)
df.iso$Limit<-factor(df.iso$Limit,levels(df.iso$Limit)[idx.limit])


cat("Posthoc tests for isolation tents.\n")

cat("Does increasing numbers the tents reduces significantly the fraction of deaths?")

print(kruskal.test( FracFinalDeaths~Limit,df.iso))

print(posthoc.kruskal.nemenyi.test( FracFinalDeaths~Limit,df.iso))

cat("We can do pairwise, ordered comparisons\n.")

print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit0"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit10"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit10"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit25"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit25"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit50"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit50"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit250"],paired=FALSE,alternative="two.sided"))
print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit250"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit500"],paired=FALSE,alternative="less"))
print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit500"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit2000"],paired=FALSE,alternative="less"))

cat("Frac Deaths Summary: FracDeaths is reduced with 100 tents when compared to 0, 10, 25, 50. There is no difference between 100 and 250. FracDeaths increases for 500 and 2000 tents when compared to 100, 250.\n")

cat("Does increasing numbers the tents reduces significantly the IFR?\n")

print(kruskal.test( CFR~Limit,df.iso))

print(posthoc.kruskal.nemenyi.test( CFR~Limit,df.iso))

cat("We can do pairwise, ordered comparisons\n.")

print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit0"],df.iso$CFR[df.iso$Limit=="Limit10"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit10"],df.iso$CFR[df.iso$Limit=="Limit25"],paired=FALSE,alternative="two.sided"))
print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit25"],df.iso$CFR[df.iso$Limit=="Limit50"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit50"],df.iso$CFR[df.iso$Limit=="Limit100"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit100"],df.iso$CFR[df.iso$Limit=="Limit250"],paired=FALSE,alternative="two.sided"))
print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit250"],df.iso$CFR[df.iso$Limit=="Limit500"],paired=FALSE,alternative="two.sided"))
print(wilcox.test(df.iso$CFR[df.iso$Limit=="Limit500"],df.iso$CFR[df.iso$Limit=="Limit2000"],paired=FALSE,alternative="greater"))

cat("Summary for IFR: IFR is reduced when increasing tents up to 100 (as with frac final deahts). There is no diffeence between 100, 250 and 500 tents. IFR is reduced for 2000 when compared to 500 tents.\n")

cat("Does increasing numbers the tents reduces significantly the final fraction of population susceptible?\n")

print(kruskal.test( FracFinalSusceptible~Limit,df.iso))

print(posthoc.kruskal.nemenyi.test( FracFinalSusceptible~Limit,df.iso))

cat("We can do pairwise, ordered comparisons\n.")

print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit0"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit10"],paired=FALSE,alternative="less"))
print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit10"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit25"],paired=FALSE,alternative="less"))
print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit25"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit50"],paired=FALSE,alternative="less"))
print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit50"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit100"],paired=FALSE,alternative="less"))
print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit100"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit250"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit250"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit500"],paired=FALSE,alternative="greater"))
print(wilcox.test(df.iso$FracFinalSusceptible[df.iso$Limit=="Limit500"],df.iso$FracFinalSusceptible[df.iso$Limit=="Limit2000"],paired=FALSE,alternative="greater"))

cat("Summary for final susceptibles: number of final susceptibles increases up to a 100 tents, and then decreases.\n")



