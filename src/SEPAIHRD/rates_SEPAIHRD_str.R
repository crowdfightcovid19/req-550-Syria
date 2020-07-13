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
  Ntrans=9 # dirty way to fix the number of transitions, see github issue 26
  model.type=parms["model.type"][[1]]
  Tcheck.mat=parms["Tcheck.mat"][[1]]
  lock.mat=parms["lock.mat"][[1]]
  hospitalized2=parms["hospitalized2"][[1]]
  self=parms["self"][[1]]
  isolation=parms["isolation"][[1]]
  isoThr=parms["isoThr"][[1]]
  lockDown=parms["lockDown"][[1]]
  hosp.idx=parms["hosp.idx"][[1]]
  inf.idx=parms["inf.idx"][[1]]
  gammaA=parms["gammaA"][[1]]
  gammaI=parms["gammaI"][[1]]
  # ... Single-value parameters for "stochastic_fixed" and vectors for "stochastic_variable"
  if(model.type=="stochastic_fixed"){ 
    tau=parms["tau"][[1]] # Simply unwrap, there is one value
    deltaE=parms["deltaE"][[1]]
    deltaP=parms["deltaP"][[1]]
    gammaH=parms["gammaH"][[1]]
    eta=parms["eta"][[1]]
    alpha=parms["alpha"][[1]]
    fracPtoI=parms["fracPtoI"][[1]]
  }else{ # There is one vector of parameters, and we want to pick a different value each time
    t.int <<- t.int+1 # This becomes a global variable
    time=t.int
    tau=unlist(parms["tau"][[1]])[time]
    deltaE=unlist(parms["deltaE"][[1]])[time]
    deltaP=unlist(parms["deltaP"][[1]])[time]
    gammaH=unlist(parms["gammaH"][[1]])[time]
    eta=unlist(parms["eta"][[1]])[time]
    alpha=unlist(parms["alpha"][[1]])[time]
    fracPtoI=unlist(parms["fracPtoI"][[1]])[time]
  }
  # .... Parameters dependent on population structure
  Nsubpop=unlist(parms["Nsubpop"][[1]])
  fracItoH.str=unlist(parms["fracItoH.str"][[1]])
  fracItoD.str=unlist(parms["fracItoD.str"][[1]])
  
  # .... Contact matrix, classes and compartments
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
    A=paste(Ref,"A",sep=".")
    I=paste(Ref,"I",sep=".")
    H=paste(Ref,"H",sep=".")
    R=paste(Ref,"R",sep=".")
    D=paste(Ref,"D",sep=".")
    f=fracPtoI # double check no age structure
    h=fracItoH.str[Ref]
    g=fracItoD.str[Ref]
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
      lambda = lambda+C[Ref,class]*self*lock.mat.local[Ref,class]*(y[classP]+y[classA]+
                                                                yClassI+yClassH)/Nsubpop[class]
      #lambda = lambda+C[Ref,class]*(y[classP]+y[classA]+yClassI+yClassH)/Nsubpop[class]
    }
    lambda=tau*lambda
    k=k+1 # see github issue 26
    dy[k] = lambda*y[S] # S to E
    k=k+1
    dy[k] = deltaE*y[E] # E to P
    k=k+1
    dy[k] = (1-f)*deltaP*y[P] # P to A
    k=k+1
    dy[k] = f*deltaP*y[P] # P to I
    k=k+1
    dy[k] = gammaA*y[A] # Asymptomatic to R
    k=k+1
    dy[k] = (1-g-h)*gammaI*y[I] # Infected to R
    k=k+1
    dy[k] = h*eta*y[I] # Infected to H
    k=k+1
    dy[k] = g*alpha*y[I] # Infected to death
    k=k+1
    dy[k] = gammaH*y[H] # Hospitalized in W countries, the fate of these is uncertain
  }
  # idx=grep("age2_no_comorbid_orange",names(y)) # DEBUG
  # y[idx] # DEBUG
  # lambda
  # y=y+dy # DEBUG
  return(dy) # Deterministic version
}

