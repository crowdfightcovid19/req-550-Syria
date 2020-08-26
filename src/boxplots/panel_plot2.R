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

library(dplyr)

currentDir <- getwd()

source("plot_routines.R")

setwd("/home/ecam/workbench/req-550-Syria")

#ptitle <- c("boxplot","boxmean","boxmedian","vio","viomean","viomedian","ribbonsd","ribbonmedian","ribbonse")
#fplot.list <- c(do_box_plot,do_box_plot_mean,do_box_plot_median,do_vio_plot,do_vio_plot_mean,do_vio_plot_median,do_ribbon_sd,do_ribbon_quartile,do_ribbon_se)

ptitle <- c("boxmeandot")
fplot.list <- c(do_box_plot_mean_dot)



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

#intervention=as.factor(seq(from=1,to=dim(df)[1],by=1))
#intervention.label=c("none","self 20%","isol 10","self 20% + isol 10", "shield","shield + self 20%","shield + lock 50%","shield + isol 10", "shield + self 20% + isol 10", "shield + self 20% + isol 10 + lock 50")


extract_subtable_output_summariesK = function(df.out,params.df){
  Ncomp = dim(params.df)[1]
  df.sub=data.frame()
  intervention.label <- c()
  for(i in 1:Ncomp){
    contacts.var=as.character(params.df$contacts[i])
    PopSize.var=paste("PopSize",params.df$Npop[i],sep="")
    Isolate.var=paste("Isolate",params.df$Isolate[i],sep="")
    Limit.var=paste("Limit",params.df$Limit[i],sep="")
    Onset.var=paste("Onset",params.df$Onset[i],sep="")
    Fate.var=paste("Fate",params.df$Fate[i],sep="")
    Tcheck.var=paste("Tcheck",params.df$Tcheck[i],sep="")
    lock.var=paste("lock",params.df$lock[i],sep="")
    self.var=paste("self",params.df$self[i],sep="")

    df.tmp=subset(df.out, contacts==contacts.var &  Isolate==Isolate.var & 
                    Onset == Onset.var & Limit==Limit.var & Fate==Fate.var & Tcheck==Tcheck.var &
                    PopSize==PopSize.var & lock==lock.var & self==self.var)
    cnames <- colnames(df.tmp)
    df.tmp <- cbind(df.tmp,rep(params.df$scale_label[i],dim(df.tmp)[1]))
    colnames(df.tmp)<-c(cnames,"intervention")
    df.sub=rbind(df.sub,df.tmp)
  }
  return(df.sub)
}




#Extract relevant data from table
setwd(codeDir)

params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_K.csv",sep=""),header = TRUE, sep=",")
df <- extract_subtable_output_summariesK(df.all,params.df)

intervention.label <- params.df$scale_label
df$group<-factor(df$group,levels(df$group)[c(3,1,2)])
df$intervention<-factor(df$intervention,intervention.label)


setwd(outPlotDir)

varX="intervention"
xlabel="Intervention"
scale_x_labels <- intervention.label
scale_fill_labels <- c("Total","Exposed Zone", "Safety Zone")
group_name = "Group"

gg.Poutbreak <- do_line_plot(df,varPoutbreak,varX,"",ytitPoutbreak,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE)+
                 theme(axis.text.x = element_blank())
gg.FracDeath <- do_box_plot_mean_dot(df,varFracDeath,varX,"",ytitFracDeath,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)+
                 theme(axis.text.x = element_blank())
gg.TimePeak <- do_box_plot_mean_dot(df,varPeak,varX,xlabel,ytitPeak,scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)+
                 theme(axis.text.x = element_text(size=axis.text.size,angle=45,hjust=1,vjust=1))

pdf(file="Fig3.pdf",width=30,height=30)
grid.arrange(gg.Poutbreak,gg.FracDeath,gg.TimePeak,nrow=3,ncol=1,heights=c(1,1,1.8))
dev.off( )

gg.b <- do_box_plot_mean_dot(df,"FracFinalRecovered",varX,"","Fraction of the population recoreved",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)+
                 theme(axis.text.x = element_text(size=axis.text.size,angle=45,hjust=1,vjust=1))

df.aux <- data.frame(df %>% group_by(group,intervention) %>% summarise(CFR = mean(NumFinalDeaths)/mean(NumFinalDeaths+NumFinalRecovered)))

gg.aa <- do_line_plot(df.aux,"CFR",varX,"","Case Fatality Rate","mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)+
        theme(axis.text.x= element_blank() )+
        theme(  legend.position = "top",
                    legend.text = element_text(size=legend.text.size),
                    legend.title = element_blank())

gg.a <- do_box_plot_mean_dot(df,"CFR",varX,"","Case Fatality Rate",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)+
        theme(axis.text.x= element_blank() )+
        theme(  legend.position = "top",
                    legend.text = element_text(size=legend.text.size),
                    legend.title = element_blank())

df$NumFinalCases <- df$NumFinalDeaths + df$NumFinalRecovered
df.thres <- data.frame(df %>% group_by(intervention,group) %>% summarise(low = sum(NumFinalCases < 15),total=length(NumFinalCases))) 
df.thres$prob <- 1 - (df.thres$total - df.thres$low)/500

gg.c <- do_line_plot(df.thres,"prob",varX,"","Safety effectiveness","identity",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)+
        theme(axis.text.x= element_blank() )



pdf(file="Fig_Sinterventions.pdf",width=30,height=30)
grid.arrange(gg.a,gg.b,nrow=2,ncol=1,heights=c(1,1.5))
dev.off( )


pdf(file="Fig_Sinterventions_lineCFR.pdf",width=30,height=30)
grid.arrange(gg.aa,gg.b,nrow=2,ncol=1,heights=c(1,1.5))
dev.off( )

pdf(file="Fig_Sinterventions_safety_effectiveness.pdf",width=30,height=30)
grid.arrange(gg.a,gg.c,gg.b,nrow=3,ncol=1,heights=c(1,1,1.5))
dev.off( )




setwd(currentDir) #Let's finish where we started.
