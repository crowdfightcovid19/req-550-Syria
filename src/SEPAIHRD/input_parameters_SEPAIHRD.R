require(extraDistr) # fits gompertz distribution

# This function considers the epidemiological parameters estimated and creates
# vectors with random number with size the number of simulations. 

### START EDITING
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

# ..... Time between symptom's onset and taking the decision of isolating in a tent
# ..... these values are set now in the main code with the option onset, uncomment if you use this script only
# t.O.param1=2
# t.O.param2=0.43
  
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
##### STOP EDITING

# --- Generate random values
#
# ..... Presymptomatic and exposed
t.incub.vec=rlnorm(Nrand,mean=log(t.incub.mean),sd=t.incub.std) # generate incubation
#t.P.vec=rgompertz(Nrand, t.P.param1, t.P.param2) # then presymptomatic
t.P.vec=rnorm(Nrand,mean=t.P.param1,sd=t.P.param2)
t.E.vec=t.incub.vec-t.P.vec # and the remainder will be exposed
t.E.toolow.index=which(t.E.vec<incub.thr) # however, values <7h are not acceptable
Ntoolow=length(t.E.toolow.index) # identify those
t.E.toolow.vec=rnorm(Ntoolow,mean=t.min.incub.mean,sd=t.min.incub.std) # and generate minimum values compatible with literature
t.E.vec[t.E.toolow.index]=t.E.toolow.vec # and substitute

# ..... Symptomatic
fracPtoI.vec=rbinom(Nrand,prob = f.S.mean,size=f.S.param)/f.S.param
t.O.vec=rnorm(Nrand,mean=t.O.param1,sd=t.O.param2)
t.ItoH.vec=rgamma(Nrand,shape=t.ItoH.shape,scale=t.ItoH.scale)
if(isoThr > 0){ # if they are isolated
  t.ItoH.tmp=t.ItoH.vec-t.O.vec  # this is the time that should remain in "I" once they decide isolate
  idx.neg=which(t.ItoH.tmp<0) # if it is negative it means that all the time till going to H
  t.O.vec[idx.neg]=t.ItoH.vec[idx.neg] # they are in the fully infectious compartment
  t.ItoH.vec=t.ItoH.tmp # then we will make them basically skip I below and jump to H
}
t.H.vec=rgamma(Nrand,shape=t.H.shape,scale=t.H.scale)
t.ItoD.vec=rgamma(Nrand,shape=t.ItoD.shape,scale=t.ItoD.scale)
#
# ..... R0
R0.mean=4
R0.param=0.43
R0.vec=rnorm(Nrand,mean=R0.mean,sd=R0.param)
#
# ..... tau
tau.mean=0.0196 # old value 0.00608
tau.param=0.00305 # old value  0.0009
tau.vec=rnorm(Nrand,mean = tau.mean,sd=tau.param)
#
# --- Transform to rates
deltaE.vec=1/t.E.vec
deltaP.vec=1/t.P.vec
idx.neg=which(deltaP.vec<0) # if there are negative values, the presymptomatic does not exist
deltaP.vec[idx.neg]=max(deltaP.vec) # fix to the highest rate
deltaO.vec=1/t.O.vec
gammaA=1/t.A.mean
gammaI=1/t.ItoR.mean
gammaH.vec=1/t.H.vec
eta.vec=1/t.ItoH.vec
idx.neg=which(eta.vec<0) # here is where those with little time of symptoms
eta.vec[idx.neg]=max(eta.vec) # should jump to H (this happens only if isoThr>0)
alpha.vec=1/t.ItoD.vec
