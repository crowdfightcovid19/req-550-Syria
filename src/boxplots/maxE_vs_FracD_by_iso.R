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

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_H2.csv",sep=""),header = TRUE, sep=",")
df.self <- extract_subtable_output_summaries(df.all,params.df)

idx.self<- c(10,1,2,3,4,5,6,7,8,9)
df.self$self<-factor(df.self$self,levels(df.self$self)[idx.self])

df.self$FracMaxExposed <- df.self$FracMaxExposed / 100. #Fraction, rather than %.

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_B.csv",sep=""),header = TRUE, sep=",")
df.iso <- extract_subtable_output_summaries(df.all,params.df)
idx.limit<- c(1,2,5,7,3,6,8,4)
df.iso$Limit<-factor(df.iso$Limit,levels(df.iso$Limit)[idx.limit])
df.iso$FracMaxExposed <- df.iso$FracMaxExposed / 100. #Fraction, rather than %.


##Self distancing
#df <- df.self
#outFile = "MaxExposed_vs_TimePeak_by_self-distancing"
#varX = "TimePeakSymptomatic"
#varY = "FracMaxExposed"
#xlabel = "Time to peak symptomatic (days)"
#ylabel = "Max. fraction of population exposed"
##scale_x_labels <- c("0","10","20","30","40","50")
#scale_color_labels <- c("0%","10%","20%","30%","40%","50%","60%","70%","80%","90%")
#group_name = "Reduction of contacts"
#
#gg <-ggplot(df,aes(x=TimePeakSymptomatic,y=FracMaxExposed))+
#     geom_point(aes(colour=self,size=FracFinalDeaths),alpha=0.6)+
#     scale_color_discrete(name=group_name,labels=scale_color_labels)+
#     scale_size(breaks=c(0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.10,0.11),
#                       labels=c("0.01","0.02","0.03","0.04","0.05","0.06","0.07","0.08","0.09","0.10","0.11"),
#                       range=c(1,10),
#                       name="Fraction of population dying")+
#     xlab(xlabel)+
#     ylab(ylabel)+
#     guides(color = guide_legend(override.aes = list(size = 5)))+
#     theme( legend.text = element_text(size=legend.text.size),
#            legend.title = element_text(size=legend.title.size),
#            axis.text = element_text(size=axis.text.size),
#            axis.title = element_text(size=axis.title.size),
#            panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "lightgrey"),
#            panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "lightgrey"),
#            panel.background = element_rect(fill = "white", colour = "black", linetype = "solid"))
#
#
#setwd(outPlotDir)
#pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 20,title=outFile)
#print(gg)
#dev.off( )
#
#Self isolation
df <- df.iso
outFile = "finalD_vs_maxE_by_self-isolation"
xlabel = "Max. fraction of population exposed"
ylabel = "Fraction of population dying"
#scale_x_labels <- c("0","10","20","30","40","50")
scale_color_labels <- c("0","10","25","50","100","250","500","2000")
group_name = "Number of self-isolation tents"

gg <-ggplot(df,aes(x=FracMaxExposed,y=FracFinalDeaths))+
     geom_point(aes(colour=Limit),alpha=0.6)+
     scale_color_discrete(name=group_name,labels=scale_color_labels,type=c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7","#E69AA0"))+
     xlab(xlabel)+
     ylab(ylabel)+
     guides(color = guide_legend(override.aes = list(size = 5)))+
     theme( legend.text = element_text(size=legend.text.size),
            legend.title = element_text(size=legend.title.size),
            axis.text = element_text(size=axis.text.size),
            axis.title = element_text(size=axis.title.size),
            panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "lightgrey"),
            panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "lightgrey"),
            panel.background = element_rect(fill = "white", colour = "black", linetype = "solid"))


setwd(outPlotDir)
pdf(file=paste(outFile,".pdf",sep=""),width=30,height = 20,title=outFile)
print(gg)
dev.off( )


setwd(currentDir) #Let's finish where we started.
