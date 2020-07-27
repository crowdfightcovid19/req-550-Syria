###############################################
# estimation_distribution_from_quantiles.R
###############################################
#
# author = Alberto Pascual-García
# email = alberto.pascual.garcia@gmail.com 
# date = 7th june 2020
# description = This script aims to tune the parameters of a given distribution
#              to best match the mean and upper and lower confidence intervals (CI). Our
#              aim is to generate random numbers, when we retrieve from the literature
#              only the mean and CI, and eventually the distribution.
# usage = Include the targeted mean and lower and upper CI, the distribution and an initial
#        guess of the parameter(s) being optimized.
#       Supported distributions are "normal" "lognormal" "gamma" "binomial" and "gompertz" 
#
# ** Minimum time to become infectious
# normal, mean = 16/24, CI=[8/24,1] (models a minimum exposed case when incubation - presympt is too small)
# For parameter = 0.14 minimization value = 3.07e-09 (normal distribution)
# ** Incubation:
# lognormal, mean = 5.2, CI=[4.1,7.2], 95%
# For parameter = 0.18 minimization value = 0.30 (lognormal distribution)
# ** Presymptomatic
# gompertz, mean = 2.3, CI=[0.8,3.0], 95%
# For parameters a = 0.028, b = 1.73 (gompertz distribution)
# After Ashcroft article this seem to be unrealistic, we take now a gaussian
# of mean 2.3 and CIhigh=2.3+(2.3-0.8)=3.8
# gaussian, mean = 2.3, CI=[0.8,3.8]
# For parameter = 0.91
# ** Fraction asymptomatic
# binomial, mean = 0.84, CI=[0.8,0.88], 95%
# For parameter = 240 minimization value = 0.0019 (binomial distribution)
# ** Symptoms onset to hospital 
#  7 days (IQR: 4-8) (Chinese study 138 patients) 
#  For parameter = 0.14 minimization value = 1.75 (lognormal distribution)
#  For parameter = 1.47 minimization value = 1.16 (gamma distribution)
# ** Hospitalized to R/D
# 10 days (IQR: 7-14) (Chinese study 138 patients) 
# For parameter = 2.24 minimization value = 1.59 (gamma distribution)
# ** Symptoms onset to critical care (to dead in our case)
# 10 days (IQR: 6-12) (Chinese study 138 patients) 
# For parameter = 2.13 minimization value = 1.12 # ** Fraction of infectious
# ** R0 Basic reproduction number
# 4 [3,5] 99% (ad-hoc after having a look to the literature)
# For parameter = 0.43 minimization value = 1.18e-08 (normal distribution)

library(extraDistr) # fits gompertz distribution
rm(list=ls())

### START EDITING
distribution="normal" #"normal" "lognormal" "gamma" "binomial" and "gompertz"
meanIn=2.3 # mean of the distribution 
CIlow=0.8 # lower CI (not log-transformed here if lognormal)
CIhigh=3.8 # upper CI
param=c(1) # a vector with the starting parameters to explore in the optimization, only gompertz requires two values
N=10e5 # number of randomizations generated for a plot
Level=0.95 # confidence level, implemented 0.95, 0.99 and 0.75 (interquartile)
xlabel="Presymptomatic time (days)" # a string for the xaxis with the units (e.g "incubation time (days)")
labelPlot="Presymptomatic" # And a label for the plot
pathOut="data/estimation_parameters/figures_prob_distros" # path for the plots from the root of the repo
### STOP EDITING

# --- Move to the output directory
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1]
pathOut=paste(this.dir,pathOut,sep="/")
setwd(pathOut)

# --- Create confidence intervals
quantiles=c(CIlow,meanIn,CIhigh) # 
if(Level==0.99){
  q=c(0.01,0.5,0.99) # 99CI
}else if(Level==0.95){
  q=c(0.05,0.5,0.95) # 95CI
}else{
  q=c(0.25,0.5,0.75) # interquartile
} 
# --- Start estimations
if(distribution != "gompertz"){ # If it  is not gompertz, we only optimize one parameter
  minQuantileOneParam=function(stdOut,quantiles,distribution,q){
    #stdOut: parameter to optimize
    #quantiles: values of the quantiles
    #q: which quantiles they are
    meanTmp=quantiles[2]
    if(distribution=="normal"){
      distro <- qnorm(q, mean=meanTmp, sd=stdOut)
    }else if(distribution=="lognormal"){
      meanTmp=log(meanTmp)
      distro <- qlnorm(q, mean=meanTmp, sd=stdOut)
    }else if(distribution=="gamma"){
      shapeIn=meanTmp/stdOut
      distro <- qgamma(q, shape=shapeIn,scale=stdOut)
    }else if(distribution=="binomial"){
      #distro <- qbinom(q,p=meanTmp,size=round(stdOut)) # not clear what this function returns
      X=rbinom(1000,p=meanTmp,size=round(stdOut)) # doing 1K experiments, retrieve the successes
      distro=quantile(X,probs=q)/round(stdOut) # transform to fractions and get the quantiles
    }
    fun=sqrt((quantiles[1]-distro[1])**2+(quantiles[2]-distro[2])**2+
               abs(quantiles[3]-distro[3])**2)
    return(fun)
  }
  if(distribution=="binomial"){ # lower and upper bounds are different
    lowbound=1
    upbound=10e8
  }else{
    lowbound=0.01
    upbound=10
  }
  # -- Optimize the function
  minOneParam.fit=optim(
    param,
    minQuantileOneParam,
    quantiles=quantiles,
    distribution=distribution,
    q=q,
    method="Brent",lower=lowbound,upper=upbound
  )

  out.fit=minOneParam.fit
  stdOut=out.fit$par
  funVal=out.fit$value
  # plot selected results
  if(distribution=="normal"){
    X <- rnorm(N, mean=meanIn, sd=stdOut)
    distro=qnorm(q, mean=meanIn, sd=stdOut)
  }else if(distribution=="lognormal"){
    meanTmp=log(meanIn)
    X <-rlnorm(N,meanlog = meanTmp,sdlog = stdOut)
    distro=qlnorm(q, mean=meanTmp, sd=stdOut)
  }else if(distribution=="gamma"){
    shapeIn=meanIn/stdOut
    X <- rgamma(N,shape=shapeIn,scale=stdOut)
    distro=qgamma(q, shape=shapeIn, scale=stdOut)
  }else if(distribution=="binomial"){ #
    X=rbinom(N,p=meanIn,size=round(stdOut)) # doing 1K experiments, retrieve the successes
    distro=quantile(X,probs=q)/round(stdOut)
  }

}else{
  minQuantileGompertz=function(param,quantiles,q){
    #param: parameters to optimize (vector with a and b)
    #quantiles: values of the quantiles
    #q: which quantiles they are
    distro=qgompertz(q,a=param[1],b=param[2])
    fun=sqrt((quantiles[1]-distro[1])**2+(quantiles[2]-distro[2])**2+
      abs(quantiles[3]-distro[3])**2)
    return(fun)
  }
  gompertz.fit=optim(
    param,
    minQuantileGompertz,
    quantiles=quantiles,
    q=q
  )
  out.fit=gompertz.fit
  asel=out.fit$par[1]
  bsel=out.fit$par[2]
  X <- rgompertz(1e5, asel, bsel)
  #curve(dgompertz(X, asel, bsel), 0, 5, col = "red", add = TRUE)
  distro=qgompertz(q,a=asel,b=bsel)
}


# --- Print results
plotOut=paste("Plot_",labelPlot,"_",distribution,"Distro.pdf",sep="")
pdf(file = plotOut,width=10)
hist(X, 100, freq = FALSE, main=paste(distribution," distribution"),
     xlab=xlabel)
dev.off()
print("** RESULTS **")
print(paste("Target values (CIlow, mean, CIhigh)",quantiles,sep=":"))
print(paste("Optimized values (CIlow, mean, CIhigh)",distro,sep=":"))
if(distribution != "gompertz"){
  print(paste("For parameter = ",stdOut,
              " minimization value = ",funVal," (",distribution," distribution)",sep=""))
}else{
  print(paste("For parameters a = ",asel,", b = ",bsel,
              " (",distribution," distribution)",sep=""))
}

