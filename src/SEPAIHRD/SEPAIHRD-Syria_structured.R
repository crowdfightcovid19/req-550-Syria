# ****************************************
# SIR-Syria_structured.R
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
#         implementing them would be straighforward. The remainder epidemiological parameters are generated
#         in the code "input_parameters_SEPAIHRD.R" where vectors for the different realizations
#         of the noise are created. There are some options for the simulation explained in the section
#         options below. There are finally some computational parameters (e.g. number of realizations)
#         to be fixed by the user below in the space indicated. The name of the directory is expected to
#         be meaningful (related to the model implemented) and will be used for the output
#         files. No other actions are needed from the user, once the parameters are fixed 
#         and the files exist simply "source".
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
#   "neutral" (optional) = Determine whether there exist a neutral zone in which two types of classes, identified
#     by two keywords (keywordA and keywordB) interact. It is assumed that to get into this zone
#     there is some testing to exclude symptomatic individuals, which will reduce the probability of
#     infection. The two keywords should be present in the names of the classes given in the 
#     input files, and will be searched with grep during the integration at every step for each
#     pair of classes, so this option may significantly increase computation times.
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

rm(list=ls())
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
fake=0 # fix to 1 if you are working with test data 
descr="null_model_shield" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
class.infected="age2_no_comorbid_orange" # string with the name of the class in which the first infection is detected

# --- Computational parameters
Npop=2000 # Population size
Ndays=365 # Number of days simulated
Nrand=100 # number of realizations of parameters


# --- Model type
CompModel="SEPAIHRD" # Only "SEPAIHRD" implemented 
isolation=1 # if hospitalized leaves the camp =1, stays in the camp = 0.
isoThr=2000 # If isolation=1, maximum capacity of H people isolation, the difference H-isoThr becomes infectious
hospitalized2=1 # if hospitalized2 = 0, all hospitalized will recover, if = 1 all will die.
neutral=0 # if neutral zone implemented, classes in that zone will not get infected by symptomatic
keywordA="orange" # keyword to identify the first type of users of the neutral zone
keywordB="green" # keyword to identify the second type of users.
# The following are obsolete options, can be recovered from SIRQ model if needed
#ContMatType="mean" # one of "mean"= mean field, "external"= read from file
#strat=0 # if ContMatType="mean" and strat= 1 it will source contact_matrix.R, where you can create manually a contacts matrix

# --- Output options
Nfull=2 # Number of simulations whose results will be fully reported (1 to Nrand)

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
if(neutral == 1){
  neutral="YES"
}else{
  neutral="NO"
}
optLabel=paste("Isolate",isolation,"_Limit",isoThr,"_Fate",hospitalized2,"_Neutral",neutral,"_PopSize",Npop,sep="")

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
neutral.mat=matrix(1,ncol=ncol(C),nrow=nrow(C)) # Same size and names than the contacts matrix
rownames(neutral.mat)=rownames(C)
colnames(neutral.mat)=colnames(C)
if(neutral=="YES"){ # if neutral space exist
  idx.classA=grep(keywordA,colnames(neutral.mat)) # identify the classes not allowed to interact if symptoms
  idx.classB=grep(keywordB,colnames(neutral.mat))
  neutral.mat[idx.classA,idx.classB]=0 # turn them to zero
  neutral.mat[idx.classB,idx.classA]=0 # will only  be applied to H and I
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
                  Cont=C,neutral.mat=neutral.mat,
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
    k=k+1
  }
  # ..... Retrieve deaths, infectious, or any other data you may want to process across realizations
  if(i == 1){
    death.vars=grep(".D",colnames(model.output))
    death.names=colnames(model.output)[death.vars]
    death.tolls.df=data.frame(matrix(ncol = length(death.vars), nrow = Nrand))
    colnames(death.tolls.df)=death.names
    death.total=vector(mode="numeric",length=Nrand)
    death.frac.df=data.frame(matrix(ncol = length(death.vars), nrow = Nrand))
    colnames(death.frac.df)=death.names
    infect.vars=grep(".I",colnames(model.output))
    infect.names=colnames(model.output)[infect.vars]
    infect.max.df=data.frame(matrix(ncol = length(infect.vars), nrow = Nrand)) # We will add the time
    colnames(infect.max.df)=infect.names
    time.infect.max.df=data.frame(matrix(ncol = length(infect.vars), nrow = Nrand))
    colnames(time.infect.max.df)=infect.names
    susc.vars=grep(".S",colnames(model.output))
    susc.names=colnames(model.output)[susc.vars]
    susc.min.df=data.frame(matrix(ncol = length(susc.vars), nrow = Nrand))
    colnames(susc.min.df)=susc.names
  }
  death.tolls=model.output[Ndays,death.vars]
  death.tolls.df[i,]=death.tolls
  death.total[i]=round(sum(death.tolls))
  death.frac.df[i,]=100*death.tolls/Nsubpop
  infect.max=apply(model.output[,infect.vars],2,max)
  infect.max.df[i,]=infect.max
  time.max=apply(model.output[,infect.vars],2,which.max)
  time.infect.max.df[i,]=time.max
  susc.min=apply(model.output[,susc.vars],2,min)
  
}

# Plots and outputs ------------------------
# --- Check the output, and plot dynamics
dir.create(dirPlotOut)
setwd(dirPlotOut)
for(k in 1:Nfull){
  model.output=output.list[[k]]
  output_long <- melt(as.data.frame(model.output), id = "time")
  labelTmp=paste(label,"_rand-",rand2report[k],sep="")
  filePlotOut=paste("Plot-Dynamics_",labelTmp,".pdf",sep="")
  pdf(file=filePlotOut,width=30,height = 8)
  gg=ggplot(data = output_long,
            aes(x = time,
                y = value,
                colour = variable,
                group = variable)) +  # assign columns to axes and groups
    geom_line() +                  # represent data as lines
    xlab("Time (days)")+           # add label for x axis
    ylab("Number of people") +     # add label for y axis
    theme(axis.title = element_text(size=16),
          axis.text = element_text(size=12),
          legend.text = element_text(size=16))+ # Increase fonts size
    labs(title = paste("Model =",descr),
         subtitle = paste("Total deaths =",death.total[rand2report[k]]),
         colour="Class/Compartment") # add title
  print(gg)
  dev.off( )
}

# --- Fraction of Deaths 
setwd(dirDataOut)
fileDataOut=paste("FracDeathTolls_",label,".dat",sep="")
write.csv(death.frac.df,file = fileDataOut)
setwd(dirPlotOut)
filePlotOut=paste("Plot-FracDeathTolls_",label,".pdf",sep="")
nodeath=which(colSums(death.frac.df)!=0) # Exclude classes with no deaths
death.frac.df=death.frac.df[,nodeath]
df.plot <- pivot_longer(death.frac.df,cols=colnames(death.frac.df)) # Transform long format
colnames(df.plot)=c("class","deaths")
pdf(file=filePlotOut,width=17,height = 8)
gg=ggplot(data = df.plot,
          aes(x = class,y = deaths)) +  # assign columns to axes and groups
  geom_boxplot()+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab("Population class")+           # add label for x axis
  ylab("Fraction of deaths (%)") +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  labs(title = paste("Model =",descr),
       subtitle = paste("Mean total deaths =",mean(death.total)))
print(gg)
dev.off( )

# --- Total number of Deaths 
setwd(dirDataOut)
fileDataOut=paste("DeathTolls_",label,".dat",sep="")
write.csv(death.tolls.df,file = fileDataOut)
setwd(dirPlotOut)
filePlotOut=paste("Plot-DeathTolls_",label,".pdf",sep="")
nodeath=which(colSums(death.tolls.df)!=0) # Exclude classes with no deaths
death.tolls.df=death.tolls.df[,nodeath]
df.plot <- pivot_longer(death.tolls.df,cols=colnames(death.tolls.df)) # Transform long format
colnames(df.plot)=c("class","deaths")
pdf(file=filePlotOut,width=17,height = 8)
gg=ggplot(data = df.plot,
          aes(x = class,y = deaths)) +  # assign columns to axes and groups
  geom_boxplot()+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab("Population class")+           # add label for x axis
  ylab("Number of deaths") +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  labs(title = paste("Model =",descr),
       subtitle = paste("Mean total deaths =",mean(death.total)))
print(gg)
dev.off( )



# --- Maximum number of infected
setwd(dirDataOut)
fileDataOut=paste("MaxInfected_",label,".dat",sep="")
write.csv(infect.max.df,file = fileDataOut)
setwd(dirPlotOut)
filePlotOut=paste("Plot-MaxInfected_",label,".pdf",sep="")
df.plot <- pivot_longer(infect.max.df,cols=colnames(infect.max.df)) # Transform long format
colnames(df.plot)=c("class","infections")
pdf(file=filePlotOut,width=17,height = 8)
gg=ggplot(data = df.plot,
          aes(x = class,y = infections)) +  # assign columns to axes and groups
  geom_boxplot(notch = TRUE)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab("Population class")+           # add label for x axis
  ylab("Max. infected") +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  labs(title = paste("Model =",descr),
       subtitle = paste("Mean total deaths =",mean(death.total)))
print(gg)
dev.off( )

# --- Days from first infection to peak
setwd(dirDataOut)
fileDataOut=paste("TimeMaxInfected_",label,".dat",sep="")
write.csv(time.infect.max.df,file = fileDataOut)
setwd(dirPlotOut)
filePlotOut=paste("Plot-TimeMaxInfected_",label,".pdf",sep="")
df.plot <- pivot_longer(time.infect.max.df,cols=colnames(time.infect.max.df)) # Transform long format
colnames(df.plot)=c("class","time")
pdf(file=filePlotOut,width=17,height = 8)
gg=ggplot(data = df.plot,
          aes(x = class,y = time)) +  # assign columns to axes and groups
  geom_boxplot(notch = TRUE)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab("Population class")+           # add label for x axis
  ylab("Time to peak (days)") +     # add label for y axis
  theme_bw()+
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  labs(title = paste("Model =",descr),
       subtitle = paste("Mean total deaths =",mean(death.total)))
print(gg)
dev.off( )


# #Plotting the proportion of people in each compartment over time
# 
# output_long$proportion <- output_long$value/START.N
# 
# ggplot(data = output_long,
#        aes(x = time,
#            y = proportion,
#            colour = variable,
#            group = variable)) +  # assign columns to axes and groups
#   geom_line() +                  # represent data as lines
#   xlab("Time (days)")+           # add label for x axis
#   ylab("Number of people") +     # add label for y axis
#   labs(title = paste("Proportion of susceptible, infected and recovered over time")) # add title
