# --- This function models a time step for the model:
dxdt_SEAIRD_str = function(t, y, parms){
  # Unwrap parmseters: this slows the code, but accessing lists is also very slow)
  # This function should be coded in FORTRAN or C
  #parms=parms.list # DEBUG
  #y=y.start # DEBUG
  #t=times_vector # DEBUG
  betaI=parms["betaI"][[1]]
  betaA=parms["betaA"][[1]]
  deltaE=parms["deltaE"][[1]]
  gammaA=parms["gammaA"][[1]]
  eta=parms["eta"][[1]]
  fracAI.vec=unlist(parms["fracAI.str"][[1]])
  gamma.vec=unlist(parms["gammaI.str"][[1]])
  alpha.vec=unlist(parms["alpha.str"][[1]])
  C=parms["Cont"][[1]]
  classes=unlist(parms["classes"][[1]])
  #vars=unlist(parms["vars"][[1]])
  compartments=unlist(parms["compartments"][[1]])
  if(any(y<0)){
    warning("** negative population values ** ") # DEBUG
  }
  N = sum(y) # Should deaths be excluded here, it does not make sense to me including it  in lambda
  dy=as.vector(matrix(0,nrow=1,ncol=length(y))) # Getting a vector ordered in the same way than y
  names(dy)=names(y) # requires these steps if then we aim to fill it by name below
  i=0
  for(classRef in classes){ # For each population class
    i=i+1
    classRefS=paste(classRef,"S",sep=".") # Create a label to handle the variable in each compartment
    classRefE=paste(classRef,"E",sep=".")
    classRefA=paste(classRef,"A",sep=".")
    classRefI=paste(classRef,"I",sep=".")
    classRefR=paste(classRef,"R",sep=".")
    classRefQ=paste(classRef,"Q",sep=".")
    classRefD=paste(classRef,"D",sep=".")
    for(var in compartments){ # Compute the derivative in the correspondent compartment
      if(var == "S"){ # susceptibles
        lambda=0 # To estimate lambda
        for(classInf in classes){ # Consider the probability of contact with own and other pop. classes
          classInfA=paste(classInf,"A",sep=".") # And the epid. parameters of asymptomatic
          classInfI=paste(classInf,"I",sep=".") # and infected 
          lambda= lambda+(betaA*y[classInfA]*C[classRef,classInf]+
                     betaI*y[classInfI]*C[classRef,classInf])
        }
        lambda=lambda/N
        dy[classRefS] = -lambda*y[classRefS]
      }else if(var == "E"){ # Exposed
        dy[classRefE] = lambda*y[classRefS]-deltaE*y[classRefE]
      }else if(var == "A"){ # Asymptomatic
        dy[classRefA] = (1-fracAI.vec[classRef])*deltaE*y[classRefE]-
          gammaA*y[classRefA]
      }else if(var == "I"){ # Infected
        dy[classRefI] = fracAI.vec[classRef]*deltaE*y[classRefE]-
          (gamma.vec[classRef]+psi+alpha.vec[classRef])*y[classRefI]
      }else if(var == "R"){ # Recovered
        dy[classRefR] = gamma.vec[classRef]*y[classRefI]+
          +gammaQ*y[classRefQ]+gammaA*y[classRefA]
      }else if(var == "Q"){ # Quarantined
        dy[classRefQ] = psi*y[classRefI]-
          (gammaQ+alpha.vec[classRef])*y[classRefQ]
      }else{ # Dead
        dy[classRefD] =  alpha.vec[classRef]*(y[classRefI]+y[classRefQ])
      }
    }
  }
  
  return(list(dy))
}

