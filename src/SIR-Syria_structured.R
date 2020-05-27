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

# -- Comments (ongoing tests)
# Juan Poyatos parameters
# fs = [ fMS, fSC, fCD]';
# fs = [ 0.19, 0.31, 0.40]'; 
# taus = [tE, tA, tM, tMR, tS, tSR, tCD, tCD_ICU, tCR, tV]';
# taus = [ 2, 4, 7, 8, 1.5, 14, 0.02, 7, 12, 1e10]'; 
# -- Models implemented so far:
#    * Fake models (directory fake_data)
#    ... age3-gender2-com2
#    ... healthy_vs_vulnerable
#    ... healthy_vs_vulnerable-confined
###### START EDITING
fake=1 # fix to 1 if you are working with fake data (used for storage only)
descr="healthy_vs_vulnerableShielded" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
class.infected="healthy" # string with the name of the class in which the first infection is detected
model="external" # one of "mean"= mean field, "external"= read from file
Ndays=365 # Number of days simulated
file.age="classes_structure.csv" # Starting population sizes by classes
betaI=0.5 # 
betaA=0.5 # 
deltaE=0.5 # Exposed
file.fracAI="fracAI_structure.csv"  # fracAI = fraction of infected showing severe symptoms, class dependent
gammaA=0.15 # from asymptomatic to recovered
gammaQ=0.001 # from quarantined to recovered, note that they would have left the camp, possibly low
file.gammaI="gammaI_structure.csv" # gammaI = from infected to recovered (class dependent)
psi=0 # rate at which they are removed from the camp and quarantined (WHO-controlled)
file.alpha="alpha_structure.csv" # alphaI = alphaQ = fatality rate, by classes
file.contacts="contacts_structure.csv" # Matrix of contacts between classes, required unless model="mean" (field)
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

label=paste("SEIRD_dynamics",descr,"cont",model,sep="_") # a label for your output  files

# Read input data ---------
setwd(dirDataIn)
age.str=read.table(file=file.age,sep="\t",header = TRUE)
Nclass=dim(age.str)[2] # number of classes in the population structure
fracAI.str=as.vector(read.table(file=file.fracAI,sep="\t",header = TRUE)) # fraction E-->I
gammaI.str=as.vector(read.table(file=file.gammaI,sep="\t",header = TRUE))
alpha.str=as.vector(read.table(file=file.alpha,sep="\t",header = TRUE))
if(model != "mean"){ # Read contacts file
  Cont=as.matrix(read.table(file=file.contacts,sep="\t")) # format to determine
}else{ # or create a mean field matrix
  Cont=matrix(1,nrow = Nclass,ncol=Nclass)
}
class.names=colnames(age.str) # Store the name of the classes
rownames(Cont)=class.names
colnames(Cont)=class.names

# Initialize data and source derivatives ----------
# --- Starting population values
compartments=c("S","E","A","I","R","Q","D") # Declare the compartments
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
# How is typically controlled avoiding having negative populations in the compartments? 

# --- Parameters list
parms.list=list(betaI=betaI,betaA=betaA,deltaE=deltaE,gammaA=gammaA,fracAI.str=fracAI.str,
                gammaI.str=gammaI.str,alpha.str=alpha.str,Cont=Cont,
                classes=class.names,vars=var.names,compartments=compartments)
# --- Times 
# (here, we do daily for Ndays days - you can change this value)
times_vector <- seq(from=0, to=Ndays, by=1)

# --- Source the function
setwd(dirFun)
source("dxdt_SEAIRD_str.R")

# Run the ODE solver
SEAIRD.output <- as.data.frame(lsoda(y=y.start, 
                                  times=times_vector, 
                                  func=dxdt_SEAIRD_str, 
                                  parms=parms.list))
# Retrieve deaths
death.vars=grep(".D",colnames(SEAIRD.output))
death.tolls=SEAIRD.output[Ndays,death.vars]
death.total=round(sum(death.tolls))

# Print the output: this is a matrix of S, I and R values at each time point	
dir.create(dirDataOut)
setwd(dirDataOut)
fileOut=paste(label,"dat",sep=".")
write.table(SEAIRD.output,file=fileOut,row.names = FALSE)

#check the output, and plot
output_long <- melt(as.data.frame(SEAIRD.output), id = "time")
dir.create(dirPlotOut)
setwd(dirPlotOut)
filePlotOut=paste("Plot_",label,".pdf")

pdf(file=filePlotOut,width=14,height = 8)
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
       subtitle = paste("Total deaths =",death.total),
       colour="Class/Compartment") # add title
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
