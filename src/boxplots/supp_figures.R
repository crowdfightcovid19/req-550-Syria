#***************************************
#panel_plot.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 15th Aug 2020
#description = Produces panel plot  
#usage = Edit setwd to base dir and run


currentDir <- getwd()

source("plot_routines.R")

library(dplyr)

setwd("/home/ecam/workbench/req-550-Syria")

#ptitle <- c("boxplot","boxmean","boxmedian","vio","viomean","viomedian","ribbonsd","ribbonmedian","ribbonse")
#fplot.list <- c(do_box_plot,do_box_plot_mean,do_box_plot_median,do_vio_plot,do_vio_plot_mean,do_vio_plot_median,do_ribbon_sd,do_ribbon_quartile,do_ribbon_se)

ptitle <- c("boxmeandot")
fplot.list <- c(do_box_plot_mean_dot)

axis.text.size = 24
axis.title.size = 27
legend.title.size = 27
legend.text.size = 24
axis.text.x.size = 24
title.size = 35

varPoutbreak <- "POutbreak"
varFracDeath <- "FracFinalDeaths"
varPeak <- "TimePeakSymptomatic"

ytitPoutbreak <- "Probability of Outbreak"
ytitFracDeath <- "Fraction of Population Dying"
ytitPeak <- "Time to Peak Symptomatic (days)"

#Directories
baseDir <- getwd()
codeDir <- paste(baseDir,"/src",sep="")
dataDir <- paste(baseDir,"/data/real_models",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")
outPlotDir <- paste(baseDir,"/manuscripts/main/figures/newFig",sep="")

idDir="modSV" # this is a string contained in all the directories that should be processed
fileIn=paste("extended_results_table_",idDir,".csv",sep="")

df.all <- read.csv(paste(outDir,"/",fileIn,sep=""))

#Extract relevant data from table
setwd(codeDir)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_A.csv",sep=""),header = TRUE, sep=",")
df.shield <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_H.csv",sep=""),header = TRUE, sep=",")
df.self <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_B.csv",sep=""),header = TRUE, sep=",")
df.iso <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_C.csv",sep=""),header = TRUE, sep=",")
df.onset <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_D.csv",sep=""),header = TRUE, sep=",")
df.shieldlimit <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_E.csv",sep=""),header = TRUE, sep=",")
df.tcheck <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_F.csv",sep=""),header = TRUE, sep=",")
df.tcheckElderly <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_G.csv",sep=""),header = TRUE, sep=",")
df.lock <- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_J.csv",sep=""),header = TRUE, sep=",")
df.evac<- extract_subtable_output_summaries(df.all,params.df)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_A2.csv",sep=""),header = TRUE, sep=",")
df.fate<- extract_subtable_output_summaries(df.all,params.df)



idx.contacts <- c(1,2,5,3,4,6,7)
df.shield$contacts<-factor(df.shield$contacts,levels(df.shield$contacts)[idx.contacts])

idx.group <- c(3,1,2)
df.shield$group<-factor(df.shield$group,levels(df.shield$group)[idx.group])

idx.limit<- c(1,2,5,7,3,6,8,4)
df.iso$Limit<-factor(df.iso$Limit,levels(df.iso$Limit)[idx.limit])

idx.self<- c(3,1,2)
df.self$self<-factor(df.self$self,levels(df.self$self)[idx.self])

#idx.onset <- c(3,1,2)
#df.onset$Onset<-factor(df.onset$Onset,levels(df.onset$Onset)[idx.onset])

idx.contacts_sl <- c(3,4,5,6,7,1,2)
df.shieldlimit$contacts<-factor(df.shieldlimit$contacts,levels(df.shieldlimit$contacts)[idx.contacts_sl])

idx.lock <- c(4,1,2,3)
df.lock$lock<-factor(df.lock$lock,levels(df.lock$lock)[idx.lock])
df.lock$group<-factor(df.lock$group,levels(df.lock$group)[c(3,1,2)])

#New factor with the intervention
df.tcheck$intervention <- as.factor(paste(df.tcheck$contacts,df.tcheck$PopSize,sep="/"))
df.tcheck$intervention<-factor(df.tcheck$intervention,levels(df.tcheck$intervention)[c(3,1,2,6,4,5)])

df.tcheck$group<-factor(df.tcheck$group,levels(df.tcheck$group)[idx.group])

df.shieldlimit$group<-factor(df.shieldlimit$group,levels(df.shieldlimit$group)[idx.group])


df.tcheckElderly$group<-factor(df.tcheckElderly$group,levels(df.tcheckElderly$group)[idx.group])
df.tcheckElderly$intervention<-as.factor(paste(df.tcheckElderly$contacts,df.tcheckElderly$Tcheck,sep="/"))


df.evac$group<-factor(df.evac$group,levels(df.evac$group)[idx.group])
df.evac$intervention<-as.factor(paste(df.evac$contacts,df.evac$Isolate,sep="/"))

df.fate$Fate<-factor(df.fate$Fate,levels(df.fate$Fate)[c(2,1)])

setwd(outPlotDir)

#Lockdown of buffer zone
outFile = "FigS12"
varX = "lock"
varY = "FracFinalRecovered"
xlabel = "Reduction of number of contacts buffer zone (%)"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("0","50","90","99")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.e <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
##gg.e <-gg.e +ylim(0.5,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.d <-gg.d +ylim(0.0,0.25)

df.lock.aux <- data.frame(df.lock %>% group_by(group,lock) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.dd <- do_line_plot(df.lock.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df.lock,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 15)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,gg.f,ncol=3,nrow=3)
#dev.off( )

#Effect of number of individuals per camp
outFile = "FigS11"
varX = "intervention"
varY = "FracFinalRecovered"
xlabel = "Model/Number of individuals in the camp"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("null/500","null/1000","null/2000","safety 2/500","safety 2/1000","safety 2/2000")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.e <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.e<-gg.e+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.e<- gg.e + ylim(0.5,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.d<-gg.d+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.d<- gg.d + ylim(0.0,0.35)

#df.tcheck.aux <- data.frame(df.tcheck %>% group_by(group,intervention) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))
#
#gg.dd <- do_line_plot(df.tcheck.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.dd<-gg.dd+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.c<-gg.c+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.b<-gg.b+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df.tcheck,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg.a<-gg.a+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 17)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,ncol=3,nrow=2)
#dev.off( )


#Effect of number of individuals per camp
df <- df.shieldlimit
outFile = "FigS10"
varX = "contacts"
varY = "FracFinalRecovered"
xlabel = "Population classes in safety zone"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("Older","Older + adult w. comorb.","Older + adults + kids (< 20%)","Older + adults + kids (< 25%)","Older + adults + kids (< 30%)")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.e <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.e<-gg.e+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.e<- gg.e + ylim(0.25,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.d<-gg.d+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.d<- gg.d + ylim(0.0,0.75)

#df.aux <- data.frame(df %>% group_by(group,contacts) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))
#
#gg.dd <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.dd<-gg.dd+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.c<-gg.c+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.b<-gg.b+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df,varY,varX,xlabel,ylabel,"identity",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg.a<-gg.a+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 20)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,ncol=3,nrow=2)
#dev.off( )


#Safety zone
df <- df.shield
outFile = "FigS9"
varX = "contacts"
varY = "FracFinalRecovered"
xlabel = "Number of contacts per week/individual"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("No limit","10","2")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
#gg.b <- gg.b + ylim(0.5,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "CFR"
ylabel = "Case Fatality Rate"

gg.a <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.a <- gg.a + ylim(0.0,0.40)

df.aux <- data.frame(df %>% group_by(group,contacts) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.aa <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


pdf(file=paste(outFile,".pdf",sep=""),width=20,height = 10)
grid.arrange(gg.a,gg.f,gg.b,ncol=3,nrow=1,widths=c(1,1,1.35))
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=20,height = 10)
#grid.arrange(gg.aa,gg.b,ncol=2,nrow=1,widths=c(1,1.35))
#dev.off( )
#


#Checks in buffer zone
df <- df.tcheckElderly
outFile = "FigS7"
varX = "intervention"
varY = "FracFinalRecovered"
xlabel = "Contacts per week and individual / Health checks"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("10 cont. (no checks)", "10 cont. + checks", "2 cont. (no checks)", "2 cont. + checks")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.e <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.e<-gg.e+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.e<- gg.e + ylim(0.5,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.d<-gg.d+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.d<- gg.d + ylim(0.0,0.4)

#df.aux <- data.frame(df %>% group_by(group,intervention) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))
#
#gg.dd <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.dd<-gg.dd+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#

varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.c<-gg.c+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.b<-gg.b+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg.a<-gg.a+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 18)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,ncol=3,nrow=2)
#dev.off( )


#Evac
df <- df.evac
outFile = "FigS6"
varX = "intervention"
varY = "FracFinalRecovered"
xlabel = "Model / Evacuation"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("null / NO","null / YES", "safety 2 / NO", "safety 2 / YES") 
#scale_x_labels <- c("NO","YES") 
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

#df <- subset(df,group=="T")
df <- subset(df,contacts=="null_model_mixed")

gg.e <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.e<-gg.e+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.e<- gg.e + ylim(0.5,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.d<-gg.d+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#gg.d<- gg.d + ylim(0.0,0.4)

#df.aux <- data.frame(df %>% group_by(group,intervention) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))
#
#gg.dd <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.dd<-gg.dd+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
#

varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.c<-gg.c+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.b<-gg.b+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg.a<-gg.a+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 17)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,ncol=3,nrow=2)
#dev.off( )


#Onset
df <- df.onset
outFile = "FigS5"
varX = "Onset"
varY = "FracFinalRecovered"
xlabel = "Time to self-isolation (h)"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("No isol.", "12", "24", "48")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.e <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.e<- gg.e + ylim(0.75,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.d<- gg.d + ylim(0.0,0.25)

df.aux <- data.frame(df %>% group_by(group,Onset) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.dd <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 15)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,ncol=3,nrow=2)
#dev.off( )


#No. isolation tents
df <- df.iso
outFile = "FigS4"
varX = "Limit"
varY = "FracFinalRecovered"
xlabel = "Number of self-isolation tents"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("0","10","25","50","100","250","500","2000")
scale_fill_labels <- c("Total")
group_name = "Group"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.b <- gg.b + ylim(0.75,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "CFR"
ylabel = "Case Fatality Rate"

gg.a <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.a <- gg.a + ylim(0.0,0.20)

df.aux <- data.frame(df %>% group_by(group,Limit) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.aa <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


pdf(file=paste(outFile,".pdf",sep=""),width=20,height = 10)
grid.arrange(gg.a,gg.b,gg.f,ncol=3,nrow=1)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=20,height = 10)
#grid.arrange(gg.aa,gg.b,ncol=2,nrow=1)
#dev.off( )



#Self distancing
df <- df.self
outFile = "FigS3"
varX = "self"
varY = "FracFinalRecovered"
xlabel = "Individual reduction of contacts per day (%)"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("0","20","50")
scale_fill_labels <- c("Total")
group_name = "Group"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.b <- gg.b + ylim(0.5,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "CFR"
ylabel = "Case Fatality Rate"

gg.a <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.a <- gg.a + ylim(0.0,0.25)

df.aux <- data.frame(df %>% group_by(group,self) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.aa <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


pdf(file=paste(outFile,".pdf",sep=""),width=20,height = 10)
grid.arrange(gg.a,gg.b,gg.f,ncol=3,nrow=1)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=20,height = 10)
#grid.arrange(gg.aa,gg.b,ncol=2,nrow=1)
#dev.off( )



#Fate
df <- df.fate
outFile = "FigS2"
varX = "Fate"
varY = "FracFinalRecovered"
xlabel = "Fate of individuals in H compartment"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("All recover", "All die")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.e <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.e <- gg.e + ylim(0.75,1.0)

varY = "FracFinalSusceptible"
ylabel = "Fraction of susceptible population"
gg.f <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "CFR"
ylabel = "Case Fatality Rate"

gg.d <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg.d <- gg.d + ylim(0.0,0.20)

df.aux <- data.frame(df %>% group_by(group,Fate) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.dd <- do_line_plot(df.aux,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg.c <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg.b <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg.a <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 15)
grid.arrange(gg.a,gg.b,gg.c,gg.d,gg.e,gg.f,ncol=3,nrow=2)
dev.off( )

#pdf(file=paste(outFile,"_lineCFR",".pdf",sep=""),width=30,height = 15)
#grid.arrange(gg.a,gg.b,gg.c,gg.dd,gg.e,gg.f,ncol=3,nrow=2)
#dev.off( )


setwd(currentDir) #Let's finish where we started.
