###############################################
# estimation_R0_function.R
###############################################
#
# author = Alberto Pascual-García
# email = alberto.pascual.garcia@gmail.com 
# date = 22th june 2020
# description = This function computes R0 for each realization k of model parameters (Nrand times)
#               through the computation of the Next Generation Matrix spectrum.


estimation_R0_function = function(parms){
  
  # --- Extract parameters
  tau.vec=parms["tau.vec"][[1]]
  deltaP.vec=parms["deltaP.vec"][[1]]
  gammaA=parms["gammaA"][[1]]
  gammaI=parms["gammaI"][[1]]
  gammaH.vec=parms["gammaH.vec"][[1]]
  eta.vec=parms["eta.vec"][[1]]
  alpha.vec=parms["alpha.vec"][[1]]
  fracPtoI.vec=parms["fracPtoI.vec"][[1]]
  fracItoH.str=unlist(parms["fracItoH.str"][[1]])
  fracItoD.str=unlist(parms["fracItoD.str"][[1]])
  av.cont=unlist(parms["av.cont"][[1]])
  mij=unlist(parms["mij"][[1]])
  epsilon=unlist(parms["epsilon"][[1]])
  Nrand=parms["Nrand"][[1]]
  # ..... Create the matrix of contacts
  av.cont.mat=as.vector(av.cont)*matrix(1,nrow=dim(C)[1],ncol=dim(C)[2])
  # ..... Multiply the matrix by the interventions
  av.cont.mat=av.cont.mat*epsilon*mij  # Check this 
  #N.str=as.matrix(N*class.str)
  # --- Compute NGM
  for(k in 1:Nrand){
    scope=av.cont.mat*as.vector(fracPtoI.vec[k])
    kappa=(1-fracItoH.str-fracItoD.str)*gammaI+
      fracItoH.str*eta.vec[k]+
      fracItoD.str*alpha.vec[k]
    A1=1/deltaP.vec[k]
    A2=(1-fracPtoI.vec[k])/gammaA
    A3=as.vector(as.matrix(fracPtoI.vec[k]/kappa))
    A4=as.vector(as.matrix((fracPtoI.vec[k]*fracItoH.str*eta.vec[k])/
                             (kappa*gammaH.vec[k])))
    Ks= tau.vec[k]*(A1+A2+A3+A4)*scope
    spectra=eigen(Ks)
    lambdas=spectra$values
    lambdas.sort=sort(abs(Re(lambdas)),decreasing = TRUE)
    R0.vec[k]=lambdas.sort[1]
  }
  return(R0.vec)
}
