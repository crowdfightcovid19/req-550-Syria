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

setwd("/home/ecam/workbench/req-550-Syria")

#ptitle <- c("boxplot","boxmean","boxmedian","vio","viomean","viomedian","ribbonsd","ribbonmedian","ribbonse")
#fplot.list <- c(do_box_plot,do_box_plot_mean,do_box_plot_median,do_vio_plot,do_vio_plot_mean,do_vio_plot_median,do_ribbon_sd,do_ribbon_quartile,do_ribbon_se)

ptitle <- c("Fig2")
fplot.list <- c(do_box_plot_mean_dot)



inset.size = 18 
title.size = 50

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

idx.contacts <- c(1,2,5,3,4,6,7)
df.shield$contacts<-factor(df.shield$contacts,levels(df.shield$contacts)[idx.contacts])

idx.group <- c(3,1,2)
df.shield$group<-factor(df.shield$group,levels(df.shield$group)[idx.group])

idx.limit<- c(1,2,5,7,3,6,8,4)
df.iso$Limit<-factor(df.iso$Limit,levels(df.iso$Limit)[idx.limit])

idx.self<- c(3,1,2)
df.self$self<-factor(df.self$self,levels(df.self$self)[idx.self])

setwd(outPlotDir)

for(i in 1:length(ptitle)){
    title <- ptitle[i]
    fplot <- fplot.list[[i]]

    #Shielding
    varX="contacts"
    xlabel="Number of contacts per week/individual"
    scale_x_labels <- c("No limit","10","2")
    scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
    group_name = "Group"

    #gg.Poutbreak.shield <- do_line_plot(df.shield,varPoutbreak,varX,xlabel,ytitPoutbreak,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
    #gg.FracDeath.shield <- fplot(df.shield,varFracDeath,varX,xlabel,ytitFracDeath,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    #gg.TimePeak.shield <- fplot(df.shield,varPeak,varX,xlabel,ytitPeak,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

    gg.Poutbreak.shield <- do_line_plot(df.shield,varPoutbreak,varX,"","","mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)
    gg.FracDeath.shield <- fplot(df.shield,varFracDeath,varX,"","",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    gg.TimePeak.shield <- fplot(df.shield,varPeak,varX,xlabel,"",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

    gg.Poutbreak.shield <- gg.Poutbreak.shield+annotate('text',label="G",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)
    gg.FracDeath.shield <- gg.FracDeath.shield+annotate('text',label="H",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)
    gg.TimePeak.shield <- gg.TimePeak.shield+annotate('text',label="I",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)

    #Isolation
    varX="Limit"
    xlabel="Number of self-isolation tents"
    scale_x_labels <- c("0","10","25","50","100","250","500","2000")
    scale_fill_labels <- c("Total")
    group_name = "Group"

    #gg.Poutbreak.iso <- do_line_plot(df.iso,varPoutbreak,varX,xlabel,ytitPoutbreak,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    #gg.FracDeath.iso <- fplot(df.iso,varFracDeath,varX,xlabel,ytitFracDeath,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    #gg.TimePeak.iso <- fplot(df.iso,varPeak,varX,xlabel,ytitPeak,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

    gg.Poutbreak.iso <- do_line_plot(df.iso,varPoutbreak,varX,"","","mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    gg.FracDeath.iso <- fplot(df.iso,varFracDeath,varX,"","",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    gg.TimePeak.iso <- fplot(df.iso,varPeak,varX,xlabel,"",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

    gg.Poutbreak.iso<- gg.Poutbreak.iso+annotate('text',label="D",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)
    gg.FracDeath.iso<- gg.FracDeath.iso+annotate('text',label="E",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)
    gg.TimePeak.iso<- gg.TimePeak.iso+annotate('text',label="F",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)



    #Self
    varX="self"
    xlabel="Individual reduction of contacts per day (%)"
    scale_x_labels <- c("0","20","50")
    scale_fill_labels <- c("Total")
    group_name = "Group"

    #gg.Poutbreak.self <- do_line_plot(df.self,varPoutbreak,varX,xlabel,ytitPoutbreak,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    #gg.FracDeath.self <- fplot(df.self,varFracDeath,varX,xlabel,ytitFracDeath,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    #gg.TimePeak.self <- fplot(df.self,varPeak,varX,xlabel,ytitPeak,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

    gg.Poutbreak.self <- do_line_plot(df.self,varPoutbreak,varX,"",ytitPoutbreak,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    gg.FracDeath.self <- fplot(df.self,varFracDeath,varX,"",ytitFracDeath,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)
    gg.TimePeak.self <- fplot(df.self,varPeak,varX,xlabel,ytitPeak,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)

    gg.Poutbreak.self<- gg.Poutbreak.self+annotate('text',label="A",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)
    gg.FracDeath.self<- gg.FracDeath.self+annotate('text',label="B",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)
    gg.TimePeak.self<- gg.TimePeak.self+annotate('text',label="C",x=-Inf,y=Inf,hjust=0,vjust=1,size=inset.size)


    #pdf(file=paste(title,".pdf",sep=""),width=27,height = 21)
    #grid.arrange(gg.Poutbreak.shield,gg.FracDeath.shield,gg.TimePeak.shield,gg.Poutbreak.iso,gg.FracDeath.iso,gg.TimePeak.iso,gg.Poutbreak.self,gg.FracDeath.self,gg.TimePeak.self,nrow=3,ncol=3)
    pdf(file=paste(title,".pdf",sep=""),width=32,height = 25)
    #grid.arrange(gg.Poutbreak.shield,gg.Poutbreak.iso,gg.Poutbreak.self,gg.FracDeath.shield,gg.FracDeath.iso,gg.FracDeath.self,gg.TimePeak.shield,gg.TimePeak.iso,gg.TimePeak.self,nrow=3,ncol=3)
    grid.arrange(arrangeGrob(gg.Poutbreak.self,top=textGrob("Self-distancing",gp=gpar(fontsize=title.size))),arrangeGrob(gg.Poutbreak.iso,top=textGrob("Isolation",gp=gpar(fontsize=title.size))),arrangeGrob(gg.Poutbreak.shield,top=textGrob("Safety zone",gp=gpar(fontsize=title.size))),gg.FracDeath.self,gg.FracDeath.iso,gg.FracDeath.shield,gg.TimePeak.self,gg.TimePeak.iso,gg.TimePeak.shield,nrow=3,ncol=3)
    dev.off( )


}

setwd(currentDir) #Let's finish where we started.
