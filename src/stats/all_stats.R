# ****************************************
# all_stats.R
# ****************************************
# ****************************************
# author = Eduard Campill-Funollet
# email = e.campillo-funollet@sussex.ac.uk
# date = 22nd August 2020
# description = Stats summaries for experiment results
# usage = Run from src/stats. Produces a table in /data/real_models/results_post_processing

currentDir <- getwd()

library(gtools) #Star significance

#Output filename
ofile <- "global_stats_summary.csv"

#Load data
setwd("/home/ecam/workbench/req-550-Syria")

#Directories
baseDir <- getwd()
codeDir <- paste(baseDir,"/src",sep="")
dataDir <- paste(baseDir,"/data/real_models",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")
outPlotDir <- paste(baseDir,"/manuscripts/main/figures/newFig",sep="")

setwd(paste(codeDir,"/boxplots",sep=""))

source("plot_routines.R") #For data loading methods

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



#Output dataframe (empty dataframe with col names)
#odf <- data.frame(fig=NA,name=NA,varX=NA,varY=NA,group=NA,pvalue=NA,significance=NA,barlettp=NA,bartlett=NA,Welchp=NA,WelchSig=NA,shapirop=NA,shapiro=NA,kruskalp=NA,kruskalSig=NA)[-1,]
odf <- data.frame(fig=NA,name=NA,varX=NA,varY=NA,group=NA,pvalue=NA,significance=NA,barlettp=NA,bartlett=NA,Welchp=NA,WelchSig=NA,kruskalp=NA,kruskalSig=NA)[-1,]

#Returns 1 or 0 indicating Homogeneity of Var (1) or not (0) for 0.05 significance
getBartlett <- function(p){
    if(p < 0.05)
        return( 0 );
    return( 1 );
}

figs <- c("FigS2","FigS3","FigS4","FigS5","FigS6","FigS7","FigS8","FigS9","FigS10","FigS11")
names <- c("Fate","Self","Iso. tents","Onset","Evacuation","Checks in buffer","Saftety zone","Classes in safety","Population","Lockdown buffer")
variables = c("Fate","self","Limit","Onset","intervention","intervention","contacts","contacts","intervention","lock")
tables <- list(df.fate,df.self,df.iso,df.onset,df.evac,df.tcheckElderly,df.shield,df.shieldlimit,df.tcheck,df.lock)
groups <- c("T","E","S")
varsY <- c("FracFinalDeaths","TimePeakSymptomatic","FracFinalRecovered","CFR")

for (i in 1:length(figs)){      
    fig <- figs[i]
    name <- names[i]
    varX <- variables[i]
    table <- tables[[i]]
    for(varY in varsY){
        for(g in groups){
            df <- subset(table,group==g)
            if(dim(df)[1] == 0){
                next    
            }
            form <- formula(paste(varY,varX,sep=" ~ "))

            #ANOVA
            res.aov <- aov(form,data=df)

            #Extract p-value
            p <- unlist(summary(res.aov))["Pr(>F)1"] 

            #Star significance
            s <- stars.pval(p)[1]

            #Do Bartlett (Homogeneity of variances)
            res.bar <- bartlett.test(form, data = df)

            pbar <- unlist(res.bar)[["p.value"]]
            bar <- getBartlett(as.numeric(pbar))


            #Welch test (when no equal variances)
            res.owt <- oneway.test(form, data=df)
            pwel <- unlist(res.owt)[["p.value"]]
            swel <- stars.pval(as.numeric(pwel))[1]

            #Normality of residuals
            #aov_residuals <- residuals(object = res.aov)
            #res.sha <- shapiro.test(x = aov_residuals)
            #psha <- unlist(res.sha)[["p.value"]]
            #sha <- getBartlett(as.numeric(psha))

            #Kruskal (if normality fails)
            res.kru <- kruskal.test(form,data=df)
            pkru <- unlist(res.kru)[["p.value"]]
            skru <- stars.pval(as.numeric(pkru))[1]

            #Add row to output dataframe.
            #odf[nrow(odf)+1,] <- c(fig,name,varX,varY,g,p,s,pbar,bar,pwel,swel,psha,sha,pkru,skru)
            odf[nrow(odf)+1,] <- c(fig,name,varX,varY,g,p,s,pbar,bar,pwel,swel,pkru,skru)
        } 
    }
}
setwd(outDir)

write.csv(odf,ofile)

setwd(currentDir)
