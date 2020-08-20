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

setwd("/home/ec365/workbench/req-550-Syria")

#ptitle <- c("boxplot","boxmean","boxmedian","vio","viomean","viomedian","ribbonsd","ribbonmedian","ribbonse")
#fplot.list <- c(do_box_plot,do_box_plot_mean,do_box_plot_median,do_vio_plot,do_vio_plot_mean,do_vio_plot_median,do_ribbon_sd,do_ribbon_quartile,do_ribbon_se)

ptitle <- c("boxmeandot")
fplot.list <- c(do_box_plot_mean_dot)

axis.text.size = 16 
axis.title.size = 18 
legend.title.size = 18 
legend.text.size = 16
axis.text.x.size = 16
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
outPlotDir <- paste(baseDir,"/manuscripts/main/figures/newSMfig",sep="")

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
outFile = "FigS11e"
varX = "lock"
varY = "FracFinalRecovered"
xlabel = "Reduction of number of contacts buffering zone (%)"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("0","50","90","99")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+ylim(0.5,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS11d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+ylim(0.0,0.25)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS11c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS11b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df.lock,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS11a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df.lock,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Effect of number of individuals per camp
outFile = "FigS10e"
varX = "intervention"
varY = "FracFinalRecovered"
xlabel = "Model/Number of individuals in the camp"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("null/500","null/1000","null/2000","safety 2/500","safety 2/1000","safety 2/2000")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.5,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS10d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.0,0.35)
pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS10c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS10b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df.tcheck,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS10a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df.tcheck,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Effect of number of individuals per camp
df <- df.shieldlimit
outFile = "FigS9e"
varX = "contacts"
varY = "FracFinalRecovered"
xlabel = "Population classes in safety zone"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("Elderly","Elder. + adult w. comorb.","Elder. + adults + kids (< 20%)","Elder. + adults + kids (< 25%)","Elder. + adults + kids (< 30%)")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.25,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS9d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.0,0.75)
pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS9c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS9b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS9a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Safety zone
df <- df.shield
outFile = "FigS8b"
varX = "contacts"
varY = "FracFinalRecovered"
xlabel = "Number of contacts per week/individual"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("No limit","10","2")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg <- gg + ylim(0.5,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS8a"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg <- gg + ylim(0.0,0.40)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Checks in buffer zone
df <- df.tcheckElderly
outFile = "FigS7e"
varX = "intervention"
varY = "FracFinalRecovered"
xlabel = "Contacts per week and individual / Health checks"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("10 cont. (no checks)", "10 cont. + checks", "2 cont. (no checks)", "2 cont. + checks")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.5,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS7d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.0,0.4)
pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS7c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS7b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS7a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Evac
df <- df.evac
outFile = "FigS6e"
varX = "intervention"
varY = "FracFinalRecovered"
xlabel = "Model / Evacuation"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("null / NO","null / YES", "safety 2 / NO", "safety 2 / YES") 
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.5,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS6d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.0,0.4)
pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS6c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS6b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS6a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Onset
df <- df.onset
outFile = "FigS5e"
varX = "Onset"
varY = "FracFinalRecovered"
xlabel = "Time to self-isolation (h)"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("No isol.", "12", "24", "48")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.75,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS5d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.0,0.25)
pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS5c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS5b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS5a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#No. isolation tents
df <- df.iso
outFile = "FigS4b"
varX = "Limit"
varY = "FracFinalRecovered"
xlabel = "Number of self-isolation tents"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("0","10","25","50","100","250","500","2000")
scale_fill_labels <- c("Total")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg <- gg + ylim(0.75,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS4a"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg <- gg + ylim(0.0,0.20)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Self distancing
df <- df.self
outFile = "FigS3b"
varX = "self"
varY = "FracFinalRecovered"
xlabel = "Individual reduction of contacts per day (%)"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("0","20","50")
scale_fill_labels <- c("Total")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg <- gg + ylim(0.5,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS3a"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
gg <- gg + ylim(0.0,0.25)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

#Fate
df <- df.fate
outFile = "FigS2e"
varX = "Fate"
varY = "FracFinalRecovered"
xlabel = "Fate of individuals in H compartment"
ylabel = "Fraction of population recovered"
scale_x_labels <- c("All recover", "All die")
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.75,1.0)

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS2d"
varY = "CFR"
ylabel = "Case Fatality Rate"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg<- gg + ylim(0.0,0.20)
pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS2c"
varY = "TimePeakSymptomatic"
ylabel = "Time to peak of symptomatic (days)"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS2b"
varY = "FracFinalDeaths"
ylabel = "Fraction of population dying"

gg <- do_box_plot_mean_dot(df,varY,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )

outFile = "FigS2a"
varY = "POutbreak"
ylabel = "Probability of Outbreak"

gg <- do_line_plot(df,varY,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
#gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

pdf(file=paste(outFile,".pdf",sep=""),width=9,height = 7)
print(gg)
dev.off( )






setwd(currentDir) #Let's finish where we started.
