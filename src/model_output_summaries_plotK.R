# Plots for model_output_summaries.R
# Experiment K --- all interventions

# --- Now you can create some plots
setwd(dirCode)
fileExp="input_parameters_multiple_output_summaries_K.csv" # A file with the comparisons you want to do
params.df=read.table(file=fileExp,header = TRUE,sep=",") 
Ncomp=dim(params.df)[1]
cat(">> Plotting results from experiment: ",fileExp,"\n")

# ... convert into df to subset
df.out=df.output # just preventive as.data.frame(df.output,stringsAsFactors = FALSE)

# --- Subset table
df.sub = extract_subtable_output_summaries(Ncomp,df.out,params.df)

# --- Reorder levels if needed and create labels
dim(df.sub)
intervention=as.factor(seq(from=1,to=dim(df.sub)[1],by=1))
intervention.label=c("none","self 20%","isol 10","self 20% + isol 10",
                     "shield","shield + self 20%","shield + lock 50%","shield + isol 10",
                     "shield + self 20% + isol 10",
                     "shield + self 20% + isol 10 + lock 50") # missing: "shield+self20%+lock50","shield+isol10+lock50"
length(intervention.label)
df.sub=cbind(intervention,df.sub)

setwd(dirPlotOut)
levels(df.sub$intervention)
#idx.int=c(2,3,1,4,4) # reorder factors
#df.sub$lock=factor(df.sub$lock,levels(df.sub$lock)[idx.lock])
#levels(df.sub$lock)


#  Shielding for the null model, fraction of deaths
varX="intervention"
varY="NumFinalDeaths.mean" #"`P.outbrk.E`"
errY="NumFinalDeaths.stderr"
xlabel="Interventions"
ylabel="Fraction of population dying"
titlelabel="Combined strategies"
subtitleLabel=""
Npop=2000

filePlotOut=paste(varX,"Vs",varY,".pdf",sep="")
dataY=df.sub[,varY]
errX=df.sub[,varX]
errMin=df.sub[,varY]-df.sub[,errY]
errMax=df.sub[,varY]+df.sub[,errY]

pdf(file=filePlotOut,width=12,height = 12)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes_string(x = varX, y = varY),size=2)+
  geom_line(aes_string(x = varX, y = varY,group=1),color="red")+
  geom_errorbar(aes(x=errX,ymin=errMin, ymax=errMax), width=.1)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text.x = element_text(size=18,angle = 45,hjust=1,vjust = 1),
        axis.text.y = element_text(size=20),  # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete(labels=intervention.label)+
  labs(title = titlelabel,
       subtitle = paste("Pop. size = ",Npop,subtitleLabel))
print(gg)
dev.off( )


# --- Time to peak
labX="intervention"
labY="TimePeakSymptomatic"
varX=df.sub[,labX]
varY1=df.sub[,"TimePeakSymptomatic.mean.E"] #"`P.outbrk.E`"
errY1=df.sub[,"TimePeakSymptomatic.stderr.E"]
varY2=df.sub[,"TimePeakSymptomatic.mean.S"] #"`P.outbrk.E`"
errY2=df.sub[,"TimePeakSymptomatic.stderr.S"]
xlabel="Interventions"
ylabel="Time to peak of symptomatic (days)"
titlelabel="Combined strategies"
subtitleLabel=""

Npop=2000

filePlotOut=paste(labX,"Vs",labY,".pdf",sep="")
dataY=df.sub[,varY]
errX=varX
errMin1=varY1-errY1
errMax1=varY1+errY1
errMin2=varY2-errY2
errMax2=varY2+errY2

pdf(file=filePlotOut,width=12,height = 12)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes(x = varX, y = varY1, colour="exposed"),size=2)+
  geom_line(aes(x = varX, y = varY1, colour = "exposed", group=1))+
  geom_point(aes(x = varX, y = varY2,colour ="shielded"),size=2)+
  geom_line(aes(x = varX, y = varY2, colour = "shielded", group=1),show.legend = TRUE)+
  geom_errorbar(aes(x=errX,ymin=errMin1, ymax=errMax1,colour="exposed"), width=.1)+
  geom_errorbar(aes(x=errX,ymin=errMin2, ymax=errMax2,colour="shielded"), width=.1)+
  scale_color_manual("",
                     breaks=c("exposed","shielded"),
                     values =c("orange","green"))+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text.x = element_text(size=18,angle = 45,hjust=1,vjust = 1),
        axis.text.y = element_text(size=20), 
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=intervention.label)+
  labs(title = titlelabel,
       subtitle = paste("Pop. size = ",Npop,subtitleLabel))

print(gg)
dev.off( )


#  Outbreak probability
labX="intervention"
labY="P.outbrk"
varX=df.sub[,labX]
varY1=df.sub[,"P.outbrk.E"] #"`P.outbrk.E`"
#errY1=df.sub[,"P.outbrk.stderr.E"]
varY2=df.sub[,"P.outbrk.S"] #"`P.outbrk.E`"
#errY2=df.sub[,"P.outbrk.stderr.S"]
xlabel="Interventions"
ylabel="Probability outbreak"
titlelabel="Combined strategies"
subtitleLabel=""


Npop=2000

filePlotOut=paste(labX,"Vs",labY,".pdf",sep="")

# errMin1=varY1-errY1
# errMax1=varY1+errY1
# errMin2=varY2-errY2
# errMax2=varY2+errY2

pdf(file=filePlotOut,width=12,height = 12)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes(x = varX, y = varY1, colour="exposed"),size=2)+
  geom_line(aes(x = varX, y = varY1, colour = "exposed", group=1))+
  geom_point(aes(x = varX, y = varY2,colour ="shielded"),size=2)+
  geom_line(aes(x = varX, y = varY2, colour = "shielded", group=1),show.legend = TRUE)+
  #geom_errorbar(aes(x=errX,ymin=errMin1, ymax=errMax1,colour="exposed"), width=.1)+
  #geom_errorbar(aes(x=errX,ymin=errMin2, ymax=errMax2,colour="shielded"), width=.1)+
  scale_color_manual("",
                     breaks=c("exposed","shielded"),
                     values =c("orange","green"))+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text.x = element_text(size=18,angle = 45,hjust=1,vjust = 1),
        axis.text.y = element_text(size=20), 
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=intervention.label)+
  labs(title = titlelabel,
       subtitle = paste("Pop. size = ",Npop,subtitleLabel))

print(gg)
dev.off( )


#  Death fractions differentiating classes
labX="intervention"
labY="NumFinalDeaths.mean.byClass"
varX=df.sub[,labX]
varY1=df.sub[,"NumFinalDeaths.mean.E"] #"`P.outbrk.E`"
errY1=df.sub[,"NumFinalDeaths.stderr.E"]
varY2=df.sub[,"NumFinalDeaths.mean.S"] #"`P.outbrk.E`"
errY2=df.sub[,"NumFinalDeaths.stderr.S"]
xlabel="Interventions"
ylabel="Fraction population dying"
titlelabel="Combined strategies"
subtitleLabel=""

Npop=2000

filePlotOut=paste(labX,"Vs",labY,".pdf",sep="")
errX=varX
errMin1=varY1-errY1
errMax1=varY1+errY1
errMin2=varY2-errY2
errMax2=varY2+errY2

pdf(file=filePlotOut,width=12,height = 12)
gg=ggplot(data = df.sub) +  # assign columns to axes and groups
  geom_point(aes(x = varX, y = varY1, colour="exposed"),size=2)+
  geom_line(aes(x = varX, y = varY1, colour = "exposed", group=1))+
  geom_point(aes(x = varX, y = varY2,colour ="shielded"),size=2)+
  geom_line(aes(x = varX, y = varY2, colour = "shielded", group=1),show.legend = TRUE)+
  geom_errorbar(aes(x=errX,ymin=errMin1, ymax=errMax1,colour="exposed"), width=.1)+
  geom_errorbar(aes(x=errX,ymin=errMin2, ymax=errMax2,colour="shielded"), width=.1)+
  scale_color_manual("",
                     breaks=c("exposed","shielded"),
                     values =c("orange","green"))+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab(xlabel)+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=22),
        axis.text.x = element_text(size=18,angle = 45,hjust=1,vjust = 1),
        axis.text.y = element_text(size=20),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete(labels=intervention.label)+
  labs(title = titlelabel,
       subtitle = paste("Pop. size = ",Npop,subtitleLabel))

print(gg)
dev.off( )
