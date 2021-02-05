###############################################
# estimation_tau_from_modelParameters.R
###############################################
#
# author = Alberto Pascual-García
# email = alberto.pascual.garcia@gmail.com 
# date = 16th june 2020
# description = This script aims to estimate the transmissivity (tau = probability of being infected
#               after contact with an infected person) from the remaining parameters of the model
#               through the computation of the Next Generation Matrix spectrum, and an estimation
#               of the reproduction number.
# usage = Parameters are sourced from input_parameters_SEPAIHRD.R, the class-structured read from
#         files in read_classStructuredData_function.R , so it can simply be sourced
#
library(MASS)
rm(list=ls())

# --- Fix parameters
Nrand=1000 # Determine number of randomizations to estimate tau

# --- Fix directories and file
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit comment if problems...
#this.dir="/pathToRepo" # ...path to the root path of your repo if the above command does not work, comment otherwise
dirDataIn=paste(this.dir,"/data/real_models/null_model_mixed/",sep="") # Directory for the input data
dirCodeBase=paste(this.dir,"/src",sep="") # Directory where the function with the basic code is found
dirParams=paste(this.dir,"/src/SEPAIHRD",sep="") # Directory where the function with the derivatives is coded
pathOut="data/estimation_parameters/figures_prob_distros"
dirPathOut=paste(this.dir,pathOut,sep="/")

file.contclass="classes_contacts" # bar(c)_i average number of contacts per class, all the remaining files and params are generated externally
fileParams="input_parameters_SEPAIHRD.R"
fileStrParams="read_classStructuredData_function.R"

# --- Read input data
setwd(dirCodeBase)
source(fileStrParams)
struct.param=read_classStructuredData_function(dirDataIn)
class.str=unlist(struct.param["class.str"][[1]])
fracItoH.str=unlist(struct.param["fracItoH.str"][[1]])
fracItoD.str=unlist(struct.param["fracItoD.str"][[1]])
class.names=unlist(struct.param["class.names"][[1]])
C=(unlist(struct.param["C"][[1]]))

setwd(dirDataIn)
av.cont=as.matrix(read.csv(file=file.contclass,sep="\t"))
#rownames(C)=colnames(C)

# --- Source parameters
#N=6000
setwd(dirParams)
isoThr=0 # needed in the estimation of parameters
source(fileParams)

# --- Compute NGM
# ..... Create the matrix of contacts
av.cont.mat=as.vector(class.str)*as.vector(av.cont)*matrix(1,nrow=dim(C)[1],ncol=dim(C)[2])
#N.str=as.matrix(N*class.str)
h=fracItoH.str
g=fracItoD.str
tau=vector(mode="numeric",length = Nrand)
for(k in 1:Nrand){
  scope=av.cont.mat # *as.vector(fracPtoI.vec[k])
  # ... clean the code to avoid mistakes
  f=fracPtoI.vec[k] 
  gammaH=gammaH.vec[k]
  eta=eta.vec[k]
  alpha=alpha.vec[k]
  deltaP=deltaP.vec[k]
  #betaP=betaP
  betaA=betaA.vec[k]
  betaI=betaI.vec[k]
  betaH=betaH.vec[k]
  # ... compute coefficients
  kappa=(1-h-g)*gammaI+h*eta+g*alpha
  A1=betaP/deltaP
  A2=betaA*(1-f)/gammaA
  A3=betaI*as.vector(as.matrix(f/kappa))
  A4=betaH*as.vector(as.matrix((f*h*eta)/
                           (kappa*gammaH)))
  
  Ks.red= (A1+A2+A3+A4)*scope
  spectra=eigen(Ks.red)
  lambdas=spectra$values
  lambdas.sort=sort(abs(Re(lambdas)),decreasing = TRUE)
  radius=lambdas.sort[1]
  
  tau[k]=R0.vec[k]/radius
}

# --- Analyse the distribution of tau
setwd(dirPathOut)
distribution="log-normal" #"normal" #"gamma" #"log-normal" # choose a distro to fit
quantile(tau,probs = c(0,0.05, 0.5, 0.95,1)) # show quantiles
fit=fitdistr(tau,densfun = distribution) # fit
mean=fit$estimate[1] # retrieve parameters
sd=fit$estimate[2]
fit$loglik # show loglike

# --- Plot results
xlabel="tau"
labelPlot="Tau"
plotOut=paste("Plot_",labelPlot,"_",distribution,"Distro_wBeta.pdf",sep="")
pdf(file = plotOut,width=10)
hist(tau, 100, freq = FALSE, main=paste(distribution," distribution"),
     xlab=xlabel)
#X=rlnorm(Nrand,meanlog = mean,sd=sd)
#curve(dnorm(x, mean = mean, sd=sd), seq(0,1,0.01),  col = "red", add = TRUE)
curve(dlnorm(x, meanlog = mean, sdlog=sd), seq(0,1,0.01),  col = "red", add = TRUE)
#curve(dgamma(x, shape = mean, rate=sd), seq(0,1,0.01),  col = "red", add = TRUE)
tau.rnd=rlnorm(Nrand,meanlog = mean,sdlog = sd)
hist(tau.rnd,99,freq=FALSE,main="randomly generated with fitted parameters",xlab=xlabel)
curve(dlnorm(x, meanlog = mean, sdlog=sd), seq(0,1,0.01),  col = "red", add = TRUE)
dev.off()
# 

