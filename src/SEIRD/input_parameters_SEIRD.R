# --- gamma

f=0.5 # desired fraction going to D or R

t.ItoR.mean=7 # mild symptomatic to hospitalized
t.ItoR.scale=0.2 

t.ItoD.mean=14 # 
t.ItoD.scale=0.4 

t.ItoR.vec=rnorm(Nrand,mean=t.ItoR.mean,sd=t.ItoR.scale)
t.ItoD.vec=rnorm(Nrand,mean=t.ItoD.mean,sd=t.ItoD.scale)

# .... beta
betaI=1 # relative infectousness of presymptomatic individuals becoming symptomatic


# ..... tau
tau.mean= -2.896575 # log-normal param: log(mean=0.05415) # older, without beta (normal): 0.0196 # old value 0.00608
tau.param=0.3652693 # log-normal param # older, without beta (normal): 0.00305 # old value  0.0009
#tau.vec=rnorm(Nrand,mean = tau.mean,sd=tau.param)
tau.vec=rlnorm(Nrand,meanlog = tau.mean,sdlog =tau.param)

gammaR.vec=1/t.ItoR.vec
gammaD.vec=1/t.ItoD.vec

if(model.rate == "caseA"){
  g=(f*mean(gammaD.vec))/(mean(gammaR.vec)*(1-f)+f*mean(gammaD.vec))
  #g=((1-f)*gammaR.vec)/(gammaD.vec*(1-f)-f*gammaD.vec)
}else{
  g=f
}


#quantile(gammaR.vec,probs = c(0.01,0.05,0.5,0.95,0.99)) # 0.93 [0.89-0.99]
#quantile(gammaD.vec,probs = c(0.01,0.05,0.5,0.95,0.99))
