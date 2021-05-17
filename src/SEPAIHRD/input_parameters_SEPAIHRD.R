require(extraDistr) # fits gompertz distribution

# This function considers the epidemiological parameters estimated and creates
# vectors with random number with size the number of simulations. 



### START EDITING
thisScript=0 # by default this must be zero (when called from other scripts)
    # if you want to run just this script, turn it to one and check the if
    # immediately  after STOP EDITING if you want to change isoThr
#set.seed(18062020) # today 
# ..... Incubation and presymptomatic (the difference will estimate t.Exposed)
t.incub.mean=5.2 # incubation time
t.incub.std=0.18 # lognormal
t.min.incub.mean=16/24 # mean of minimum incubation time
t.min.incub.std=0.14 # 
incub.thr=8/24 # minimum incubation threshold
#t.P.param1=0.028 # presymptomatic time, gompertz first param
#t.P.param2=1.73 # gompertz second param
t.P.param1=2.3 # presymptomatic time, gaussian first param
t.P.param2=0.91 # gaussian second param

# ..... Symptomatic compartments
f.S.mean=0.84
f.S.param=240 # Number of trials needed to fit the CI reported

t.A.mean=7 # time to recover for assymptomatic 1/t.A=gamma_A
t.ItoR.mean=7 # mild symptomatic to recover, no distro here 1/t.I=gamma_I

t.ItoH.mean=7 # mild symptomatic to hospitalized
t.ItoH.scale=1.47 # gamma distribution
t.ItoH.shape=t.ItoH.mean/t.ItoH.scale
  
t.H.mean=10 # Time to recover in the hospital 1/t.H = gamma_H (if dying would be alpha_H)
t.H.scale=2.24 # gamma distribution
t.H.shape=t.H.mean/t.H.scale

t.ItoD.mean=10 # time from onset to death in Western countries
t.ItoD.scale=2.13 # gamma distribution
t.ItoD.shape=t.ItoD.mean/t.ItoD.scale

AUC.mean=0.44 # Area Under the Curve infectiousness
AUC.std=0.082 #n normal

betaP.mean=1 # relative infectousness of presymptomatic individuals becoming symptomatic
rhoAI.mean=0.58 # ratio of Asymptomatic to symptomatic infectiousness
rhoAI.std=0.32 # lognormal

rhoHI.mean=0.48 # ratio of hospitalized to symptomatic infectiousness

Ifact.mean=0.24 # factor required to estimate infectiousness ratios, it is = betaI
Ifact.std=0.53

##### STOP EDITING

if(thisScript == 1){ # if you run this script only, these values are needed to avoid errors
  # ..... some params for testing
  isoThr=10
  Nrand=10000
}

# --- Fix onset distribution
if(onset > 0){   # ..... Time between symptom's onset and taking the decision of isolating in a tent
  if(onset == 1){
    t.O.param1=1/24
    t.O.param2=0.010
  }else if(onset == 12){
    t.O.param1=1/2
    t.O.param2=0.11
  }else if(onset == 24){
    t.O.param1=1
    t.O.param2=0.21
  }else{
    t.O.param1=2
    t.O.param2=0.43
  }
  #tents="YES"
}else{ # these values are arbitrary, will not be used but are computed, so we prevent errors
  t.O.param1=1/2
  t.O.param2=0.11
  #tents="NO"
}

# --- Generate random values
#
# ..... Presymptomatic and exposed
t.incub.vec=rlnorm(Nrand,mean=log(t.incub.mean),sd=t.incub.std) # generate incubation
#t.P.vec=rgompertz(Nrand, t.P.param1, t.P.param2) # then presymptomatic
t.P.vec=rnorm(Nrand,mean=t.P.param1,sd=t.P.param2) # then presymptomatic
t.E.vec=t.incub.vec-t.P.vec # and the remainder will be exposed
t.E.toolow.index=which(t.E.vec<incub.thr) # however, values <7h are not acceptable
Ntoolow=length(t.E.toolow.index) # identify those
t.E.toolow.vec=rnorm(Ntoolow,mean=t.min.incub.mean,sd=t.min.incub.std) # and generate minimum values compatible with literature
t.E.vec[t.E.toolow.index]=t.E.toolow.vec # and substitute
t.E.vec.neg=which(t.E.vec<0) # still, this may happen with prob. ~10^(-7) so not neglectable if many simulations are run
t.E.vec[t.E.vec.neg]=t.min.incub.mean
t.P.vec=c(t.P.vec[Nrand],t.P.vec[1:(Nrand-1)]) # we shift one time step to make more likely that they match

# ..... Symptomatic
fracPtoI.vec=rbinom(Nrand,prob = f.S.mean,size=f.S.param)/f.S.param
t.O.vec=rnorm(Nrand,mean=t.O.param1,sd=t.O.param2)
t.O.toolow.index=which(t.O.vec<1/4) # we consider at least 6h of symptoms
t.O.vec[t.O.toolow.index]=1/4
t.ItoH.vec=rgamma(Nrand,shape=t.ItoH.shape,scale=t.ItoH.scale)
t.OtoH.vec=t.ItoH.vec
t.OtoI.vec=t.O.vec
if(onset > 0){ # if they are isolated and there is an onset
  t.ItoH.tmp=t.ItoH.vec-t.O.vec  # this is the time that should remain in "I" once they decide isolate
  idx.neg=which(t.ItoH.tmp<0) # if it is negative it means that all the time till going to H
  t.OtoI.vec[idx.neg]=t.ItoH.vec[idx.neg] # they are in the fully infectious compartment
  t.ItoH.tmp[idx.neg]=1/24 # then we will make them basically skip I
  t.ItoH.vec=c(t.ItoH.tmp[Nrand],t.ItoH.tmp[1:(Nrand-1)]) # we shift one time step to make them match 
}
deltaO.vec=1/t.OtoI.vec
etaO.vec=1/t.OtoH.vec

t.ItoD.vec=rgamma(Nrand,shape=t.ItoD.shape,scale=t.ItoD.scale)
t.OtoD.vec=t.ItoD.vec
if(onset > 0){ # if they are isolated and there is an onset
  t.ItoD.tmp=t.ItoD.vec-t.O.vec  # this is the time that should remain in "I" once they decide isolate
  idx.neg=which(t.ItoD.tmp<0) # if it is negative it means that all the time till going to H
  t.ItoD.tmp[idx.neg]=1/24 # then we will make them basically skip I
  t.ItoD.vec=c(t.ItoD.tmp[Nrand],t.ItoD.tmp[1:(Nrand-1)]) 
}
alphaO.vec=1/t.OtoD.vec

ones=vector(mode="numeric",length = Nrand)
ones=ones+1
t.ItoR.vec=t.ItoR.mean*ones # constant vector if no onset compartment is present
t.OtoR.vec=t.ItoR.vec
if(onset > 0){ # if they are isolated and there is an onset compartment
  t.ItoR.tmp=t.ItoR.vec-t.O.vec  # this is the time that should remain in "I" once they decide isolate
  idx.neg=which(t.ItoR.tmp<0) # if it is negative it means that all the time till going to H
  t.ItoR.tmp[idx.neg]=1/24 # then we will make them basically skip I
  t.ItoR.vec=c(t.ItoR.tmp[Nrand],t.ItoR.tmp[1:(Nrand-1)]) 
}
gammaO.vec=1/t.OtoR.vec

t.H.vec=rgamma(Nrand,shape=t.H.shape,scale=t.H.scale)

#
# ..... R0
R0.mean=4
R0.param=0.43
R0.vec=rnorm(Nrand,mean=R0.mean,sd=R0.param)
#
# ..... tau
tau.mean= -2.896575 # log-normal param: log(mean=0.05415) # older, without beta (normal): 0.0196 # old value 0.00608
tau.param=0.3652693 # log-normal param # older, without beta (normal): 0.00305 # old value  0.0009
#tau.vec=rnorm(Nrand,mean = tau.mean,sd=tau.param)
tau.vec=rlnorm(Nrand,meanlog = tau.mean,sdlog =tau.param)

#
# --- Transform to rates (for onset compartment see onset>0 conditions above)
deltaE.vec=1/t.E.vec
deltaP.vec=1/t.P.vec
idx.neg=which(deltaP.vec<0) # if there are negative values, the presymptomatic does not exist
deltaP.vec[idx.neg]=max(deltaP.vec) # fix to the highest rate
gammaA=1/t.A.mean
gammaI.vec=1/t.ItoR.vec
gammaH.vec=1/t.H.vec
eta.vec=1/t.ItoH.vec
#idx.neg=which(eta.vec<0) # here is where those with little time of symptoms
#eta.vec[idx.neg]=max(eta.vec) # should jump to H (this happens only if onset>0)
alpha.vec=1/t.ItoD.vec

# --- Infectiousness
AUC.vec=rnorm(Nrand,mean = AUC.mean,sd=AUC.std)
rhoAI.vec=rlnorm(Nrand,mean=log(rhoAI.mean),sd=rhoAI.std) 
# ... the following lines of code were used to estimate Ifact, it
#     was then adjusted to a lognorm distribution (see below)
# Ifact=(gammaI*gammaH.vec*(1-AUC.vec))/
#   (AUC.vec*deltaP.vec*(gammaH.vec+rhoHI.mean*gammaI))
# quantile(Ifact,probs = c(0.01,0.05,0.5,0.95,0.99)) # check for rare values
# # mean = 0.24 (95% CI: 0.0774, 0.57); (99% CI: 0.018, 0.81) # lognormal
# idx.norm=which((Ifact < 0.57) & (Ifact > 0.0774)) # 99% of the values, remove abnormally divergent  values
# hist(Ifact[idx.norm],breaks=50) # lognorm
# hist(log(Ifact[idx.norm]),breaks=50) # lognorm
# qqnorm(log(Ifact[idx.norm]))

Ifact.vec=rlnorm(Nrand,mean=log(Ifact.mean),sd=Ifact.std)

betaP.vec=betaP.mean*(fracPtoI.vec+(1-fracPtoI.vec)*rhoAI.vec)
betaI.vec=Ifact.vec
betaA.vec=Ifact.vec*rhoAI.vec
betaH.vec=Ifact.vec*rhoHI.mean

 # quantile(betaP.vec,probs = c(0.01,0.05,0.5,0.95,0.99)) # 0.93 [0.89-0.99]
 # quantile(betaI.vec,probs = c(0.01,0.05,0.5,0.95,0.99))
 # quantile(betaA.vec,probs = c(0.01,0.05,0.5,0.95,0.99))
 # quantile(betaH.vec,probs = c(0.01,0.05,0.5,0.95,0.99))
 # quantile(tau.vec,probs = c(0.01,0.05,0.5,0.95,0.99))
 # 
 # hist(betaP.vec,breaks=50) # 
 # qqnorm(log(betaP.vec))
 # qqline(log(betaP.vec), col = "steelblue", lwd = 2)
 # qqnorm((betaP.vec))
 # qqline((betaP.vec), col = "red", lwd = 2)
 # 
 # hist(betaI.vec,breaks=50) # lognorm
 # qqnorm(log(betaI.vec))
 # qqline(log(betaI.vec), col = "blue", lwd = 2)
 # 
 # hist(betaA.vec,breaks=50) # lognorm
 # qqnorm(log(betaA.vec))
 # qqline(log(betaA.vec), col = "green", lwd = 2)
 # 
 # hist(betaH.vec,breaks=50) # lognorm
 # qqnorm(log(betaH.vec))
 # qqline(log(betaH.vec), col = "black", lwd = 2)
 # 
# quantile(t.O.vec,probs = c(0,0.01,0.05,0.5,0.95,0.99,1))
#  hist(t.O.vec,breaks=50) #
#  qqnorm(t.O.vec)
#  qqline(t.O.vec, col = "red", lwd = 2)
#  
#  quantile(t.ItoH.vec,probs = c(0,0.01,0.05,0.5,0.95,0.99,1))
#  hist(t.ItoH.vec,breaks=50) # 
#  qqnorm(t.ItoH.vec)
#  qqline(t.ItoH.vec, col = "cyan", lwd = 2)
#  
#  quantile(eta.vec,probs = c(0,0.01,0.05,0.5,0.95,0.99,1))
#  