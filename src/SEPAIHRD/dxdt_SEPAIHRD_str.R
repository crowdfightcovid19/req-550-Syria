# --- This function models a time step for the model:
dxdt_SEPAIHRD_str = function(t, y, parms){
  # Unwrap parmseters: this slows the code, but accessing lists is also very slow)
  # This function should be coded in FORTRAN or C
  #parms=parms.list # DEBUG
  #y=y.start # DEBUG
  #t=times_vector # DEBUG
  #browser() # DEBUG
  Tcheck.mat=parms["Tcheck.mat"][[1]]
  lock.mat=parms["lock.mat"][[1]]
  hospitalized2=parms["hospitalized2"][[1]]
  isolation=parms["isolation"][[1]]
  isoThr=parms["isoThr"][[1]]
  lockDown=parms["lockDown"][[1]]
  hosp.idx=parms["hosp.idx"][[1]]
  inf.idx=parms["inf.idx"][[1]]
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
  
  Nsubpop=unlist(parms["Nsubpop"][[1]])
  fracPtoI=parms["fracPtoI"][[1]]
  fracItoH.str=unlist(parms["fracItoH.str"][[1]])
  fracItoD.str=unlist(parms["fracItoD.str"][[1]])

  C=parms["Cont"][[1]] 
  classes=unlist(parms["classes"][[1]])
  #vars=unlist(parms["vars"][[1]])
  compartments=unlist(parms["compartments"][[1]])
  # if(any(y<0)){
  #   warning("** negative population values ** ") # DEBUG
  # }
  N = sum(y) # Total population size
  
  # --- Quantify people at the H compartment
  Htot = sum(y[hosp.idx]) # people which needs to be in isolation, heavy symptoms
  Itot = sum(y[inf.idx]) # mild symptoms
  Qtot = Htot+Itot  # total should be quarantined
  isoDiff = isoThr-Qtot # check if there is space in isolation camps
  if(isoDiff > 0){ # if it is
    Qinf=0 # They will be removed, so they are not infectious
  }else{ # if there is no space
    isoDiff=abs(isoDiff) # the difference will stay in the camp
    Qinf=1 # so they are infectious
  }
  lock.mat.local=matrix(1,ncol=ncol(lock.mat),nrow=nrow(lock.mat))
  rownames(lock.mat.local)=rownames(lock.mat)
  colnames(lock.mat.local)=colnames(lock.mat)
  if(lockDown == "YES"){ # If there is a possible lockdown 
    if(Itot > 1){ # As soon as there is one case
      lock.mat.local=lock.mat # apply lockdown
    }
  }

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
          classH=paste(class,"H",sep=".") # hospitalized
          classI=paste(class,"I",sep=".") # and infected
          # ... Reduce the infectivity of symptomatic under some scenarios
          if(isolation == "YES"){ # If there is the possibility of isolation
            if(Qtot==0){
              yFracI=0
              yFracH=0
            }else{
              yFracI=(y[classI]/Qtot)*isoDiff
              yFracH=(y[classH]/Qtot)*isoDiff # distribute infectivity of those that cannot be isolated proportionally to their number across classes
            }
            yClassI=Qinf*Tcheck.mat[Ref,class]*yFracI
            yClassH=Qinf*Tcheck.mat[Ref,class]*yFracH # considers both isolation and symptomatic interacting if tests are put in place
          }else{
            yClassI=Tcheck.mat[Ref,class]*y[classI]
            yClassH=Tcheck.mat[Ref,class]*y[classH] # only affects classes being tested
          }
          #yClassI=Tcheck.mat[Ref,class]*y[classI] # only affects classes being tested
          # ... Compute lambda
          lambda = lambda+C[Ref,class]*lock.mat.local[Ref,class]*(y[classP]+y[classA]+
                                         yClassI+yClassH)/Nsubpop[class]
        }
        lambda=tau*lambda
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
        if(hospitalized2 == "R"){ # Lower bound of deaths, hospitalized become recovered
          dy[R] = gammaA*y[A]+(1-g-h)*gammaI*y[I]+gammaH*y[H]
        }else{ # upper bound, hospitalized wold all die
          dy[R] = gammaA*y[A]+(1-g-h)*gammaI*y[I]
        }
      }else{ # Dead
        if(hospitalized2 == "R"){ # Lower bound of deaths, hospitalized become recovered
          dy[D] = g*alpha*y[I]
        }else{  # upper bound, hospitalized would all die
          dy[D] = g*alpha*y[I]+gammaH*y[H]
        }
      }
    }
  }
  # idx=grep("age2_no_comorbid_orange",names(y)) # DEBUG
  # y[idx] # DEBUG
  # lambda
  # y=y+dy # DEBUG
  return(list(dy)) # Deterministic version
}

