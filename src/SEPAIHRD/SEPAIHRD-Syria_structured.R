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
#        different realizations of the parameters. There are three modes of simulation, either
#        deterministic, stochastic with the parameters fixed for each realization, or stochastic
#        with the parameter varying for each time step. The latter version is the one
#        possibly closer to reality but it also takes longer times to run.
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
#   "isolation" = Determine if hospitalized stay in the camp (and hence are still infectious) or
#     if are evacuated outside the camp. all hospitalized above that value become infectious because we assume
#     they will stay in the camp. Their fate is then determined by the variable "hospitalized2".
#   "isoThr" =  This parameter determine if there are individual tents available to facilitate the quarantine
#      of mild symptomatic individuals. It should  be a number between 1 and the total population size.
#   "onset" = This parameter determines if individuals isolated spend some time between their symptoms
#      and their self-isolation. If equal to 0 they isolate immediately, other options are 1, 12 or 24h. No
#      further options are considered because, for each value, a probability distribution was considered and
#      hard-coded.
#   "hospitalized2" =  Determine whether all hospitalized will become recovered (=0) or if they die (=1) 
#   "Tcheck" (optional) = Determine whether there exist a test check (most likely "T"emperature, = 1) that 
#     will prevent the interaction of symptomatic people between two types of classes, identified
#     by two keywords (keywordA and keywordB). Set to (=0) otherwise. An example comes from safety zones, in 
#     which it is assumed that to access this zone there is some testing to exclude symptomatic
#     individuals, which will reduce the probability of infection. The two keywords should be present in the names of the classes given in the 
#     input files, and will be searched with grep, so its limitations should be considered or the
#     code modified if complex regular expressions must be used.
#   "lockDown" = Determines if the shielded zone is locked after the first symptomatic case in the non-shielded
#       zone is provided. Set it to (=0) if there is no lockdown and to a number between 0 and 1 if there is
#       lockDown. This number should represent you estimation on which would be the reduction in the number
#       of contacts between both populations (shielded or not) due to the lockdown, e.g. 0.9 for 90% reduction
#    "self" = Self is similar in spirit to lockDown, but it applies to the whole population. It is a parameter
#      modelling the reduction in the number of contacts that each individual will experience if self-distancing
#      measures were implemented. Set self=0 for no self-distancing and 1>self>0 for the %-reduced.
#    "xi" = Is a parameter to determine the reduction in the probability of infection per contact if contention
#      measures (masks, gloves, additional distance) are put in place between carers and people isolated in tents.
#      The same parameter is used in the estimation of the contacts between classes in the safety zone when
#      shielding is implemented. This estimation is performed in Management_matrix_construction.R and the equivalent
#      parameter there is called RR and fixed to 0.2, which is teh default also here.
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


# Build a label with the options ---------
if(isolation == 1){
  isolation="YES"
  Hinfect=0 # Hospitalized become non-infectious
}else{
  isolation="NO"
  Hinfect=1 # Hospitalized are infectious
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
if(lockDown > 0){
  lockLabel=lockDown
  lockValue=1-lockDown
  lockDown="YES"
}else{
  lockValue=1
  lockDown="NO"
  lockLabel="NO"
}
if(self > 0){
  selfLabel=self
  self=1-self # A factor multiplying the number of contacts
}else{
  self=1
  selfLabel="NO"
}
if(model.type=="deterministic"){
  MT="D"
}else if(model.type=="stochastic_fixed"){
  MT="SF"
}else{ # stochastic variable
  MT="SV"
}
optLabel=paste("Isolate",isolation,"_Limit",isoThr,"_Onset",onset,"_Fate",hospitalized2,
               "_Tcheck",Tcheck,"_PopSize",Npop,
               "_lock",lockLabel,"_self",selfLabel,"_mod",MT,sep="")

# Fix directories ------------
if(fake == 1){
  dirTmp="/fake_models/"
}else{
  dirTmp="/real_models/"
}

# --- The following lines edit the input and output directories
# You may have problems with the following line in Windows, or if you do not run from rstudio
#this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
this.dir="~/Nextcloud/Militancia/crowdfightcovid19/Projects/Request550-Syria/req-550-Syria"
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
  if(onset==0){
    compartments=c("S","E","P","A","I","H","R","D") # 
  }else{
    compartments=c("S","E","P","A","O","I","H","R","D") # isolation requires one more comp.
  }
  if(model.type=="deterministic"){
    source("dxdt_SEPAIHRD_str.R")
    dxdtfun=dxdt_SEPAIHRD_str
  }else{ # the model is stochastic
    source("rates_SEPAIHRD_str.R")
    dxdtfun=rates_SEPAIHRD_str
  }
  #set.seed(18062020) # Today, store for reproducibility
  set.seed(13072020) # Today, store for reproducibility
  source("input_parameters_SEPAIHRD.R")
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
inf.idx=grep(".I$",names(y.start),perl = TRUE) # take indexes infectious variables, needed to estimate capacity isolation centers
if(onset > 0){ # not used
  ons.idx=grep(".O$",names(y.start),perl = TRUE)
}
hosp.idx=grep(".H$",names(y.start),perl = TRUE) # take indexes hospitalized variables, needed to estimate capacity isolation centers
#browser()

# --- Create a matrix to limit contacts between symptomatic people of one class and population of selected classes
Tcheck.mat=matrix(1,ncol=ncol(C),nrow=nrow(C)) # Same size and names than the contacts matrix
rownames(Tcheck.mat)=rownames(C)
colnames(Tcheck.mat)=colnames(C)
if(Tcheck=="YES"){ # if Tcheck space exist
  idx.classA=grep(keywordA,colnames(Tcheck.mat)) # identify the classes not allowed to interact if symptoms
  idx.classB=grep(keywordB,colnames(Tcheck.mat))
  Tcheck.mat[idx.classA,idx.classB]=0 # turn them to zero
  Tcheck.mat[idx.classB,idx.classA]=0 # will only  be applied to H and I
}

# --- Create a matrix to limit contacts between selected classes if a lockdown is imposed
carers.mat=matrix(0,ncol=ncol(C),nrow=nrow(C)) # Same size and names than the contacts matrix
rownames(carers.mat)=rownames(C)
colnames(carers.mat)=colnames(C)
if(isoThr > 0){ # if there are tents available, we need carers
  carers.mat[class.carers,]=1 # turn them to one the interaction between the carers class and all the others
}

# --- Create a matrix to determine the interaction between isolated in tents and the class assigned as carers
lock.mat=matrix(1,ncol=ncol(C),nrow=nrow(C)) # Same size and names than the contacts matrix
rownames(lock.mat)=rownames(C)
colnames(lock.mat)=colnames(C)
if(lockDown=="YES"){ # if it is possible a lockdown
  lock.mat[idx.classA,idx.classB]=lockValue # turn them to zero
  lock.mat[idx.classB,idx.classA]=lockValue # will be applied to all classes
}

# --- Finally, initialize times and stochastic transitions
# (here, we do daily for Ndays days - you can change this value)
times_vector <- seq(from=0, to=Ndays, by=1)
if((model.type=="stochastic_fixed")||(model.type=="stochastic_variable")){
  setwd(dirCodeSpec)
  if(onset == 0){
    source("make_transitions.R")
    transitions=make_transitions(class.names,var.names,hospitalized2)
  }else{ # An additional onset compartment  is introduced
    source("make_transitions_iso.R")
    transitions=make_transitions_iso(class.names,var.names,hospitalized2)
  }
  Ntrans=length(transitions)[1]/Nclass
  y.start=round(y.start)
}

 
# Run the model Nrealiz times ----------------
dir.create(dirDataOut)
setwd(dirDataOut)
k=1 # labels the number of fully reported results
rand2report=vector(mode="integer",length=Nfull) # store realization that will be reported
output.list=list()
output.aggr.list=list()
for(i in 1:Nrealiz){ # Launch the script Nrealiz times
  #betaI=betaI.vec[i]
  #betaA=betaA.vec[i]
  if((model.type=="deterministic")||(model.type=="stochastic_fixed")){
    deltaE=deltaE.vec[i]
    deltaP=deltaP.vec[i]
    deltaO=deltaO.vec[i]
    gammaO=gammaO.vec[i]
    gammaI=gammaI.vec[i]
    gammaH=gammaH.vec[i]
    eta=eta.vec[i]
    etaO=etaO.vec[i]
    alphaO=alphaO.vec[i]
    alpha=alpha.vec[i]
    betaP=betaP.vec[i]
    betaA=betaA.vec[i]
    betaI=betaI.vec[i]
    betaH=betaH.vec[i]
    tau=tau.vec[i]
    fracPtoI=fracPtoI.vec[i]
  }else{ # stochastic variable
    setwd(dirCodeSpec) # These three lines should be optimized
    source("input_parameters_SEPAIHRD.R") # should be converted into a function
    setwd(dirDataOut)
    t.int=0 # this variable will be global
    # Generates new parameters each realization
    deltaE=deltaE.vec
    deltaP=deltaP.vec
    deltaO=deltaO.vec
    gammaO=gammaO.vec
    gammaI=gammaI.vec
    gammaH=gammaH.vec
    eta=eta.vec
    etaO=etaO.vec
    alphaO=alphaO.vec
    alpha=alpha.vec
    tau=tau.vec
    betaP=betaP.vec
    betaA=betaA.vec
    betaI=betaI.vec
    betaH=betaH.vec
    fracPtoI=fracPtoI.vec
  }

  gammaA=gammaA
  Cont=C
  parms.list=list(Nsubpop=Nsubpop,Ntrans=Ntrans,model.type=model.type,
                  tau=tau,betaP=betaP,betaA=betaA,betaI=betaI,betaH=betaH,
                  deltaE=deltaE,deltaP=deltaP,deltaO=deltaO,
                  gammaA=gammaA,gammaO=gammaO,gammaI=gammaI,gammaH=gammaH,
                  eta=eta,etaO=etaO,alphaO=alphaO,alpha=alpha,
                  fracPtoI=fracPtoI,fracItoH.str=fracItoH.str,fracItoD.str=fracItoD.str,
                  Cont=C,Tcheck.mat=Tcheck.mat,lockDown=lockDown,lock.mat=lock.mat,self=self,
                  hospitalized2=hospitalized2,Hinfect=Hinfect,
                  onset=onset,isoThr=isoThr,xi=xi,carers.mat=carers.mat,
                  inf.idx=inf.idx,hosp.idx=hosp.idx,
                  classes=class.names,vars=var.names,compartments=compartments)
  
  # Run the ODE solver
  if((model.type=="stochastic_fixed")||(model.type=="stochastic_variable")){
    #dxdtfun=rates_SEPAIHRD_str
      model.output=as.data.frame(ssa.adaptivetau(init.values =y.start,
                    transitions=transitions,
                    rateFunc =dxdtfun, 
                    params=parms.list, 
                    tf=Ndays))
  }else{
    model.output <- as.data.frame(lsoda(y=y.start, 
                                        times=times_vector, 
                                        func=dxdtfun, 
                                        parms=parms.list))
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
      comp.id=paste("\\.",comp,"$",sep="")
      comp.vars=grep(comp.id,colnames(model.output))
      comp.vars.list[[u]]=comp.vars
      comp.names=colnames(model.output)[comp.vars]
      comp.df=data.frame(matrix(ncol = length(comp.vars), nrow = Nrealiz))
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
        comp.time.df=data.frame(matrix(ncol = Nvars, nrow = Nrealiz))
        colnames(comp.time.df)=names.tmp
        comp.time.df.list[[v]]=comp.time.df
      }
    }
  }
  # --- Process output
  if(i == round(k*Nrealiz/Nfull)){
    labelTmp=paste(label,"_rand-",i,sep="")
    fileOut=paste(labelTmp,"dat",sep=".")
    write.table(model.output,file=fileOut,row.names = FALSE)
    output.list[[k]]=model.output
    rand2report[k]=i
    if((i == 1)&(Nrealiz != Nfull)){
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
  # ... When each simulation finishes
  u=0
  v=0
  for(comp in compartments){ # We collect all max/min of variables
    u=u+1
    comp.vars=comp.vars.list[[u]]
    if((comp=="S")||(comp=="R")||(comp=="D")){ # and the times in which relevant events happen
      time_final_local=length(model.output$time)
      comp.out=model.output[time_final_local,comp.vars]
      comp.df.list[[u]][i,]=comp.out
      if(comp=="S"){ # for susceptible
        v=v+1
        susc.traject=model.output[,comp.vars] # take the total across classes
        susc.diff=mapply(`-`,susc.traject,comp.out) # compute the differences with the end of the simulation
        if(model.type=="deterministic"){
          susc.steady.vec=apply(susc.diff,2,function(x){min(which(x<1))}) # identify the time in which the difference with final state <1 person)
        }else{
          time.tmp=apply(susc.diff,2,function(x){min(which(x==0))}) # identify the time in which the difference with final state <1 person)
          susc.steady.vec=model.output$time[time.tmp]
        }
        comp.time.df.list[[v]][i,]=susc.steady.vec # store it
      }
    }else{
      v=v+1
      comp.max=apply(model.output[,comp.vars],2,max)
      comp.df.list[[u]][i,]=comp.max
      id.time.max=apply(model.output[,comp.vars],2,which.max)
      time.max=model.output$time[id.time.max]
      comp.time.df.list[[v]][i,]=time.max
    }
  }
}
# ... Retrieve some totals
u=which(compartments=="D")
death.total=round(rowSums(comp.df.list[[u]]))
frac.nodeath=apply(comp.df.list[[u]],2,function(x){length(which(x==0))})/Nrealiz
# frac.nodeath.df=data.frame(names(frac.nodeath),frac.nodeath,-2) # The df must be created within the loops below to gather the vars appropriately
#colnames(frac.nodeath.df)=c("class","nodeath","Y")
u=which(compartments=="S")
susc.total=round(rowSums(comp.df.list[[u]]))
u=which(compartments=="R")
recov.total=round(rowSums(comp.df.list[[u]]))

if(test_sim == 1){ # stop the simulation here
  cat("** Simulation finished:",label,"\n")
  cat("Mean death total",mean(death.total),"\n")
  cat("Mean susc total",mean(susc.total),"\n")
  cat("Mean recov total",mean(recov.total),"\n")
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
if(onset==0){
  comp.descr=c("Susceptible","Exposed","Presymptomatic","Asymptomatic",
               "Symptomatic","Hospitalized","Recovered","Deaths")
}else{
  comp.descr=c("Susceptible","Exposed","Presymptomatic","Asymptomatic",
               "Symp_Onset-stage","Symp_Iso-stage","Hospitalized","Recovered","Deaths")
}

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
      times_vector_local=model.output$time
    }else{ # Plot the aggregated dynamics
      model.output=output.aggr.list[[k]]
      model.output=cbind(times_vector_local,model.output)
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
            title = element_text(size=9))+ # Increase fonts size 
      scale_colour_manual(values=col_vector)+ #and choose palette
      labs(title = paste("Model =",descr,optLabel),
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
setwd(dirCodeBase)
source("create_palette.R")
setwd(dirPlotOut)
col_qual=create_palette(descr)
u=0
for(comp in compartments){ # We collect all max/min of variables
  u=u+1
  #fillCol=col_qual[u]
  Compartment=comp.descr[u]
  df.out=comp.df.list[[u]]
  frac.nodeath.df=data.frame(colnames(df.out),frac.nodeath,-10) # to annotate this properly, the names should be the same
  colnames(frac.nodeath.df)=c("class","nodeath","Y")
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
  df.plot.drop=df.plot
  df.plot.drop[df.plot==0]=NA # Exclude zeros for the boxplot
  pdf(file=filePlotOut,width=10,height = 7)
  gg=ggplot(data = df.plot,
            aes(x = class,y = Y)) +  # assign columns to axes and groups
    geom_boxplot(data = df.plot.drop,
                 aes(x = class,y = Y))+
    geom_jitter(show.legend = TRUE,
                aes(colour=class),height = 0,width=0.2)+
    geom_text(data=frac.nodeath.df,
              aes(x=class,
              y=Y,
              label=nodeath),inherit.aes = TRUE)+
    #geom_bar(stat="identity") +                  # represent data as lines
    xlab("Population Class")+           # add label for x axis
    ylab(paste("Number of ",Compartment,sep="")) +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=22),
          axis.text = element_text(size=16), # ,angle=90, hjust = 1,vjust=0.5),
          legend.text = element_text(size=22),
          legend.title = element_text(size=28),
          title=element_text(size=9))+ # Increase fonts size
    scale_colour_manual(values=col_qual)+
    scale_x_discrete(labels=as.character(seq(from=1,to=Nclass,by=1)))+
    labs(title = paste("Model =",descr,optLabel),
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
  frac.nodeath.df=data.frame(colnames(df.out),frac.nodeath,-2) # to annotate this properly, the names should be the same
  colnames(frac.nodeath.df)=c("class","nodeath","Y")
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
  df.plot.drop=df.plot
  df.plot.drop[df.plot==0]=NA # Exclude zeros for the boxplot
  pdf(file=filePlotOut,width=10,height = 7)
  gg=ggplot(data = df.plot,
            aes(x = class,y = Y)) +  # assign columns to axes and groups
    geom_boxplot(data = df.plot.drop,
                 aes(x = class,y = Y))+
    geom_jitter(show.legend = TRUE,
                aes(colour=class),height = 0,width=0.2)+
    geom_text(data=frac.nodeath.df,
              aes(x=class,
                  y=Y,
                  label=nodeath),inherit.aes = TRUE)+
    #geom_bar(stat="identity") +                  # represent data as lines
    xlab("Population Class")+           # add label for x axis
    ylab(paste(Compartment," (% of the class)",sep="")) +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=22),
          axis.text = element_text(size=16), # ,angle=90, hjust = 1,vjust=0.5),
          legend.text = element_text(size=22),
          legend.title = element_text(size=28),
          title=element_text(size=9))+ # Increase fonts size
    scale_colour_manual(values=col_qual)+
    scale_x_discrete(labels=as.character(seq(from=1,to=Nclass,by=1)))+
    labs(title = paste("Model =",descr,optLabel),
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
  frac.nodeath.df=data.frame(colnames(df.out),frac.nodeath,-10) # to annotate this properly, the names should be the same
  colnames(frac.nodeath.df)=c("class","nodeath","Y")
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
  df.plot.drop=df.plot
  df.plot.drop[df.plot==0]=NA # Exclude zeros for the boxplot
  pdf(file=filePlotOut,width=10,height = 7)
  gg=ggplot(data = df.plot,
            aes(x = class,y = Y)) +  # assign columns to axes and groups
    geom_boxplot(data = df.plot.drop,
                 aes(x = class,y = Y))+
    geom_jitter(show.legend = TRUE,
                aes(colour=class),height = 0,width=0.2)+
    geom_text(data=frac.nodeath.df,
              aes(x=class,
                  y=Y,
                  label=nodeath),inherit.aes = TRUE)+
    #geom_bar(stat="identity") +                  # represent data as lines
    xlab("Population Class")+           # add label for x axis
    ylab(ylab) +     # add label for y axis
    theme_bw()+
    theme(axis.title = element_text(size=22),
          axis.text = element_text(size=16), # ,angle=90, hjust = 1,vjust=0.5),
          legend.text = element_text(size=22),
          legend.title = element_text(size=28),
          title=element_text(size=9))+ # Increase fonts size
    scale_colour_manual(values=col_qual)+
    scale_x_discrete(labels=as.character(seq(from=1,to=Nclass,by=1)))+
    labs(title = paste("Model =",descr,optLabel),
         subtitle = paste("Pop. size = ",Npop, 
                          "; Mean tot. deaths =",mean(death.total),
                          "; Mean tot. susc. =",mean(susc.total),
                          "; Mean tot. recov. =",mean(recov.total),sep=""))
  print(gg)
  dev.off( )
}

cat("** Simulation finished:",label,"\n")
cat("Mean death total",mean(death.total),"\n")
cat("Mean susc total",mean(susc.total),"\n")
cat("Mean recov total",mean(recov.total),"\n")
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
