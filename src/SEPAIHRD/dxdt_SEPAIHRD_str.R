# --- This function models a time step for the model:
dxdt_SEAIRD_str = function(t, y, parms){
  # Unwrap parmseters: this slows the code, but accessing lists is also very slow)
  # This function should be coded in FORTRAN or C
  #parms=parms.list # DEBUG
  #y=y.start # DEBUG
  #t=times_vector # DEBUG
  scenario=params["scenario"][[1]]
  #betaI=parms["betaI"][[1]]
  #betaA=parms["betaA"][[1]]
  tau=parms["tau"][[1]]
  deltaE=parms["deltaE"][[1]]
  deltaP=parms["deltaP"][[1]]
  gammaA=parms["gammaA"][[1]]
  gammaI=parms["gammaI"][[1]]
  gammaH=parms["gammaH"][[1]]
  eta=parms["eta"][[1]]
  alpha=parms["alpha"][[1]]
  
  fracPtoI=parms["fracPtoI.str"]
  fracItoH.str=unlist(parms["fracItoH.str"][[1]])
  fracItoD.str=unlist(parms["fracItoD.str"][[1]])

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
  for(Ref in classes){ # For each population class
    i=i+1
    S=paste(Ref,"S",sep=".") # Create a label to handle the variable in each compartment
    E=paste(Ref,"E",sep=".")
    P=paste(Ref,"P",sep=".")
    A=paste(Ref,"A",sep=".")
    I=paste(Ref,"I",sep=".")
    H=paste(Ref,"H",sep=".")
    R=paste(Ref,"R",sep=".")
    D=paste(Ref,"D",sep=".")
    f=fracPtoI # double check no age structure
    h=fracItoH.str[Ref]
    g=fracItoD.str[Ref]
    for(var in compartments){ # Compute the derivative in the correspondent compartment
      if(var == "S"){ # susceptibles
        lambda=0 # To estimate lambda
        for(class in classes){ # Consider the probability of contact with own and other pop. classes
          classP=paste(class,"P",sep=".") # Only for infectious compartments, presymptomatic
          classA=paste(class,"A",sep=".") # asymptomatic
          classP=paste(class,"H",sep=".") # hospitalized
          classI=paste(class,"I",sep=".") # and infected
          # Double check the following, there is no beta any more
          lambda= lambda+C[Ref,class](y[classA]+y[classP]+y[classI]+y[classH])
        }
        lambda=tau*lambda/N
        dy[S] = -lambda*y[S]
      }else if(var == "E"){ # Exposed
        dy[E] = lambda*y[S]-deltaE*y[E]
      }else if(var == "P"){ # Presymptomatic
        dy[P] = deltaE*y[E]-deltaP*y[P]
      }else if(var == "A"){ # Asymptomatic
        dy[A] = (1-f)*deltaP*y[P]-gammaA*y[A]
      }else if(var == "I"){ # Mild symptomatic
        dy[I] = f*deltaP*y[P]-((1-g-h)*gammaI+h*eta+g*alpha)*y[I]
      }else if(var == "H"){ # Hospitalized in W countries, the fate of these is uncertain
        dy[H] = h*eta*y[I]-gammaH*y[H]
      }else if(var == "R"){ # Recovered
        if(scenario == 0){ # Lower bound of deaths, hospitalized become recovered
          dy[R] = gammaA*y[A]+(1-g-h)*gammaI*y[I]+gammaH*y[H]
        }else{ # upper bound, hospitalized would all die
          dy[R] = gammaA*y[A]+(1-g-h)*gammaI*y[I]
        }
      }else{ # Dead
        if(scenario == 0){ # Lower bound of deaths, hospitalized become recovered
          dy[D] = g*alpha*y[I]
        }else{  # upper bound, hospitalized would all die
          dy[D] = g*alpha*y[I]+gammaH*y[H]
        }
      }
    }
  }
  
  return(list(dy))
}

