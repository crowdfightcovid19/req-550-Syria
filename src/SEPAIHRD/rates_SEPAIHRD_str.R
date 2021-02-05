# --- This function models a time step for the stochastic model, 
#     see dxdt_SEPAIHRD_str for the deterministic version
rates_SEPAIHRD_str = function(y, parms,t){
  # parms=parms.list # DEBUG
  # y=y.start # DEBUG
  # t=2 # DEBUG
  #t=times_vector # DEBUG
  #browser() # DEBUG
  
  # --- Extract  parameters
  # .... Single-value parameters
  Ntrans=parms["Ntrans"][[1]] #  see github issue 26
  model.type=parms["model.type"][[1]]
  Tcheck.mat=parms["Tcheck.mat"][[1]]
  lock.mat=parms["lock.mat"][[1]]
  hospitalized2=parms["hospitalized2"][[1]]
  carers.mat=parms["carers.mat"][[1]]
  Hinfect=parms["Hinfect"][[1]]
  xi=parms["xi"][[1]]
  self=parms["self"][[1]]
  # isolation=parms["isolation"][[1]] # No longer used, the relevant param is now Hinfect
  isoThr=parms["isoThr"][[1]]
  lockDown=parms["lockDown"][[1]]
  hosp.idx=parms["hosp.idx"][[1]]
  inf.idx=parms["inf.idx"][[1]]
  gammaA=parms["gammaA"][[1]]
  gammaI=parms["gammaI"][[1]]
  betaP=parms["betaP"][[1]]
  # ... Single-value parameters for "stochastic_fixed" and vectors for "stochastic_variable"
  if(model.type=="stochastic_fixed"){ 
    tau=parms["tau"][[1]] # Simply unwrap, there is one value
    betaA=parms["betaA"][[1]]
    betaI=parms["betaI"][[1]]
    betaH=parms["betaH"][[1]]
    deltaE=parms["deltaE"][[1]]
    deltaP=parms["deltaP"][[1]]
    deltaO=parms["deltaO"][[1]]
    gammaH=parms["gammaH"][[1]]
    eta=parms["eta"][[1]]
    alpha=parms["alpha"][[1]]
    fracPtoI=parms["fracPtoI"][[1]]
  }else{ # There is one vector of parameters, and we want to pick a different value each time
    t.int <<- t.int+1 # This becomes a global variable
    time=t.int
    tau=unlist(parms["tau"][[1]])[time]
    betaA=unlist(parms["betaA"][[1]])[time]
    betaI=unlist(parms["betaI"][[1]])[time]
    betaH=unlist(parms["betaH"][[1]])[time]
    deltaE=unlist(parms["deltaE"][[1]])[time]
    deltaP=unlist(parms["deltaP"][[1]])[time]
    deltaO=unlist(parms["deltaO"][[1]])[time]
    gammaH=unlist(parms["gammaH"][[1]])[time]
    eta=unlist(parms["eta"][[1]])[time]
    alpha=unlist(parms["alpha"][[1]])[time]
    fracPtoI=unlist(parms["fracPtoI"][[1]])[time]
  }
  # .... Parameters dependent on population structure
  Nsubpop=unlist(parms["Nsubpop"][[1]])
  fracItoH.str=unlist(parms["fracItoH.str"][[1]])
  fracItoD.str=unlist(parms["fracItoD.str"][[1]])
  
  # .... Set up the number of compartments
  # if(isoThr == 0){
  #   Ntrans=9 # dirty way to fix the number of transitions, see github issue 26
  # }else{
  #   Ntrans=10
  # }
  
  # .... Contact matrix, classes and compartments
  C=parms["Cont"][[1]] 
  classes=unlist(parms["classes"][[1]])
  #vars=unlist(parms["vars"][[1]])
  compartments=unlist(parms["compartments"][[1]])
  # if(any(y<0)){
  #   warning("** negative population values ** ") # DEBUG
  # }
  N = sum(y) # Total population size
  
  # --- Initialize vars for isolation in tents
  # ..... Quantify people at the symptomatic compartments
  #Htot = sum(y[hosp.idx]) # people which needs to be in isolation, heavy symptoms
  Itot = sum(y[inf.idx]) # mild symptoms, these are the only ones that can stay in tents
  Niso = isoThr*y[inf.idx]
  names(Niso)=classes
  if(Itot > 0){ # Niso will be zero otherwise for all classes
    Niso = Niso/Itot
  }
  
  # --- Initialize vars for lockdown
  lock.mat.local=matrix(1,ncol=ncol(lock.mat),nrow=nrow(lock.mat))
  rownames(lock.mat.local)=rownames(lock.mat)
  colnames(lock.mat.local)=colnames(lock.mat)
  if(lockDown == "YES"){ # If there is a possible lockdown 
    if(Itot > 1){ # As soon as there is one case
      lock.mat.local=lock.mat # apply lockdown
    }
  }
  
  # --- Initialize vector of derivatives
  # see github issue 26 related to how dy is built
  dy=as.vector(matrix(0,nrow=1,
                      ncol=(length(classes)*Ntrans))) # Getting a vector ordered in the same way than y
  #names(dy)=names(y) # the names of the transitions should be here
  i=0
  k=0
  for(Ref in classes){ # For each population class
    i=i+1
    S=paste(Ref,"S",sep=".") # Create labels to handle variables and transitions
    E=paste(Ref,"E",sep=".")
    P=paste(Ref,"P",sep=".")
    if(isoThr>0){
      O=paste(Ref,"O",sep=".")
    }
    A=paste(Ref,"A",sep=".")
    I=paste(Ref,"I",sep=".")
    H=paste(Ref,"H",sep=".")
    R=paste(Ref,"R",sep=".")
    D=paste(Ref,"D",sep=".")
    f=fracPtoI # double check no age structure
    h=fracItoH.str[Ref]
    g=fracItoD.str[Ref]
    
    Nexp=y[S]+y[E]+y[P]+y[A]+y[R] # exposed individuals (may interact with infected in isolation, i.e. become carers)
    lambda=0 # To estimate lambda
    for(class in classes){ # Consider the probability of contact with own and other pop. classes
      classP=paste(class,"P",sep=".") # Only for infectious compartments, presymptomatic
      classA=paste(class,"A",sep=".") # asymptomatic
      classH=paste(class,"H",sep=".") # hospitalized
      classI=paste(class,"I",sep=".") # and infected
      # ... Reduce the infectivity of symptomatic under some scenarios
      if(isoThr > 0){ # If there are tents for isolation
        classO=paste(class,"O",sep=".") # symptomatic, but not isolated yet
        # .... Address the infectivity of isolated first.
        #      The following condition should not be needed with carers.mat, just to prevent weird things to happen
        if(Nexp > 0){ # There are available carers 
          frac.exp=Niso[class]/Nexp # Note that it could be > 0
        }else{ # otherwise it means all carers died (very unlikely)
          isoThr=0 # so isolation does no longer make sense
          Niso=Niso*0
          frac.exp=0 # all are exposed
        }
        iso.transm = xi*carers.mat[Ref,class]*frac.exp # transmission from isolated
        
        # .... Address the infectivity of non-isolated
        if(Itot > isoThr){ # this happens if the capacity of isolation is insufficient
          Nfree=y[classI]-Niso[class] # number of non-isolated exceeding the capacity
        }else{ 
          Nfree=0
        }
        yClassI=Tcheck.mat[Ref,class]*(Nfree+y[classO]) # they are infectious
      }else{ # no isolation
        yClassI=Tcheck.mat[Ref,class]*y[classI] # all are fully infectious
        iso.transm=0 # the isolation transmission does not hold
      }
      yClassH=Tcheck.mat[Ref,class]*y[classH] # these individuals do not pass a symptoms' check
      # ... Compute lambda
      lambda = lambda+
               iso.transm+
               C[Ref,class]*self*lock.mat.local[Ref,class]*
                      (betaP*y[classP]+betaA*y[classA]+
                         betaI*yClassI+betaH*Hinfect*yClassH)/Nsubpop[class]
    }
    lambda=tau*lambda
    k=k+1 # see github issue 26
    dy[k] = lambda*y[S] # S to E
    k=k+1
    dy[k] = deltaE*y[E] # E to P
    k=k+1
    dy[k] = (1-f)*deltaP*y[P] # P to A
    k=k+1
    dy[k] = f*deltaP*y[P] # P to I if isoThr=0, to O otherwise
    k=k+1
    dy[k] = gammaA*y[A] # Asymptomatic to R
    if(isoThr>0){
      k=k+1
      dy[k] = (1-g-h)*gammaI*y[O] # Onset-Infected to R
      k=k+1
      dy[k] = h*deltaO*y[O] # Onset-Infected to Late-Infected
      k=k+1
      dy[k] = g*alpha*y[O] # Onset-Infected to D
    }
    k=k+1
    dy[k] = (1-g-h)*gammaI*y[I] # Infected to R
    k=k+1
    dy[k] = h*eta*y[I] # Infected to H
    k=k+1
    dy[k] = g*alpha*y[I] # Infected to D
    k=k+1
    dy[k] = gammaH*y[H] # Hospitalized in W countries, the fate of these is uncertain, it is controlled in the transitions
  }
  # idx=grep("age2_no_comorbid_orange",names(y)) # DEBUG
  # y[idx] # DEBUG
  # lambda
  # y=y+dy # DEBUG
  return(dy) # Deterministic version
}

