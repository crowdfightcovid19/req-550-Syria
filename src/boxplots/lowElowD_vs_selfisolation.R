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

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_B.csv",sep=""),header = TRUE, sep=",")
df.iso <- extract_subtable_output_summaries(df.all,params.df)
idx.limit<- c(1,2,5,7,3,6,8,4)
df.iso$Limit<-factor(df.iso$Limit,levels(df.iso$Limit)[idx.limit])
df.iso$FracMaxExposed <- df.iso$FracMaxExposed / 100. #Fraction, rather than %.

odf <- data.frame(Limit=NA,total=NA,fracD=NA,lowED=NA,lowEDfraction=NA)[-1,]
for(s in levels(df.iso$Limit)){
   df.aux <- subset(df.iso, Limit == s)
   total = nrow(df.aux)
   df.lowe <- subset(df.aux,FracMaxExposed <=0.05)
   for(d in c(0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.10,0.11)){
        lowED <- nrow(subset(df.lowe,FracFinalDeaths>d-0.01 & FracFinalDeaths < d ))
        lowEDfraction <- lowED / total 
        odf[nrow(odf)+1,] <- c(s,total,d,lowED,lowEDfraction)
   }
}

odf$Limit <- factor(odf$Limit)
odf$Limit <-factor(odf$Limit,levels(odf$Limit)[idx.limit])
odf$lowEDfraction <- as.numeric(odf$lowEDfraction)
odf$fracD <- factor(odf$fracD)


outFile = "Eoutbreaks_vs_self-isolation"
xlabel = "Number of self-isolation tents"
ylabel = "Fraction of simulations with low exposed outbreaks"

gg <- ggplot(odf,aes(x=Limit,y=lowEDfraction,fill=fracD))+geom_bar(stat="identity")+
      xlab(xlabel)+
      ylab(ylabel)+
      scale_fill_discrete(labels=c("<0.01","<0.02","<0.03","<0.04","<0.05","<0.06","<0.07","<0.08","<0.09","<0.10","<0.11"),name="Fraction of population dying")+
      scale_y_continuous(labels=function(x) sprintf("%.3f",x))+
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
