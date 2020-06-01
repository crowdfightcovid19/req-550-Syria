# ****************************************
# SIR-Syria_structured.R
# ****************************************
# 
# 
# author = Alberto Pascual-García, expanding a version from Eduard Campillo-Funollet
# email = alberto.pascual.garcia@gmail.com (Eduard: e.campillo-funollet@sussex.ac.uk)
# date = 27th May 2020
# description = This script expands the script SimpleSIR.R to account for a structured population
#        in which the transition probabilities from one compartment to another depend on features
#        of the population that the user may want to define, for instance the age,
#        sex or comorbidities of the individuals, hereafter population "classes".
# usage = you have to create a directory in /data/models including the following files describing
#         parameters for the classes. Not all the parameters are implemented in this way
#         because the distinction between community classes is possibly not relevant, but
#         implementing them would be straighforward. The remainder parameters should be fixed
#         by the user below in the space indicated. The name of the directory is expected to
#         be meaningful (related to the model implemented) and will be used for the output
#         files. No other actions are needed from the user, once the parameters are fixed 
#         and the files exist simply "source".
# input_files = Examples of models are located in data/fake_models
#    a) 4 tab separated files with a single row and one column for each class. The
#         classes (i.e. column names) must be the same in all files.
#   * classes_structure.csv: A file describing the starting values of the populations for each class defined
#   * fracAI_structure.csv: A file describing the expected fraction of E going to I for each class
#   * gammaI_structure.csv: A file describing the rate of recovery from infected for each class
#   * alpha_structure.csv: A file describing the fatality rate for each class
#    b) 1 tab-separated file with a matrix of dimensions Nclass x Nclass. The rownames and
#       colnames must exist and match the names of the classes used above. 
#   * contacts_structure.csv: A matrix describing the probability of contact between classes. This
#    matrix permits full flexibility to modulate the contact parameters when actions on population
#    classes are performed (e.g. "females-healthy" class interact with "shielded" class but 
#    "males-healthy" class do not). 
# examples = Run any of the models in "data/fake_models/". See README file in the directory for
#    a description.
# output_files = One file and one figure. The file contains the trajectories of the simulations
#     which are then plotted, including the total death toll. Death tolls by class are coded but
#     not shown in the figure.
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
# δE = latency rate
# kappa = fraction of exposed becoming contagious --> not implemented, no explicit latent phase
# σ = fraction of infections with severe symptoms (class structured)
# η = removal rate of people with severe symptoms from the community 
# γI = recovery rate of people with severe symptoms (class structured)
# γA = recovery rate of people with no/mild symptoms 
# αI = fatality rate of people with severe symptoms (class structured)
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

# -- Comments (ongoing tests)
# Juan Poyatos parameters
# fs = [ fMS, fSC, fCD]';
# fs = [ 0.19, 0.31, 0.40]'; 
# taus = [tE, tA, tM, tMR, tS, tSR, tCD, tCD_ICU, tCR, tV]';
# taus = [ 2, 4, 7, 8, 1.5, 14, 0.02, 7, 12, 1e10]'; 
# -- Models implemented so far:
#    * Fake models (directory fake_data)
#    ... age3_gender2_com2
#    ... healthy_vs_vulnerable
#    ... healthy_vs_vulnerable-confined
# 
#
# Fix parameters ----------------------
###### START EDITING
# --- Structure of directories and labelling 
fake=1 # fix to 1 if you are working with fake data (used for storage only)
descr="age3_gender2_com2" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
class.infected="age2_M_healthy" # string with the name of the class in which the first infection is detected
# --- Model type
CompModel="SEAIRQD" # One of "SEAIRQD" (basic), "SEPAIRQD" (+latent) or "SEPAIRQHD" (+latent and hospitalized)
ContMatType="mean" # one of "mean"= mean field, "external"= read from file
strat=0 # if ContMatType="mean" and strat= 1 it will source contact_matrix.R, where you can create manually a contacts matrix
# --- Epidemiological parameters
Ndays=365 # Number of days simulated
file.age="classes_structure.csv" # Starting population sizes by classes
# Infected to susceptible (R0)
betaI=0.5 # 
betaI.lowCI=0.3 # lower CI boundary
betaI.sigCI="95" # character, significance of the confidence interval
betaA=0.5 # 
betaA.lowCI=0.3 # lower CI boundary
betaA.sigCI="95"
file.contacts="contacts_structure.csv" # Matrix of contacts between classes, required unless ContMatType="mean" (field)
# Exposed and Latent
deltaE=0.5 # Exposed
deltaE.lowCI=0.3
deltaE.sigCI="95"
deltaP=0.3 # Latent
# Assymptomatic and Infectious
file.fracAI="fracAI_structure.csv"  # fracAI = fraction of infected showing severe symptoms, class dependent
gammaA=0.15 # from asymptomatic to recovered
gammaA.lowCI=0.1
gammaA.sigCI="95"
file.gammaI="gammaI_structure.csv" # gammaI = from infected to recovered (class dependent)
file.alpha="alpha_structure.csv" # alphaI = alphaQ = fatality rate, by classes
# Quarantined, hospitalized, and dead
gammaQ=0.001 # from quarantined to recovered, note that they would have left the camp, possibly low
psi=0 # rate at which they are removed from the camp and quarantined (WHO-controlled)
# --- Parameters to control the randomizations
Nrand=100 # number of realizations of parameters
# --- Output options
Nfull=5 # Number of realization whose results will be fully reported

######### STOP EDITING

# Fix directories ------------
if(fake == 1){
  dirTmp="/fake_models/"
}else{
  dirTmp="/models/"
}
# --- The following lines edit the input and output directories
# You may have problems with the following line in Windows, or if you do not run from rstudio 
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit comment if problems...
#this.dir="/pathToRepo" # ...path to the root path of your repo if the above command does not work, comment otherwise
dirDataIn=paste(this.dir,"/data",dirTmp,descr,sep="") # Directory for the input data
dirFun=paste(this.dir,"/src",sep="") # Directory where the function with the derivatives is coded
dirDataOut=paste(this.dir,"/data",dirTmp,descr,"/results",sep="") # directory for the simulation output
dirPlotOut=paste(this.dir,"/data",dirTmp,descr,"/figures",sep="") # directory for the figure

label=paste("SEIRD_dynamics",descr,"cont",ContMatType,sep="_") # a label for your output  files

# Read input data ---------
setwd(dirDataIn)
age.str=read.table(file=file.age,sep="\t",header = TRUE)
Nclass=dim(age.str)[2] # number of classes in the population structure
fracAI.str=as.vector(read.table(file=file.fracAI,sep="\t",header = TRUE)) # fraction E-->I
gammaI.str=as.vector(read.table(file=file.gammaI,sep="\t",header = TRUE))
alpha.str=as.vector(read.table(file=file.alpha,sep="\t",header = TRUE))
class.names=colnames(age.str) # Store the name of the classes
if(ContMatType != "mean"){ # Read contacts file
  Cont=as.matrix(read.table(file=file.contacts,sep="\t")) # format to determine
  rownames(Cont)=class.names
  colnames(Cont)=class.names
}else{ # or create a mean field matrix
  Cont=matrix(1,nrow = Nclass,ncol=Nclass)
  rownames(Cont)=class.names
  colnames(Cont)=class.names
  if(strat==1){ # create a specific contact matrix
    setwd(dirFun)
    source("contacts_matrix.R")
    setwd(dirDataIn)
  }
}

# Initialize the model and data  ----------
# Select the model and source it
setwd(dirFun)
if(CompModel == "SEAIRQD"){
  compartments=c("S","E","A","I","R","Q","D") # Declare the compartments
  source("dxdt_SEAIRD_str.R")
  dxdtfun=dxdt_SEAIRD_str
}else if(CompModel == "SEPAIRQD"){ # Include P
  compartments=c("S","E","P","A","I","R","Q","D") # 
  source("dxdt_SEPAIRD_str.R")
  dxdtfun=dxdt_SEPAIRQD_str
}else if(CompModel == "SEPAIRQHD"){ # Include H
  compartments=c("S","E","P","A","I","R","Q","H","D") # 
  source("dxdt_SEPAIRQHD_str.R")
  dxdtfun=dxdt_SEPAIRHD_str
}
# --- Starting population values
setwd(dirDataIn)
Ncomp=length(compartments)
y.start=matrix(0, nrow= Ncomp*Nclass,ncol=1)
var.names=c()
for(var in compartments){ # Create a vector with all the variables
  if(var == "S"){ # starting susceptible
    y.start[1:Nclass,1]=as.numeric(age.str[1,])
  }
  var.names=c(var.names,paste(class.names,var,sep="."))
}
y.start=as.vector(y.start) # we need to work with vectors in the solver
names(y.start)=var.names
first.inf=paste(class.infected,"I",sep=".") # In the class where the infection was detected, I compartment
y.start[first.inf]=1 # we initialize the first case
# NOTES: At the time in which the first infection is detected, a number of asymptomatic and exposed
# cases could already be there, how to initialize it?

# --- Generate random realizations of the parameters
zscore=vector(mode="numeric")
zscore["95"]=-1.64 # translate CI significance in zscore
zscore["99"]=-2.32
betaI.std=(betaI.lowCI-betaI)/zscore[betaI.sigCI] # extract standard deviation
betaI.mat=rnorm(Nrand,betaI,betaI.std) # generate a matrix of realizations
betaA.std=(betaA.lowCI-betaA)/zscore[betaA.sigCI] # extract standard deviation
betaA.mat=rnorm(Nrand,betaA,betaA.std)
deltaE.std=(deltaE.lowCI-deltaE)/zscore[deltaE.sigCI] # extract standard deviation
deltaE.mat=rnorm(Nrand,deltaE,deltaE.std)
gammaA.std=(gammaA.lowCI-gammaA)/zscore[gammaA.sigCI] # extract standard deviation
gammaA.mat=rnorm(Nrand,gammaA,gammaA.std)
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
  betaI=betaI.mat[i]
  betaA=betaA.mat[i]
  deltaE=deltaE.mat[i]
  gammaA=gammaA.mat[i]
  fracAI.str=fracAI.str
  gammaI.str=gammaI.str
  alpha.str=alpha.str
  Cont=Cont
  parms.list=list(betaI=betaI,betaA=betaA,deltaE=deltaE,gammaA=gammaA,fracAI.str=fracAI.str,
                gammaI.str=gammaI.str,alpha.str=alpha.str,Cont=Cont,
                classes=class.names,vars=var.names,compartments=compartments)
  
  # Run the ODE solver
  SEAIRD.output <- as.data.frame(lsoda(y=y.start, 
                                       times=times_vector, 
                                       func=dxdtfun, 
                                       parms=parms.list))
  
  # --- Process output
  if(i == round(k*Nrand/Nfull)){
    labelTmp=paste(label,"_rand-",i,sep="")
    fileOut=paste(labelTmp,"dat",sep=".")
    write.table(SEAIRD.output,file=fileOut,row.names = FALSE)
    output.list[[k]]=SEAIRD.output
    rand2report[k]=i
    k=k+1
  }
  # ..... Retrieve deaths
  if(i == 1){
    death.vars=grep(".D",colnames(SEAIRD.output))
    death.names=colnames(SEAIRD.output)[death.vars]
    death.tolls.df=data.frame(matrix(ncol = length(death.vars), nrow = Nrand))
    colnames(death.tolls.df)=death.names
    death.total=vector(mode="numeric",length=Nrand)
    death.frac.df=data.frame(matrix(ncol = length(death.vars), nrow = Nrand))
    colnames(death.frac.df)=death.names
    infect.vars=grep(".I",colnames(SEAIRD.output))
    infect.names=colnames(SEAIRD.output)[infect.vars]
    infect.max.df=data.frame(matrix(ncol = length(infect.vars), nrow = Nrand)) # We will add the time
    colnames(infect.max.df)=infect.names
    time.infect.max.df=data.frame(matrix(ncol = length(infect.vars), nrow = Nrand))
    colnames(time.infect.max.df)=infect.names
  }
  death.tolls=SEAIRD.output[Ndays,death.vars]
  death.tolls.df[i,]=death.tolls
  death.total[i]=round(sum(death.tolls))
  death.frac.df[i,]=100*death.tolls/age.str
  infect.max=apply(SEAIRD.output[,infect.vars],2,max)
  infect.max.df[i,]=infect.max
  time.max=apply(SEAIRD.output[,infect.vars],2,which.max)
  time.infect.max.df[i,]=time.max
}

# --- Print the output: this is a matrix of S, I and R values at each time point	
# Plots ------------------------
# --- Check the output, and plot dynamics
dir.create(dirPlotOut)
setwd(dirPlotOut)
for(k in 1:Nfull){
  SEAIRD.output=output.list[[k]]
  output_long <- melt(as.data.frame(SEAIRD.output), id = "time")
  labelTmp=paste(label,"_rand-",rand2report[k],sep="")
  filePlotOut=paste("Plot-Dynamics_",labelTmp,".pdf")
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

# --- Death tolls
filePlotOut=paste("Plot-DeathTolls_",label,".pdf")
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
  ylab("Death toll (%)") +     # add label for y axis
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  labs(title = paste("Model =",descr),
       subtitle = paste("Total deaths =",death.total))
print(gg)
dev.off( )

# --- Maximum number of infected
filePlotOut=paste("Plot-MaxInfected_",label,".pdf")
df.plot <- pivot_longer(infect.max.df,cols=colnames(infect.max.df)) # Transform long format
colnames(df.plot)=c("class","infections")
pdf(file=filePlotOut,width=17,height = 8)
gg=ggplot(data = df.plot,
          aes(x = class,y = infections)) +  # assign columns to axes and groups
  geom_boxplot(notch = TRUE)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab("Population class")+           # add label for x axis
  ylab("Max. infected") +     # add label for y axis
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  theme_bw()+
  labs(title = paste("Model =",descr),
       subtitle = paste("Total deaths =",death.total))
print(gg)
dev.off( )

# --- Days from first infection to peak
filePlotOut=paste("Plot-TimeMaxInfected_",label,".pdf")
df.plot <- pivot_longer(time.infect.max.df,cols=colnames(time.infect.max.df)) # Transform long format
colnames(df.plot)=c("class","time")
pdf(file=filePlotOut,width=17,height = 8)
gg=ggplot(data = df.plot,
          aes(x = class,y = time)) +  # assign columns to axes and groups
  geom_boxplot(notch = TRUE)+
  #geom_bar(stat="identity") +                  # represent data as lines
  xlab("Population class")+           # add label for x axis
  ylab("Time to peak (days)") +     # add label for y axis
  theme(axis.title = element_text(size=16),
        axis.text = element_text(size=12),
        legend.text = element_text(size=16))+ # Increase fonts size
  theme_bw()+
  labs(title = paste("Model =",descr),
       subtitle = paste("Total deaths =",death.total))
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
