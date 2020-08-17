#***************************************
#extend_table_results.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 30th July 2020
#description = Process plots for expA. TODO: significance
#usage = Run from src/

currentDir <- getwd()
setwd("/home/ecam/workbench/req-550-Syria/src")

#By Alberto
extract_subtable_output_summaries = function(df.out,params.df){
  Ncomp = dim(params.df)[1]
  df.sub=data.frame()
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
    df.sub=rbind(df.sub,df.tmp)
  }
  return(df.sub)
}


#Directories
setwd("..")
baseDir <- getwd()
codeDir <- paste(baseDir,"/src",sep="")
dataDir <- paste(baseDir,"/data/real_models",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")

idDir="modSV" # this is a string contained in all the directories that should be processed
fileIn=paste("extended_results_table_",idDir,".csv",sep="")

df.all <- read.csv(paste(outDir,"/",fileIn,sep=""))

#Extract relevant data from table
setwd(codeDir)
params.df <- read.table(file=paste(codeDir,"/","input_parameters_multiple_output_summaries_B.csv",sep=""),header = TRUE, sep=",")

df <- extract_subtable_output_summaries(df.all,params.df)

#Pre-process table: null model mixed everyone is exposed. We do not want totals.

#idx.nullmixed <- which( df$contacts == "null_model_mixed" )
#df$group[ idx.nullmixed ] <- rep("E",length(idx.nullmixed) )
#
#df.tmp <- subset(df, group != "T")
#
#df<- rbind(data.frame(),df.tmp) 
#
setwd(codeDir)

#df$Limit <- as.factor(df$Limit)
levels(df$Limit)

fn = "FracFinalDeaths"
varX="limit"
varY="fracdeath" 
xlabel="Isolation capacity (individuals)"
ylabel="Fraction of population dying"
titlelabel="Isolation"
Npop=2000

filePlotOut=paste(fn,"_",varX,"Vs",varY,"_","box",".pdf",sep="")
pdf(file=filePlotOut,width=9,height = 7)
dodge <- position_dodge(width = 0.9)
gg=ggplot(data=df)+
  #geom_jitter(size=0.4,alpha=0.5,aes_string(x="contacts",y=fn,colour="group"),position=position_jitter(width=.05))+
  geom_point(position=position_jitterdodge(dodge.width=0.9),aes_string(x="Limit",y=fn,colour="group"))+
  geom_boxplot(aes_string(x="Limit",y=fn,fill="group"),position=dodge)+
  xlab(xlabel)+
  ylab(ylabel)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  #theme(legend.position="none",
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
        labs(title=titlelabel,subtitle=paste("Population size = ",Npop))

print(gg)
dev.off( )

filePlotOut=paste(fn,"_",varX,"Vs",varY,"_","vio",".pdf",sep="")
pdf(file=filePlotOut,width=9,height = 7)
gg=ggplot(data=df)+
  geom_violin(aes_string(x="Limit",y=fn,fill="group"))+
  #geom_jitter(size=0.4,alpha=0.5,aes_string(x="contacts",y=fn,group="group"))+
  xlab(xlabel)+
  ylab(ylabel)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  #theme(legend.position="none",
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
        labs(title=titlelabel,subtitle=paste("Population size = ",Npop))

print(gg)
dev.off( )

fn = "TimePeakSymptomatic"
varX="limit"
varY="fracdeath" 
xlabel="Isolation capacity (individuals)"
ylabel="Fraction of population dying"
titlelabel="Isolation"
Npop=2000

filePlotOut=paste(fn,"_",varX,"Vs",varY,"_","box",".pdf",sep="")
pdf(file=filePlotOut,width=9,height = 7)
dodge <- position_dodge(width = 0.9)
gg=ggplot(data=df)+
  #geom_jitter(size=0.4,alpha=0.5,aes_string(x="contacts",y=fn,colour="group"),position=position_jitter(width=.05))+
  geom_point(position=position_jitterdodge(dodge.width=0.9),aes_string(x="Limit",y=fn,colour="group"))+
  geom_boxplot(aes_string(x="Limit",y=fn,fill="group"),position=dodge)+
  xlab(xlabel)+
  ylab(ylabel)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  #theme(legend.position="none",
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
        labs(title=titlelabel,subtitle=paste("Population size = ",Npop))

print(gg)
dev.off( )

filePlotOut=paste(fn,"_",varX,"Vs",varY,"_","vio",".pdf",sep="")
pdf(file=filePlotOut,width=9,height = 7)
gg=ggplot(data=df)+
  geom_violin(aes_string(x="Limit",y=fn,fill="group"))+
  #geom_jitter(size=0.4,alpha=0.5,aes_string(x="contacts",y=fn,group="group"))+
  xlab(xlabel)+
  ylab(ylabel)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  #theme(legend.position="none",
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
        labs(title=titlelabel,subtitle=paste("Population size = ",Npop))

print(gg)
dev.off( )


setwd(currentDir) #Let's finish where we started.
