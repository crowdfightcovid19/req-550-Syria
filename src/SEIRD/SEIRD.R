
rm(list=ls())
#library(deSolve)   # package to solve the model
library(reshape2)  # package to change the shape of the model output
library(ggplot2)
library(rstudioapi) # package to retrieve current path, fix manually if working in Windows or outside Rstudio
library(tidyverse) 
library(adaptivetau)

###### START EDITING
Nrand=10000 # number of random values generated for one realization
Npop=0 # size susceptible
Nexp=1000 # number of starting exposed
Nrealiz=100 # number of realizations of the whole model
Nfull=5 # number of full realizations to store
Ndays=100
model.type="stochastic_variable" # "stochastic_fixed" or"stochastic_variable"
model.rate="caseA" # "caseA" or "caseB"
fix.seed=6062021 # today, a seed for reproducibility

### STOP EDITING
label=paste("SEIRD",model.rate,model.type,sep="_")
set.seed(fix.seed)
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
dirCodeBase=paste(this.dir,"/src/SEIRD",sep="") # Directory where the function with the basic code is found
dirDataOut=paste(this.dir,"/data/fake_models/SEIRD",sep="") # directory for the simulation output
dirPlotOut=paste(dirDataOut,"/figures",sep="")

if(!dir.exists(dirDataOut)){dir.create(dirDataOut)}
if(!dir.exists(dirPlotOut)){dir.create(dirPlotOut)}

# --- Load ODE function
setwd(dirCodeBase)
source("rates_SEIRD.R")
dxdtfun=rates_SEIRD

# --- Set up the model depending on the case considered
S="S"; E="E"; I="I"; IR="IR"; ID="ID"; R="R"; D="D"
if(model.rate == "caseA"){
  y.start=c(Npop,Nexp,0,0,0)
  var.names=c(S,E,I,R,D)
  names(y.start)=var.names
  A=cbind(rbind(S,-1,E,+1), # This matrix lists all the transitions for class Ref
          rbind(E,-1,I,+1),
          rbind(I,-1,R,+1), 
          rbind(I,-1,D,+1))
}else{
  y.start=c(Npop,Nexp,0,0,0,0)
  var.names=c(S,E,IR,ID,R,D)
  names(y.start)=var.names
  A=cbind(rbind(S,-1,E,+1),
          rbind(E,-1,IR,+1), # This matrix lists all the transitions for class Ref
          rbind(E,-1,ID,+1), 
          rbind(IR,-1,R,+1), 
          rbind(ID,-1,D,+1))
}

Ntrans=dim(A)[1]
transitions=ssa.maketrans(var.names,A) # Create the transitions list

setwd(dirCodeBase) # These three lines should be optimized
source("input_parameters_SEIRD.R")
source("residence_times.R")
setwd(dirDataOut)

g.out=vector("numeric",length = Nrealiz)
rand2report=vector("numeric",length=Nfull)
output.list=list()
k=1
for(i in 1:Nrealiz){ # Launch the script Nrealiz times
  #betaI=betaI.vec[i]
  #betaA=betaA.vec[i]
  if(model.type=="stochastic_fixed"){
    gammaR=gammaR.vec[i]
    gammaD=gammaD.vec[i]
    tau=tau.vec[i]
  }else{ # stochastic variable
    setwd(dirCodeBase) # These three lines should be optimized
    source("input_parameters_SEIRD.R") # should be converted into a function
    setwd(dirDataOut)
    t.int=0 # this variable will be global
    # Generates new parameters each realization
    gammaR=gammaR.vec
    gammaD=gammaD.vec
    tau=tau.vec
  }
  parms.list=list(Ntrans=Ntrans,model.rate=model.rate,
                  g=g,betaI=betaI,tau=tau,
                  gammaR=gammaR,gammaD=gammaD)
  model.output=as.data.frame(ssa.adaptivetau(init.values =y.start,
                                             transitions=transitions,
                                             rateFunc =dxdtfun, 
                                             params=parms.list, 
                                             tf=Ndays))
  # --- extract outputs
  Nsteps=dim(model.output)[1]
  g.out[i]=model.output$R[Nsteps]/Nexp # retrieve the final prop of recovered
  if(model.rate == "caseA"){
    res.objects=residence_times(model.output)
    res.time.summ=res.objects[[1]]
    res.time.summ=as.data.frame(t(res.time.summ$mean))
    colnames(res.time.summ)=c("D","R")
    if(i == 1){
      res.time.df=res.time.summ
    }else{
      res.time.df=rbind(res.time.df,res.time.summ)
    }
  }
  # -- Save some simulations to plot
  if(i == round(k*Nrealiz/Nfull)){
    labelTmp=paste(label,"_rand-",i,sep="")
    fileOut=paste(labelTmp,"dat",sep=".")
    write.table(model.output,file=fileOut,row.names = FALSE)
    output.list[[k]]=model.output
    rand2report[k]=
    k=k+1
    if((i == 1)&(Nrealiz != Nfull)){
      warning("More than one randomization required to run this code")
    }
  }
}

if(model.rate == "caseA"){
  print("residence times:")
  print(colMeans(res.time.df))
}
print("proportion of recovered")
print(mean(g.out))

# --- Check the output, and plot dynamics
dir.create(dirPlotOut)
setwd(dirPlotOut)

for(k in 1:Nfull){ # For each realization completely recorded
  labelTmp=paste(label,"_rand-",rand2report[k],sep="")
  model.output=output.list[[k]]
  if(model.rate == "classB"){
    model.output$I=model.output$IR+model.output$ID
  }
  model.names=colnames(model.output)
  filePlotOut=paste("Plot-Dynamics_",labelTmp,".pdf",sep="")
  varcolor="Compartment"
  widthPlot=15
  heightPlot=12
  n = ncol(model.output)
  col_class = rainbow(n)
  col_vector=col_class
  times_vector_local=model.output$time
  output_long <- melt(as.data.frame(model.output), id = "time")
  pdf(file=filePlotOut,width=widthPlot,height = heightPlot)
  gg=ggplot(data = output_long,
            aes(x = time,
                y = value,
                colour = variable,
                group = variable)) +  # assign columns to axes and groups
    geom_line(size=1.5) +                  # represent data as lines
    xlab("Time (days)")+           # add label for x axis
    ylab("Number of people") +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=20),
          axis.text = element_text(size=14),
          legend.text = element_text(size=16),
          legend.title = element_text(size=22),
          title = element_text(size=9))+ # Increase fonts size 
    scale_colour_manual(values=col_vector)#+ #and choose palette
  # labs(title = paste("Model =",descr,optLabel),
  #      subtitle = paste("Total deaths = ",death.total[rand2report[k]],
  #                       "; Total susceptibles = ",susc.total[rand2report[k]],
  #                       "; Total recovered = ",recov.total[rand2report[k]]),
  #      colour=varcolor) # add title
  print(gg)
  dev.off( )
}


