# ****************************************
# SEPAIHRD-Syria_structured.R
# ****************************************
# 
# 
# author = Alberto Pascual-García, built from minimal SIR code from Eduard Campillo-Funollet
# email = alberto.pascual.garcia@gmail.com (Eduard: e.campillo-funollet@sussex.ac.uk)
# date = 27th May 2020
# description = This script computes a deterministic epidemiological model with different
#        compartments, further accounting for a structured population
#        in which the transition probabilities from one compartment to another depend on features
#        of the population that the user may want to define, for instance the age,
#        sex or comorbidities of the individuals, hereafter population "classes". The
#        scripts also implements a routine to run simulations multiple times with
#        different realizations of the parameters.
# usage = Create a directory in /data/$type_models including the following files describing
#         parameters for the classes. Not all the parameters are implemented in this way
#         because the distinction between community classes is possibly not relevant, but
#         implementing them would be straighforward. Please note that the name of the directory is expected to
#         be meaningful (related to the model implemented) and will be used for the output
#         files. The remainder epidemiological parameters are generated
#         in the code "input_parameters_SEPAIHRD.R" where vectors for the different realizations
#         of the noise are created. There are some options for the simulation explained in the section
#         options below. There are finally some computational parameters (e.g. number of realizations)
#         to be fixed by the user. These parameters are coded in a script named 
#         launch_SEPAIHRD-Syria_structured.R which should be sourced to run the present code. There
#         are other scripts labelled multiple_launch_SEPAIHRD_$experiment.R, to run the script
#         multiple times. 
# input_files = Examples of models are located in data/fake_models
#    a) 4 tab separated files with a single row and one column for each class plus the column names. The
#         classes (i.e. column names) must be the same in all files.
#   * "classes_structure": A file describing the fraction of the population that each class represents
#   *Not in current version fracPtoI_structure.csv: A file describing the expected fraction of P going to I for each class
#   * "fracItoH_structure": A file describing the fraction of infected that would be hospitalized
#   * "fracItoD_structure": A file describing the fraction of infected that would die
#    b) 1 tab-separated file with a matrix of dimensions Nclass x Nclass. The rownames and
#       colnames must exist and match the names of the classes used above. 
#   * "contacts_structure": A matrix describing the probability of contact between classes. This
#    matrix permits full flexibility to modulate the contact parameters when actions on population
#    classes are performed (e.g. "females-healthy" class interact with "shielded" class but 
#    "males-healthy" class do not). 
# examples = Run any of the models in "data/fake_models/". See README file in the directory for
#    a description.
# output_files = The script generates two types of files:
#    1. Summary files: These are files containing the mean and standard deviation across all the
#       simulations for a certain variable: $Variable_$Model_$options.dat. A plot is also generated
#       with the same name.
#    2. Dynamics files: These are files containing the whole simulations for certain realizations
#       of the parameters (the number of these files generated is controlled by the var Nfull).
#       The files are named: $Model_dynamics_$options_$realizationNum.dat, and there is also a plot with
#       the dynamics.
# options = There are different types of simulations that can be run:
#   "isolation" (mandatory) = Determine if hospitalized stay in the camp (and hence are still infectious) or
#     if are isolated outside the camp. The maximum capacity of people isolated outside the camp
#     is determined by "isoThr", all hospitalized above that value become infectious because we assume
#     they will stay in the camp. Their fate is then determined by the variable "hospitalized2".
#   "hospitalized2" = (mandatory) Determine whether all hospitalized will become recovered (=0) or death (=1) 
#   "Tcheck" (optional) = Determine whether there exist a test check (most likely Temperture) that 
#     will prevent the interaction of symptomatic people between two types of classes, identified
#     by two keywords (keywordA and keywordB). An example may be if it is created a neutral zone, in 
#     which it is assumed that to access this zone there is some testing to exclude symptomatic
#     individuals, which will reduce the probability of infection. The two keywords should be present in the names of the classes given in the 
#     input files, and will be searched with grep, so its limitations should be considered or the
#     code modified if complex regular expressions must be used.
#     
# warning = note that the structure of directories is strict. However, there is a command
#    to automatically retrieve the path of the user in the repo which may not work in Windows/Mac.
#    See comments below around the variable "this.dir", comment that specific command and fix
#    your root path manually.
#
# --- Description of parameters
# All parameters annotated as "class structured" can be specific for
# each population class and are read from external files. The remaining
# parameters can be fixed below.
# βI = bare transmission rate of people with severe symptoms
# βA = bare transmission rate of people with no/mild symptoms
# δE = exposed rate
# δP = presymptomatic rate
# η = rate from onset to hospitalized
# γI = recovery rate of people with symptoms (class structured)
# γA = recovery rate of people with no symptoms 
# γH = recovery rate of hospitalized (or dead in worst case scenario)
# α = fatality rate of people with severe symptoms (class structured)
# f = fraction of symptomatic (fracPtoI)
# h = fraction of hospitalized (fracItoH)
# g = fraction of critical (fracItoD)
# C_{u,v}=probability of interaction of an individual from class u with one of class v. 
# ... The variable "model" describes how the matrix C is built, implemented options are:
# ... "mean" -> mean field approach, C=1.
# ... "ext" -> the matrix is read from an external file

#rm(list=ls())
# Load libraries ---------
library(deSolve)   # package to solve the model
library(reshape2)  # package to change the shape of the model output
library(ggplot2)
library(rstudioapi) # package to retrieve current path, fix manually if working in Windows or outside Rstudio
library(tidyverse) # another package to reshape data for ggplot

# Fix parameters ----------------------
# .... These are the parameters related to input and output of files and computational
# .... options. Epidemiological parameters are hardcoded in the file "input_parameters_$model.R"
# .... and are not expected to be changed.
###### START EDITING
# --- Structure of directories and labelling 
# fake=0 # fix to 1 if you are working with test data 
# descr="null_model_shield" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
# class.infected="age2_no_comorbid_orange" # string with the name of the class in which the first infection is detected
# 
# # --- Computational parameters
# Npop=2000 # Population size
# Ndays=365 # Number of days simulated
# Nrand=100 # number of realizations of parameters
# 
# 
# # --- Model type
# CompModel="SEPAIHRD" # Only "SEPAIHRD" implemented 
# isolation=1 # if hospitalized leaves the camp =1, stays in the camp = 0.
# isoThr=2000 # If isolation=1, maximum capacity of H people isolation, the difference H-isoThr becomes infectious
# hospitalized2=1 # if hospitalized2 = 0, all hospitalized will recover, if = 1 all will die.
# Tcheck=0 # if tests are implemented, symptomatic individuals will be excluded from the interaction between two classes
# keywordA="orange" # keyword to identify the first population class affected by Tcheck.
# keywordB="green" # keyword to identify the second population class affected by Tcheck.
# # The following are obsolete options, can be recovered from SIRQ model if needed
# #ContMatType="mean" # one of "mean"= mean field, "external"= read from file
# #strat=0 # if ContMatType="mean" and strat= 1 it will source contact_matrix.R, where you can create manually a contacts matrix
# 
# # --- Output options
# Nfull=2 # Number of simulations whose results will be fully reported (1 to Nrand)
#
######### STOP EDITING

# Build a label with the options ---------
if(isolation == 1){
  isolation="YES"
}else{
  isolation="NO"
  isoThr=0
}
if(hospitalized2 == 1){
  hospitalized2="D"
}else{
  hospitalized2="R"
}
if(Tcheck == 1){
  Tcheck="YES"
}else{
  Tcheck="NO"
}
optLabel=paste("Isolate",isolation,"_Limit",isoThr,"_Fate",hospitalized2,"_Tcheck",Tcheck,"_PopSize",Npop,sep="")

# Fix directories ------------
if(fake == 1){
  dirTmp="/fake_models/"
}else{
  dirTmp="/real_models/"
}

# --- The following lines edit the input and output directories
# You may have problems with the following line in Windows, or if you do not run from rstudio 
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
#this.dir="/pathToRepo" # ...path to the root path of your repo if the above command does not work, comment otherwise
dirDataIn=paste(this.dir,"/data",dirTmp,descr,sep="") # Directory for the input data
dirCodeBase=paste(this.dir,"/src",sep="") # Directory where the function with the basic code is found
dirCodeSpec=paste(this.dir,"/src/",CompModel,sep="") # Directory where code specific to this model
dirDataOut=paste(this.dir,"/data",dirTmp,descr,"/",optLabel,sep="") # directory for the simulation output
dirPlotOut=paste(dirDataOut,"/figures",sep="") # directory for the figure


label=paste(CompModel,"dynamics",descr,optLabel,sep="_") # a label for your output  files
#label=paste(CompModel,"dynamics",descr,"cont",ContMatType,"PopSize",Npop,"scenario",outcome,sep="_") # a label for your output  files

# Read input data ---------
setwd(dirCodeBase)
source("read_classStructuredData_function.R")
struct.param=read_classStructuredData_function(dirDataIn)
class.str=unlist(struct.param["class.str"][[1]])
fracItoH.str=unlist(struct.param["fracItoH.str"][[1]])
fracItoD.str=unlist(struct.param["fracItoD.str"][[1]])
class.names=unlist(struct.param["class.names"][[1]])
C=(unlist(struct.param["C"][[1]]))
Nclass=length(class.str)

# Initialize the model and data  ----------
# .... Select the model and source it
setwd(dirCodeSpec)
if(CompModel == "SEPAIHRD"){ # Only this model implemented so far
  compartments=c("S","E","P","A","I","H","R","D") # 
  source("dxdt_SEPAIHRD_str.R")
  source("input_parameters_SEPAIHRD.R")
  dxdtfun=dxdt_SEPAIHRD_str
}


# --- Starting population values
setwd(dirDataIn)
Ncomp=length(compartments)
Nsubpop=as.numeric(class.str)*Npop
names(Nsubpop)=names(class.str)
y.start=matrix(0, nrow= Ncomp*Nclass,ncol=1)
var.names=c()
for(var in compartments){ # Create a vector with all the variables
  if(var == "S"){ # starting susceptible
    y.start[1:Nclass,1]=Nsubpop
  }
  var.names=c(var.names,paste(class.names,var,sep="."))
}
y.start=as.vector(y.start) # we need to work with vectors in the solver
names(y.start)=var.names
first.inf=paste(class.infected,"E",sep=".") # The class infected is initialized in the E compartment
y.start[first.inf]=1 # we initialize the first case
first.inf=paste(class.infected,"S",sep=".")
y.start[first.inf]=y.start[first.inf]-1 # substract from susceptible
hosp.idx=grep(".H$",names(y.start),perl = TRUE) # take indexes hospitalized variables, needed to estimate capacity isolation centers

# --- Create a matrix to limit the interaction of symptomatic people between certain classes
Tcheck.mat=matrix(1,ncol=ncol(C),nrow=nrow(C)) # Same size and names than the contacts matrix
rownames(Tcheck.mat)=rownames(C)
colnames(Tcheck.mat)=colnames(C)
if(Tcheck=="YES"){ # if Tcheck space exist
  idx.classA=grep(keywordA,colnames(Tcheck.mat)) # identify the classes not allowed to interact if symptoms
  idx.classB=grep(keywordB,colnames(Tcheck.mat))
  Tcheck.mat[idx.classA,idx.classB]=0 # turn them to zero
  Tcheck.mat[idx.classB,idx.classA]=0 # will only  be applied to H and I
}


# --- Finally, initialize times 
# (here, we do daily for Ndays days - you can change this value)
times_vector <- seq(from=0, to=Ndays, by=1)

# Run the model Nrand times ----------------
dir.create(dirDataOut)
setwd(dirDataOut)
k=1 # labels the number of fully reported results
rand2report=vector(mode="integer",length=Nfull) # store realization that will be reported
output.list=list()
output.aggr.list=list()
for(i in 1:Nrand){ # Launch the script Nrand times
  #betaI=betaI.vec[i]
  #betaA=betaA.vec[i]
  deltaE=deltaE.vec[i]
  deltaP=deltaP.vec[i]
  gammaA=gammaA
  gammaI=gammaI
  gammaH=gammaH.vec[i]
  eta=eta.vec[i]
  alpha=alpha.vec[i]
  tau=tau.vec[i]

  fracPtoI=fracPtoI.vec[i]
  #fracItoH.str=fracItoH.str
  #fracItoD.str=fracItoD.str
  Cont=C
  parms.list=list(Nsubpop=Nsubpop,tau=tau,deltaE=deltaE,deltaP=deltaP,
                  gammaA=gammaA,gammaI=gammaI,gammaH=gammaH,eta=eta,alpha=alpha,
                  fracPtoI=fracPtoI,fracItoH.str=fracItoH.str,fracItoD.str=fracItoD.str,
                  Cont=C,Tcheck.mat=Tcheck.mat,
                 hospitalized2=hospitalized2,isolation=isolation,isoThr=isoThr,hosp.idx=hosp.idx,
                classes=class.names,vars=var.names,compartments=compartments)
  
  # Run the ODE solver
  model.output <- as.data.frame(lsoda(y=y.start, 
                                       times=times_vector, 
                                       func=dxdtfun, 
                                       parms=parms.list))
  
  # --- Process output
  if(i == round(k*Nrand/Nfull)){
    labelTmp=paste(label,"_rand-",i,sep="")
    fileOut=paste(labelTmp,"dat",sep=".")
    write.table(model.output,file=fileOut,row.names = FALSE)
    output.list[[k]]=model.output
    rand2report[k]=i
    if(i == 1){
      warning("More than one randomization required to run this code")
    }
    u=0
    model.aggr.output=data.frame(matrix(ncol = length(compartments), 
                                        nrow = dim(model.output)[1]))
    for(comp in compartments){
      u=u+1
      comp.vars=comp.vars.list[[u]]
      var.aggr=rowSums(model.output[,comp.vars])
      model.aggr.output[,u]=var.aggr
    }
    output.aggr.list[[k]]=model.aggr.output
    k=k+1
  }
  # ..... Retrieve deaths, infectious, or any other data you may want to process across realizations
  if(i == 1){ # Prepare the dataframes in the first iteration
    u=0
    v=0
    comp.vars.list=list()
    comp.df.list=list()
    comp.time.df.list=list()
    compartments.time=c()
    for(comp in compartments){ # We will collect all max/min of variables
      u=u+1
      comp.id=paste(".",comp,"$",sep="")
      comp.vars=grep(comp.id,colnames(model.output))
      comp.vars.list[[u]]=comp.vars
      comp.names=colnames(model.output)[comp.vars]
      comp.df=data.frame(matrix(ncol = length(comp.vars), nrow = Nrand))
      colnames(comp.df)=comp.names
      comp.df.list[[u]]=comp.df
      if((comp!="D")&&(comp!="R")){ # and the times in which relevant events happen
        v=v+1
        # if(comp=="S"){ # only steady state time for all susceptible
        #   Nvars=1
        #   names.tmp=comp
        # }else{ # max for all classes
          Nvars=length(comp.vars)
          names.tmp=comp.names
        #}
        compartments.time[v]=comp
        comp.time.df=data.frame(matrix(ncol = Nvars, nrow = Nrand))
        colnames(comp.time.df)=names.tmp
        comp.time.df.list[[v]]=comp.time.df
      }
    }
  }
  # ... When each simulation finishes
  u=0
  v=0
  for(comp in compartments){ # We collect all max/min of variables
    u=u+1
    comp.vars=comp.vars.list[[u]]
    if((comp=="S")||(comp=="R")||(comp=="D")){ # and the times in which relevant events happen
      comp.out=model.output[Ndays,comp.vars]
      comp.df.list[[u]][i,]=comp.out
      if(comp=="S"){ # for susceptible
        v=v+1
        susc.traject=model.output[,comp.vars] # take the total across classes
        susc.diff=mapply(`-`,susc.traject,comp.out) # compute the differences with the end of the simulation
        susc.steady.vec=apply(susc.diff,2,function(x){min(which(x<1))}) # identify the time in which the difference with final state <1 person)
        comp.time.df.list[[v]][i,]=susc.steady.vec # store it
      }
    }else{
      v=v+1
      comp.max=apply(model.output[,comp.vars],2,max)
      comp.df.list[[u]][i,]=comp.max
      time.max=apply(model.output[,comp.vars],2,which.max)
      comp.time.df.list[[v]][i,]=time.max
    }
  }
}
# ... Retrieve some totals
u=which(compartments=="D")
death.total=round(rowSums(comp.df.list[[u]]))
u=which(compartments=="S")
susc.total=round(rowSums(comp.df.list[[u]]))
u=which(compartments=="R")
recov.total=round(rowSums(comp.df.list[[u]]))

if(test_sim == 1){ # stop the simulation here
  cat("** Simulation finished:",label)
  cat("Mean death total",mean(death.total))
  cat("Mean death total",mean(death.total))
  cat("Mean death total",mean(death.total))
  stop(">> Testing mode enabled, finishing...")
}

# Plots and outputs ------------------------
# --- Prepare some aesthetics and labels
library(RColorBrewer)
n <- (Nclass*Ncomp)+5 # there is always one too light
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_qual = rainbow(Ncomp) # unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
col_class = rainbow(n) #  c(brewer.pal(Nclass,"Set2"),brewer.pal(Nclass,"Dark2"),
              #              brewer.pal(Nclass,"Spectral"),brewer.pal(Nclass,"Accent"), 
              #             brewer.pal(Nclass,"Paired"),brewer.pal(Nclass,"Pastel1"),
              #             brewer.pal(Nclass,"Set1"),brewer.pal(Nclass,"Set3"))
#col_qual[4]="red" # col_qual[n+2] # change yellow
#col_qual[8]="black"
  # c(brewer.pal(Nclass,"Set2"),brewer.pal(Nclass,"Dark2"),
  #              brewer.pal(Nclass,"Spectral"),brewer.pal(Nclass,"Accent"), 
  #             brewer.pal(Nclass,"Paired"),brewer.pal(Nclass,"Pastel1"),
  #             brewer.pal(Nclass,"Set1"),brewer.pal(Nclass,"Set3")) # other palette
comp.descr=c("Susceptible","Exposed","Presymptomatic","Asymptomatic",
             "Infected","Hospitalized","Recovered","Deaths")
# --- Check the output, and plot dynamics
dir.create(dirPlotOut)
setwd(dirPlotOut)
for(k in 1:Nfull){ # For each realization completely recorded
  for(u in 1:2){
    if(u==1){ # Plot the whole dynamics
      model.output=output.list[[k]]
      model.names=colnames(model.output)
      filePlotOut=paste("Plot-Dynamics_",labelTmp,".pdf",sep="")
      varcolor="Class/Compartment"
      widthPlot=30
      heightPlot=12
      col_vector=col_class
    }else{ # Plot the aggregated dynamics
      model.output=output.aggr.list[[k]]
      model.output=cbind(times_vector,model.output)
      colnames(model.output)=c("time",comp.descr)
      filePlotOut=paste("Plot-DynamicsAggreg_",labelTmp,".pdf",sep="")
      varcolor="Compartment"
      heightPlot=8
      widthPlot=10
      col_vector=col_qual
    }
    output_long <- melt(as.data.frame(model.output), id = "time")
    labelTmp=paste(label,"_rand-",rand2report[k],sep="")
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
            title = element_text(size=20))+ # Increase fonts size 
      scale_colour_manual(values=col_vector)+ #and choose palette
      labs(title = paste("Model =",descr),
           subtitle = paste("Total deaths = ",death.total[rand2report[k]],
                            "; Total susceptibles = ",susc.total[rand2report[k]],
                            "; Total recovered = ",recov.total[rand2report[k]]),
           colour=varcolor) # add title
    print(gg)
    dev.off( )
  }
 
}

# --- Plot the final value for each variable
# --- Plot the proportion relative to the subpopulation for each variable
u=0
for(comp in compartments){ # We collect all max/min of variables
  u=u+1
  #fillCol=col_qual[u]
  Compartment=comp.descr[u]
  df.out=comp.df.list[[u]]
  if((comp=="S")||(comp=="R")||(comp=="D")){
    labelOut=paste("NumFinal",Compartment,"_",sep="")
  }else{
    labelOut=paste("NumMax",Compartment,"_",sep="")
  }
  setwd(dirDataOut)
  fileDataOut=paste(labelOut,label,".dat",sep="")
  write.csv(df.out,file = fileDataOut)
  setwd(dirPlotOut)
  filePlotOut=paste("Plot-",labelOut,label,".pdf",sep="")
  df.plot <- pivot_longer(df.out,cols=colnames(df.out)) # Transform long format
  colnames(df.plot)=c("class","Y")
  pdf(file=filePlotOut,width=10,height = 7)
  gg=ggplot(data = df.plot,
            aes(x = class,y = Y,fill=class)) +  # assign columns to axes and groups
    geom_boxplot()+
    #geom_bar(stat="identity") +                  # represent data as lines
    xlab("Population Class")+           # add label for x axis
    ylab(paste("Number of ",Compartment,sep="")) +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=22),
          axis.text = element_text(size=16), # ,angle=90, hjust = 1,vjust=0.5),
          legend.text = element_text(size=22),
          legend.title = element_text(size=28),
          title=element_text(size=14))+ # Increase fonts size
    scale_colour_manual(values=col_qual)+
    scale_x_discrete(labels=as.character(seq(from=1,to=Nclass,by=1)))+
    labs(title = paste("Model =",descr),
         subtitle = paste("Pop. size = ",Npop, 
                          "; Mean tot. deaths =",mean(death.total),
                          "; Mean tot. susc. =",mean(susc.total),
                          "; Mean tot. recov. =",mean(recov.total),sep=""))
  print(gg)
  dev.off( )
}
# --- Plot the proportion relative to the subpopulation for each variable
u=0
for(comp in compartments){ # We collect all max/min of variables
  u=u+1
  #fillCol=col_qual[u]
  Compartment=comp.descr[u]
  df.tmp=comp.df.list[[u]]
  df.out=100*data.frame(mapply(`/`,df.tmp,Nsubpop)) # Transform into fractions
  if((comp=="S")||(comp=="R")||(comp=="D")){
    labelOut=paste("FracFinal",Compartment,"_",sep="")
  }else{
    labelOut=paste("FracMax",Compartment,"_",sep="")
  }
  setwd(dirDataOut)
  fileDataOut=paste(labelOut,label,".dat",sep="")
  write.csv(df.out,file = fileDataOut)
  setwd(dirPlotOut)
  filePlotOut=paste("Plot-",labelOut,label,".pdf",sep="")
  df.plot <- pivot_longer(df.out,cols=colnames(df.out)) # Transform long format
  colnames(df.plot)=c("class","Y")
  pdf(file=filePlotOut,width=10,height = 7)
  gg=ggplot(data = df.plot,
            aes(x = class,y = Y,fill=class)) +  # assign columns to axes and groups
    geom_boxplot()+
    #geom_bar(stat="identity") +                  # represent data as lines
    xlab("Population Class")+           # add label for x axis
    ylab(paste(Compartment," (% of the class)",sep="")) +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=22),
          axis.text = element_text(size=16), # ,angle=90, hjust = 1,vjust=0.5),
          legend.text = element_text(size=22),
          legend.title = element_text(size=28),
          title=element_text(size=14))+ # Increase fonts size
    scale_colour_manual(values=col_qual)+
    scale_x_discrete(labels=as.character(seq(from=1,to=Nclass,by=1)))+
    labs(title = paste("Model =",descr),
         subtitle = paste("Pop. size = ",Npop, 
                          "; Mean tot. deaths =",mean(death.total),
                          "; Mean tot. susc. =",mean(susc.total),
                          "; Mean tot. recov. =",mean(recov.total),sep=""))
  print(gg)
  dev.off( )
}


# --- Plot the times at which some relevant events happen
v=0
for(comp in compartments.time){ 
  v=v+1
  Compartment.time=compartments.time[v]
  u=which(compartments==Compartment.time)
  #fillCol=col_qual[u]
  Compartment=comp.descr[u]
  df.out=comp.time.df.list[[v]]
  if(comp=="S"){
    labelOut=paste("TimeSteadyState",Compartment,"_",sep="")
    ylab="Time to steady state (days)"
  }else{
    labelOut=paste("TimePeak",Compartment,"_",sep="")
    ylab=paste("Time to maximum of",Compartment,"(days)")
  }
  setwd(dirDataOut)
  fileDataOut=paste(labelOut,label,".dat",sep="")
  write.csv(df.out,file = fileDataOut)
  setwd(dirPlotOut)
  filePlotOut=paste("Plot-",labelOut,label,".pdf",sep="")
  df.plot <- pivot_longer(df.out,cols=colnames(df.out)) # Transform long format
  colnames(df.plot)=c("class","Y")
  pdf(file=filePlotOut,width=10,height = 7)
  gg=ggplot(data = df.plot,
            aes(x = class,y = Y,fill=class)) +  # assign columns to axes and groups
    geom_boxplot()+
    #geom_bar(stat="identity") +                  # represent data as lines
    xlab("Population Class")+           # add label for x axis
    ylab(ylab) +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=22),
          axis.text = element_text(size=16), # ,angle=90, hjust = 1,vjust=0.5),
          legend.text = element_text(size=22),
          legend.title = element_text(size=28),
          title=element_text(size=14))+ # Increase fonts size
    scale_colour_manual(values=col_qual)+
    scale_x_discrete(labels=as.character(seq(from=1,to=Nclass,by=1)))+
    labs(title = paste("Model =",descr),
         subtitle = paste("Pop. size = ",Npop, 
                          "; Mean tot. deaths =",mean(death.total),
                          "; Mean tot. susc. =",mean(susc.total),
                          "; Mean tot. recov. =",mean(recov.total),sep=""))
  print(gg)
  dev.off( )
}
## Continue here, include frac death tolls, think if plots for aggregated, clean, test and go
# 
# # --- Plot the fraction of deaths
# setwd(dirDataOut)
# fileDataOut=paste("FracDeaths_",label,".dat",sep="")
# write.csv(death.frac.df,file = fileDataOut)
# setwd(dirPlotOut)
# filePlotOut=paste("Plot-FracDeaths_",label,".pdf",sep="")
# nodeath=which(colSums(death.frac.df)!=0) # Exclude classes with no deaths
# death.frac.df=death.frac.df[,nodeath]
# df.plot <- pivot_longer(death.frac.df,cols=colnames(death.frac.df)) # Transform long format
# colnames(df.plot)=c("class","deaths")
# pdf(file=filePlotOut,width=17,height = 8)
# gg=ggplot(data = df.plot,
#           aes(x = class,y = deaths)) +  # assign columns to axes and groups
#   geom_boxplot()+
#   #geom_bar(stat="identity") +                  # represent data as lines
#   xlab("Population class")+           # add label for x axis
#   ylab("Fraction of deaths (%)") +     # add label for y axis
#   theme_bw()+
#   theme(axis.title = element_text(size=16),
#         axis.text = element_text(size=12),
#         legend.text = element_text(size=16))+ # Increase fonts size
#   labs(title = paste("Model =",descr),
#        subtitle = paste("Mean total deaths =",mean(death.total),
#                         "Mean total susceptibles =",mean(susc.total),
#                         "Mean total recovered =",mean(recov.total)))
# print(gg)
# dev.off( )
