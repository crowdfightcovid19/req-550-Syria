require(extraDistr) # fits gompertz distribution

# This function considers the epidemiological parameters estimated and creates
# vectors with random number with size the number of simulations. 

### START EDITING
set.seed(18062020) # today 
# ..... Incubation and presymptomatic (the difference will estimate t.Exposed)
t.incub.mean=5.2 # incubation time
t.incub.std=0.18 # lognormal
t.min.incub.mean=16/24 # mean of minimum incubation time
t.min.incub.std=0.14 # 
incub.thr=8/24 # minimum incubation threshold
t.P.param1=0.028 # presymptomatic time, gompertz first param
t.P.param2=1.73 # gompertz second param

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
t.P.vec=rgompertz(Nrand, t.P.param1, t.P.param2) # then presymptomatic
t.E.vec=t.incub.vec-t.P.vec # and the remainder will be exposed
t.E.toolow.index=which(t.E.vec<incub.thr) # however, values <7h are not acceptable
Ntoolow=length(t.E.toolow.index) # identify those
t.E.toolow.vec=rnorm(Ntoolow,mean=t.min.incub.mean,sd=t.min.incub.std) # and generate minimum values compatible with literature
t.E.vec[t.E.toolow.index]=t.E.toolow.vec # and substitute
#
# ..... Symptomatic
fracPtoI.vec=rbinom(Nrand,prob = f.S.mean,size=f.S.param)/f.S.param
t.ItoH.vec=rgamma(Nrand,shape=t.ItoH.shape,scale=t.ItoH.scale)
t.H.vec=rgamma(Nrand,shape=t.H.shape,scale=t.H.scale)
t.ItoD.vec=rgamma(Nrand,shape=t.ItoD.shape,scale=t.ItoD.scale)
#
# ..... R0
R0.mean=4
R0.param=0.43
R0.vec=rnorm(Nrand,mean=R0.mean,sd=R0.param)
#
# ..... tau
tau.mean=0.0059
tau.param=0.0009
tau.vec=rnorm(Nrand,mean = tau.mean,sd=tau.param)
#
# --- Transform to rates
deltaE.vec=1/t.E.vec
deltaP.vec=1/t.P.vec
gammaA=1/t.A.mean
gammaI=1/t.ItoR.mean
gammaH.vec=1/t.H.vec
eta.vec=1/t.ItoH.vec
alpha.vec=1/t.ItoD.vec
