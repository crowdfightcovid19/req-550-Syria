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
# usage = Create a directory in /data/models including the following files describing
#         parameters for the classes. Not all the parameters are implemented in this way
#         because the distinction between community classes is possibly not relevant, but
#         implementing them would be straighforward. The remainder epidemiological parameters are generated
#         in the code "input_parameters_SEPAIHRD.R" where vectors for the different realizations
#         of the noise are created. There are finally some computational parameters (e.g. number of realizations)
#         to be fixed by the user below in the space indicated. The name of the directory is expected to
#         be meaningful (related to the model implemented) and will be used for the output
#         files. No other actions are needed from the user, once the parameters are fixed 
#         and the files exist simply "source".
# input_files = Examples of models are located in data/fake_models
#    a) 4 tab separated files with a single row and one column for each class plus the column names. The
#         classes (i.e. column names) must be the same in all files.
#   * classes_structure.csv: A file describing the fraction of the population that each class represents
#   *Not in current version fracPtoI_structure.csv: A file describing the expected fraction of P going to I for each class
#   * fracItoH_structure.csv: A file describing the fraction of infected that would be hospitalized
#   * fracItoD_structure.csv: A file describing the fraction of infected that would die
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
fake=1 # fix to 1 if you are working with test data 
descr="age3_gender2_com2" # A string describing the model, input data should be created in a directory with that name in /data, outputs will be located there
class.infected="age2_M_healthy" # string with the name of the class in which the first infection is detected

# --- Model type
CompModel="SEPAIHRD" # Only "SEPAIHRD" implemented 
ContMatType="mean" # one of "mean"= mean field, "external"= read from file
strat=0 # if ContMatType="mean" and strat= 1 it will source contact_matrix.R, where you can create manually a contacts matrix
scenario=1 # if scenario = 0, all hospitalized will recover, if = 1 all will die.

# --- Computational parameters
Npop=6000 # Population size
Ndays=365 # Number of days simulated
Nrand=100 # number of realizations of parameters

# --- Output options
Nfull=5 # Number of simulations whose results will be fully reported (1 to Nrand)
######### STOP EDITING



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
dirDataOut=paste(this.dir,"/data",dirTmp,descr,"/results",sep="") # directory for the simulation output
dirPlotOut=paste(this.dir,"/data",dirTmp,descr,"/figures",sep="") # directory for the figure

label=paste(CompModel,"dynamics",descr,"cont",ContMatType,sep="_") # a label for your output  files

# Read input data ---------
setwd(dirCodeBase)
source("read_classStructuredData_function.R")
struct.param=read_classStructuredData_function(dirDataIn)
class.str=unlist(struct.param["class.str"][[1]])
fracItoH.str=unlist(struct.param["fracItoH.str"][[1]])
fracItoD.str=unlist(struct.param["fracItoD.str"][[1]])
class.names=unlist(struct.param["class.names"][[1]])
C=(unlist(struct.param["C"][[1]]))

# Initialize the model and data  ----------
# .... Select the model and source it
setwd(dirCodeSpec)
if(CompModel == "SEPAIHRD"){ # Only this model implemented so far
  compartments=c("S","E","P","A","I","H","R","D") # 
  source("dxdt_SEPAIHRD_str.R")
  source("input_parameters_SEPAIHRD.R")
  dxdtfun=dxdt_SEPAIRQD_str
}


# --- Starting population values
setwd(dirDataIn)
Ncomp=length(compartments)
y.start=matrix(0, nrow= Ncomp*Nclass,ncol=1)
var.names=c()
for(var in compartments){ # Create a vector with all the variables
  if(var == "E"){ # starting exposed
    y.start[1:Nclass,1]=as.numeric(class.str[1,])*Npop
  }
  var.names=c(var.names,paste(class.names,var,sep="."))
}
y.start=as.vector(y.start) # we need to work with vectors in the solver
names(y.start)=var.names
first.inf=paste(class.infected,"E",sep=".") # The class infected is initialized in the E compartment
y.start[first.inf]=1 # we initialize the first case

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
  fracItoH.str=fracItoH.str
  fracItoD.str=fracItoD.str
  Cont=Cont
  parms.list=list(tau=tau,deltaE=deltaE,deltaP=deltaP,
                  gammaA=gammaA,gammaI=gammaI,gammaH=gammaH,
                  fracPtoI=fracPtoI,fracItoH.str=fracItoH.str,fracItoD.str=fracItoD.str,Cont=Cont,
                scenario=scenario,classes=class.names,vars=var.names,compartments=compartments)
  
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
  # ..... Retrieve deaths
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
  }
  death.tolls=model.output[Ndays,death.vars]
  death.tolls.df[i,]=death.tolls
  death.total[i]=round(sum(death.tolls))
  death.frac.df[i,]=100*death.tolls/class.str
  infect.max=apply(model.output[,infect.vars],2,max)
  infect.max.df[i,]=infect.max
  time.max=apply(model.output[,infect.vars],2,which.max)
  time.infect.max.df[i,]=time.max
}

# --- Print the output: this is a matrix of S, I and R values at each time point	
# Plots ------------------------
# --- Check the output, and plot dynamics
dir.create(dirPlotOut)
setwd(dirPlotOut)
for(k in 1:Nfull){
  model.output=output.list[[k]]
  output_long <- melt(as.data.frame(model.output), id = "time")
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
       subtitle = paste("Mean total deaths =",mean(death.total)))
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
