# Plots for model_output_summaries.R
# shielding

# --- Now you can create some plots
setwd(dirCode)
fileExp="input_parameters_multiple_output_summaries_B.csv" # A file with the comparisons you want to do
params.df=read.table(file=fileExp,header = TRUE,sep=",") 
Ncomp=dim(params.df)[1]

# ... convert into df to subset
df.out=df.output # just preventive as.data.frame(df.output,stringsAsFactors = FALSE)

df.sub=data.frame()
for(i in 1:Ncomp){
  contacts.var=as.character(params.df$contacts[i])
  PopSize.var=paste("PopSize",params.df$Npop[i],sep="")
  Isolate.var=paste("Isolate",params.df$Isolate[i],sep="")
  Limit.var=paste("Limit",params.df$Limit[i],sep="")
  Fate.var=paste("Fate",params.df$Fate[i],sep="")
  Tcheck.var=paste("Tcheck",params.df$Tcheck[i],sep="")
  lock.var=paste("lock",params.df$lock[i],sep="")
  self.var=paste("self",params.df$self[i],sep="")
  
  df.tmp=subset(df.out, contacts==contacts.var &  Isolate==Isolate.var &
                  Limit==Limit.var & Fate==Fate.var & Tcheck==Tcheck.var &
                  PopSize==PopSize.var & lock==lock.var & self==self.var)
  
  df.sub=rbind(df.sub,df.tmp)
}

setwd(dirPlotOut)
levels(df.sub$contacts)
# idx.self=c(1,1,2) # not needed
#df.sub$self=factor(df.sub$self,levels(df.sub$self)[idx.self])
#levels(df.sub$self)


#  Shielding for the null model, fraction of deaths
varX="contacts"
varY="NumFinalDeaths.mean" #"`P.outbrk.E`"
errY="NumFinalDeaths.stderr"
xlabel="Number of contacts per week/individual"
ylabel="Fraction of population dying"
titlelabel="Shielding"
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
  scale_x_discrete( labels=c("No limit","10","2"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop))
print(gg)
dev.off( )


#  Self distancing for the null model, time to peak
labX="contacts"
labY="TimePeakInfected"
varX=df.sub[,"contacts"]
varY1=df.sub[,"TimePeakInfected.mean.E"] #"`P.outbrk.E`"
errY1=df.sub[,"TimePeakInfected.stderr.E"]
varY2=df.sub[,"TimePeakInfected.mean.S"] #"`P.outbrk.E`"
errY2=df.sub[,"TimePeakInfected.stderr.S"]
xlabel="Number of contacts per week/individual"
ylabel="Time to peak of infected (days)"
titlelabel="Shielding"
Npop=2000

filePlotOut=paste(labX,"Vs",labY,".pdf",sep="")
dataY=df.sub[,varY]
errX=varX
errMin1=varY1-errY1
errMax1=varY1+errY1
errMin2=varY2-errY2
errMax2=varY2+errY2

pdf(file=filePlotOut,width=9,height = 7)
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
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=c("No limit","10","2"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop,sep=""),
       colour="Pop. class")
       
print(gg)
dev.off( )


#  Outbreak probability
labX="contacts"
labY="P.outbrk"
varX=df.sub[,"contacts"]
varY1=df.sub[,"P.outbrk.E"] #"`P.outbrk.E`"
#errY1=df.sub[,"P.outbrk.stderr.E"]
varY2=df.sub[,"P.outbrk.S"] #"`P.outbrk.E`"
#errY2=df.sub[,"P.outbrk.stderr.S"]
xlabel="Number of contacts per week/individual"
ylabel="Probability outbreak"
titlelabel="Shielding"
Npop=2000

filePlotOut=paste(labX,"Vs",labY,".pdf",sep="")

# errMin1=varY1-errY1
# errMax1=varY1+errY1
# errMin2=varY2-errY2
# errMax2=varY2+errY2

pdf(file=filePlotOut,width=9,height = 7)
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
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=c("No limit","10","2"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop,sep=""),
       colour="Pop. class")

print(gg)
dev.off( )


#  Death fractions differentiating classes
labX="contacts"
labY="NumFinalDeaths.mean.byClass"
varX=df.sub[,"contacts"]
varY1=df.sub[,"NumFinalDeaths.mean.E"] #"`P.outbrk.E`"
errY1=df.sub[,"NumFinalDeaths.stderr.E"]
varY2=df.sub[,"NumFinalDeaths.mean.S"] #"`P.outbrk.E`"
errY2=df.sub[,"NumFinalDeaths.stderr.S"]
xlabel="Number of contacts per week/individual"
ylabel="Fraction population dying"
titlelabel="Shielding"
Npop=2000

filePlotOut=paste(labX,"Vs",labY,".pdf",sep="")
errX=varX
errMin1=varY1-errY1
errMax1=varY1+errY1
errMin2=varY2-errY2
errMax2=varY2+errY2

pdf(file=filePlotOut,width=9,height = 7)
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
        axis.text = element_text(size=20), # ,angle=90, hjust = 1,vjust=0.5),
        legend.text = element_text(size=22),
        legend.title = element_text(size=28),
        title=element_text(size=16))+ # Increase fonts size
  #scale_colour_manual(values=col_qual)+
  scale_x_discrete( labels=c("No limit","10","2"))+
  labs(title = titlelabel,
       subtitle = paste("Population. size = ",Npop,sep=""),
       colour="Pop. class")

print(gg)
dev.off( )
