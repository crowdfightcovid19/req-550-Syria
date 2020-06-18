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
# usage = I
#
rm(list=ls())
# --- Fix directories and file
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit comment if problems...
#this.dir="/pathToRepo" # ...path to the root path of your repo if the above command does not work, comment otherwise
dirDataIn=paste(this.dir,"/data/real_models/null_model/",sep="") # Directory for the input data
dirParams=paste(this.dir,"/src/SEPAIHRD",sep="") # Directory where the function with the derivatives is coded
pathOut="data/estimation_parameters/figures_prob_distros"
dirPathOut=paste(this.dir,pathOut,sep="/")
file.class="classes_structure" # Fraction of the population that each class represents
file.fracItoH="fracItoH_structure"  # fraction of symptomatic that would be hospitalized
file.fracItoD="fracItoD_structure" # fraction that will directly die
file.contacts="contacts_structure" # contact matrix
fileParams="input_parameters_SEPAIHRD.R"


# --- Read input data
setwd(dirDataIn)
sep="\t"
class.str=read.table(file=file.class,sep=sep,header = TRUE)
Nclass=dim(class.str)[2] # number of classes in the population structure
#fracPtoI=as.vector(read.table(file=file.fracPtoI,sep=sep,header = TRUE)) 
fracItoH=as.vector(read.table(file=file.fracItoH,sep=sep,header = TRUE))
fracItoD=as.vector(read.table(file=file.fracItoD,sep=sep,header = TRUE))
class.names=colnames(class.str) # Store the name of the classes
C=as.matrix(read.csv(file=file.contacts,sep = sep))
rownames(C)=colnames(C)

# --- Source parameters
N=6000
Nrand=1000 # Determine number of randomizations
setwd(dirParams)
source(fileParams)

# --- Compute scope of class i
N.str=as.matrix(N*class.str)
scope=C#/as.vector(N.str)
tau=vector(mode="numeric",length = Nrand)
for(k in 1:Nrand){
  kappa=(1-fracItoH-fracItoD)*gammaI+fracItoH*eta.vec[k]+fracItoD*alpha.vec[k]
  A1=1/deltaP.vec[k]
  A2=(1-fracPtoI.vec[k])/gammaA
  A3=as.vector(as.matrix(fracPtoI.vec[k]/kappa))
  A4=as.vector(as.matrix((fracPtoI.vec[k]*fracItoH*eta.vec[k])/
                           (kappa*gammaH.vec[k])))
  
  Ks.red= (A1+A2+A3+A4)*scope
  spectra=eigen(Ks.red)
  lambdas=spectra$values
  lambdas.sort=sort(abs(lambdas),decreasing = TRUE)
  radius=lambdas.sort[1]
  
  tau[k]=R0.vec[k]/radius
}

# --- Analyse the distribution of tau
setwd(dirPathOut)
distribution="normal" #"gamma" #"log-normal" # choose a distro to fit
quantile(tau,probs = c(0.05, 0.5, 0.95)) # show quantiles
fit=fitdistr(tau,densfun = distribution) # fit
mean=fit$estimate[1] # retrieve parameters
sd=fit$estimate[2]
fit$loglik # show loglike

# --- Plot results
xlabel="tau"
labelPlot="Tau"
plotOut=paste("Plot_",labelPlot,"_",distribution,"Distro.pdf",sep="")
pdf(file = plotOut,width=10)
hist(tau, 100, freq = FALSE, main=paste(distribution," distribution"),
     xlab=xlabel)
#X=rlnorm(Nrand,meanlog = mean,sd=sd)
curve(dnorm(x, mean = mean, sd=sd), seq(0,1,0.01),  col = "red", add = TRUE)
#curve(dlnorm(x, meanlog = mean, sdlog=sd), seq(0,1,0.01),  col = "red", add = TRUE)
#curve(dgamma(x, shape = mean, rate=sd), seq(0,1,0.01),  col = "red", add = TRUE)
dev.off()

