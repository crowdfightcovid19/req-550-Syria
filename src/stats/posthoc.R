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
params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_A.csv",sep=""),header = TRUE, sep=",")
df.shield <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_C.csv",sep=""),header = TRUE, sep=",")
df.onset <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_B.csv",sep=""),header = TRUE, sep=",")
df.iso <- extract_subtable_output_summaries(df.all,params.df)

idx.contacts <- c(1,2,5,3,4,6,7)
df.shield$contacts<-factor(df.shield$contacts,levels(df.shield$contacts)[idx.contacts])
idx.group <- c(3,1,2)
df.shield$group<-factor(df.shield$group,levels(df.shield$group)[idx.group])
idx.limit<- c(1,2,5,7,3,6,8,4)
df.iso$Limit<-factor(df.iso$Limit,levels(df.iso$Limit)[idx.limit])


cat("Test if the difference between null model and safety interventions (10 and 2 contacts) are significantlt different.\n")

print(kruskal.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="T",]))

cat("There is a difference in the medians of the groups. We run a pairwise test.\n")

print(posthoc.kruskal.conover.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="T",]))

cat("Similar results using van Waerden.\n")

print(vanWaerden.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="T",]))

print(posthoc.vanWaerden.test(FracFinalDeaths~contacts,df.shield[df.shield$group=="T",]))

cat("All differences between contact strategies are significant\n")

cat("*********************************************\n")

cat("Test if the difference in the fraction of deaths is significant for 24h vs. 12h in the Onset variable.\n")

#params.df.onset <- read.table("../stats/input_summaries_onset.csv",header=TRUE,sep=",")                                                                   
#df.onset <- extract_subtable_output_summaries(df.all,params.df.onset)

print(kruskal.test( FracFinalDeaths~Onset, df.onset))

cat("The difference is significant. Posthoc...\n")

print(posthoc.kruskal.conover.test( FracFinalDeaths~Onset, df.onset))

cat("All differences significant.\n")

cat("van Waerden test to double check")

print(vanWaerden.test(FracFinalDeaths~Onset,df.onset))

print(posthoc.vanWaerden.test(FracFinalDeaths~Onset,df.onset))

cat("Posthoc test for isolation tents, increasing numbers the tents reduces significantly the fraction of deaths? What about CFR?\n")

print(kruskal.test( FracFinalDeaths~Limit,df.iso))

print(posthoc.kruskal.nemenyi.test( FracFinalDeaths~Limit,df.iso))

cat("We can do pairwise, ordered comparisons\n.")

print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit100"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit250"],paired=FALSE,alternative="two.sided"))

print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit250"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit500"],paired=FALSE,alternative="two.sided"))

print(wilcox.test(df.iso$FracFinalDeaths[df.iso$Limit=="Limit500"],df.iso$FracFinalDeaths[df.iso$Limit=="Limit2000"],paired=FALSE,alternative="less") )

cat("And a bunch of similar tests to get\n")

cat("Fracdeath: 100 = 250 = 500 < 50 < 10 = 25 = 2000 < 0, all the comparisons significant to 0.05")

cat("Therefore the optimal number of tents is 100, alternatively 50. There is no difference between 10 and 25 tents. Any number of tents is better than no tents. 2000 is not worth: 10 tents have the same effect, and 100 have a better effect.")

cat("For CFR\n")

print(posthoc.vanWaerden.test(CFR~Limit,df.iso))

cat("And doing a bunch of wilcox...")

print(posthoc.vanWaerden.test(CFR~Limit,df.iso))

cat("Any number better than 0. 100 = 250 = 500 = 2000 < 10=25=50\n")

df.shield.S <- subset(df.shield,group=="S")  
