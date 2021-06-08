
rates_SEIRD = function(y, parms,t){
  #browser()
  Ntrans=parms["Ntrans"][[1]] 
  model.rate=parms["model.rate"][[1]] 

  if(model.type=="stochastic_fixed"){ 
    g=parms["g"][[1]] # Simply unwrap, there is one value
    tau=parms["tau"][[1]] 
    betaI=parms["betaI"][[1]]
    gammaR=parms["gammaR"][[1]]
    gammaD=parms["gammaD"][[1]]
  }else{
    t.int <<- t.int+1 # This becomes a global variable
    time=t.int   
    g=parms["g"][[1]] # Simply unwrap, there is one value
    #g=unlist(parms["g"][[1]])[time]
    tau=unlist(parms["tau"][[1]])[time] # we pick one value per time point
    gammaD=unlist(parms["gammaD"][[1]])[time]
    gammaR=unlist(parms["gammaR"][[1]])[time]
  }
  N=sum(y)
  dy=as.vector(matrix(0,nrow=1,ncol=Ntrans))
  k=0
  if(model.rate == "caseA"){
    lambda=tau*betaI*y[I]/N
    k=k+1 # see github issue 26
    dy[k] = lambda*y[S] # S to I
    k=k+1
    dy[k] = y[E] # E to I
    k=k+1
    dy[k] = g*gammaR*y[I] # Infected to R
    k=k+1
    dy[k] = (1-g)*gammaD*y[I] # Infected to D
    
  }else{
    lambda=tau*betaI*(y[IR]+y[ID])/N
    k=k+1 #
    dy[k] = lambda*y[S] # S to E
    k=k+1 #
    dy[k] = g*y[E] # E to IR
    k=k+1
    dy[k] = (1-g)*y[E] # E to ID
    k=k+1
    dy[k] = gammaR*y[IR] # Infected to R
    k=k+1
    dy[k] = gammaD*y[ID] # Infected to D
  }
  return(dy)
}
