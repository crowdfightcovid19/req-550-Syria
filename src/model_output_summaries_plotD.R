# Plots for model_output_summaries.R
# Experiment B --- self-isolation in tents -- null model

# --- Now you can create some plots
setwd(dirCode)
fileExp="input_parameters_multiple_output_summaries_B.csv" # A file with the comparisons you want to do
params.df=read.table(file=fileExp,header = TRUE,sep=",") 
Ncomp=dim(params.df)[1]

# ... convert into df to subset
df.out=df.output # just preventive as.data.frame(df.output,stringsAsFactors = FALSE)

# --- Subset table
df.sub = extract_subtable_output_summaries(Ncomp,df.out,params.df)

# --- Reorder levels if needed
setwd(dirPlotOut)
levels(df.sub$Limit)
# idx.self=c(3,1,2) # reorder levels
# df.sub$self=factor(df.sub$self,levels(df.sub$self)[idx.self])
# levels(df.sub$self)


#  Self distancing for the null model, fraction of deaths
varX="Limit"
varY="NumFinalDeaths.mean" #"`P.outbrk.E`"
errY="NumFinalDeaths.stderr"
xlabel="Isolation capacity (individuals)"
ylabel="Fraction of population dying"
titlelabel="Isolation"
Npop=2000

filePlotOut=paste(varX,"Vs",varY,".pdf",sep="")
dataY=df.sub[,varY]
errX=df.sub[,varX]
errMin=df.sub[,varY]-df.sub[,errY]
errMax=df.sub[,varY]+df.sub[,errY]

pdf(file=filePlotOut,width=9,height = 7)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes_string(x = varX, y = varY),size=2)+
  geom_line(aes_string(x = varX, y = varY,group=1),color="red")+
  geom_errorbar(aes(x=errX,ymin=errMin, ymax=errMax), width=.1)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop))
print(gg)
dev.off( )


#  time to peak
varX="Limit"
varY="TimePeakInfected.mean" #"`P.outbrk.E`"
errY="TimePeakInfected.stderr"
xlabel="Isolation capacity (individuals)"
ylabel="Time to peak of infected (days)"
titlelabel="Isolation"

Npop=2000

filePlotOut=paste(varX,"Vs",varY,".pdf",sep="")
dataY=df.sub[,varY]
errX=df.sub[,varX]
errMin=df.sub[,varY]-df.sub[,errY]
errMax=df.sub[,varY]+df.sub[,errY]

pdf(file=filePlotOut,width=9,height = 7)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes_string(x = varX, y = varY),size=2)+
  geom_line(aes_string(x = varX, y = varY,group=1),color="red")+
  geom_errorbar(aes(x=errX,ymin=errMin, ymax=errMax), width=.1)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop))
print(gg)
dev.off( )


#  Probability outbreak
varX="Limit"
varY="P.outbrk.E" #"`P.outbrk.E`"
#errY="TimePeakInfected.stderr"
xlabel="Isolation capacity (individuals)"
ylabel="Probability outbreak"
titlelabel="Isolation"

Npop=2000

filePlotOut=paste(varX,"Vs",varY,".pdf",sep="")
dataY=df.sub[,varY]
errX=df.sub[,varX]
errMin=df.sub[,varY]-df.sub[,errY]
errMax=df.sub[,varY]+df.sub[,errY]

pdf(file=filePlotOut,width=9,height = 7)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes_string(x = varX, y = varY),size=2)+
  geom_line(aes_string(x = varX, y = varY,group=1),color="red")+
  #geom_errorbar(aes(x=errX,ymin=errMin, ymax=errMax), width=.1)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=c("0","10","25","50","100"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop))
print(gg)
dev.off( )
