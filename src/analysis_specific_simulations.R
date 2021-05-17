#***************************************
# analysis_specific_simulations.R
#***************************************
#
#
#author = Alberto Pascual-García
#email = alberto.pascual.garcia@gmail.com
#date = 11th March 2021
#description = This script compares two simulations by plotting a specific variable
#         selected present in both (i.e. it cannot plot onset vs symptomatic). It cannot
#         handle either simulations with different behavioural classes
#usage = Edit required fields and run

library(reshape2)
library(ggplot2)

### START EDIT
rand1="250"
rand2="250"

dirSim1="IsolateNO_Limit10_Onset24_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV"
dirSim2="IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV" 
fileSim1=paste("SEPAIHRD_dynamics_null_model_mixed_IsolateNO_Limit10_Onset24_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV_rand-",rand1,".dat",sep="")
fileSim2=paste("SEPAIHRD_dynamics_null_model_mixed_IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV_rand-",rand2,".dat",sep="")

sim1_label=paste("Limit10_Onset24_rand",rand1,sep="")
sim2_label=paste("null_model_mixed_rand",rand2,sep="")

sel.var="D"
descr.var="PopDead"
ylabel="Population dying"
# sel.var="E"
# descr.var="PopExposed"
# ylabel="Population exposed"

### STOP EDIT

# --- Move to directory and retrieve list of directories
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1]
dirCode=paste(this.dir,"/src",sep="")
dirData=paste(this.dir,"/data/real_models/",sep="")
dirSim=paste(dirData,"null_model_mixed/",sep="")
dirOut=paste(dirData,"results_post_processing",sep="")
dirPlotOut=paste(dirOut,"/Specific_simul_compar",sep="")
setwd(dirSim)

fileIn1=paste(dirSim1,fileSim1,sep="/")
fileIn2=paste(dirSim2,fileSim2,sep="/")

# --- Read simulations
Nmax=3100 # Number of points we will compare both simulations
sim1=read.table(fileIn1,header = TRUE)#,sep=",")
sim2=read.table(fileIn2,header = TRUE)

Nmax1=max(which(sim1$time < 80))
Nmax2=max(which(sim2$time < 80))
sim1=sim1[1:Nmax1,]
sim2=sim2[1:Nmax2,]

#plot(sim)
#plot(sim1$time,sim2$time)

sim1=data.frame(sim1,rep("isolation",times=dim(sim1)[1]))
sim2=data.frame(sim2,rep("null model",times=dim(sim2)[1]))
colnames(sim1)[ncol(sim1)]="simulation"
colnames(sim2)[ncol(sim2)]="simulation"
#colnames(sim1)=paste(colnames(sim1[2:length(colnames(sim1))]),"iso",sep=".")
#colnames(sim2)=paste(colnames(sim2[2:length(colnames(sim1))]),"null",sep=".")
#df.all=cbind(sim1[1:Nmax,],sim2[1:Nmax,])


sel.var=paste(".",sel.var,"$",sep="")
#sel.idx=grep(sel.var,names(df.all),perl = TRUE)
sel.idx.sim1=grep(sel.var,names(sim1),perl = TRUE)
sel.idx.sim2=grep(sel.var,names(sim2),perl = TRUE)

#df.sel=df.all[,c(1,sel.idx)]
sim1.sel=sim1[,c(1,sel.idx.sim1,dim(sim1)[2])]
sim2.sel=sim2[,c(1,sel.idx.sim2,dim(sim2)[2])]

df.sel=rbind(sim1.sel,sim2.sel)

output_long <- melt(as.data.frame(df.sel), id = c("time","simulation"))
output_long = cbind(output_long,paste(output_long$variable,
                                      output_long$simulation,sep="_"))
colnames(output_long)[ncol(output_long)]="variable_simulation"
#labelTmp=paste(label,"_rand-",rand2report[k],sep="")
filePlotOut=paste("PlotCompareSim_",sim1_label,"_VS_",sim2_label,"_",descr.var,".pdf",sep="")
widthPlot=15; heightPlot=8
setwd(dirPlotOut)
pdf(file=filePlotOut,width=widthPlot,height = heightPlot)
gg=ggplot(data = output_long, #df.sel, #output_long,
          aes(x = time,
              y = value, #age2_no_comorbid.E,
              colour = variable))+#, #simulation,
              #group = simulation)) +  # assign columns to axes and groups
  geom_line(size=1.5,aes(linetype = simulation)) +                  # represent data as lines
  xlab("Time (days)")+           # add label for x axis
  ylab(ylabel) +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=20),
        axis.text = element_text(size=14),
        legend.text = element_text(size=16),
        legend.title = element_text(size=22),
        title = element_text(size=9))#+ # Increase fonts size 
  #scale_colour_manual(values=col_vector)+ #and choose palette
  #labs(title = paste("Model =",descr,optLabel),
  #     subtitle = paste("Total deaths = ",death.total[rand2report[k]],
  #                      "; Total susceptibles = ",susc.total[rand2report[k]],
  #                      "; Total recovered = ",recov.total[rand2report[k]]),
  #     colour=varcolor) # add title
print(gg)
dev.off( )
