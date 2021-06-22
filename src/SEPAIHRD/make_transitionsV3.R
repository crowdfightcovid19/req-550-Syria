# ****************************************
# make_transitionsV3.R
# ****************************************
# 
# 
# author = Alberto Pascual-García 
# email = alberto.pascual.garcia@gmail.com 
# date = 9th July 2020
# description = This function creates the transitions for running the tau-leaping simulations.
# usage = It is sourced within SEPAIHRD-Syria_structured.R

make_transitions = function(class.names,var.names,hospitalized2){
  require(adaptivetau)
  
  i=0
  for(Ref in class.names){
    i=i+1
    S.vars=paste(Ref,"S",sep=".") # Create labels to handle variables and transitions
    E.vars=paste(Ref,"E",sep=".")
    P.vars=paste(Ref,"P",sep=".")
    A.vars=paste(Ref,"A",sep=".")
    I.vars=paste(Ref,"I",sep=".")
    H.vars=paste(Ref,"H",sep=".")
    V.vars=paste(Ref,"V",sep=".")
    R.vars=paste(Ref,"R",sep=".")
    D.vars=paste(Ref,"D",sep=".")
    if(hospitalized2=="D"){
      DR.vars=paste(Ref,"D",sep=".")
    }else{
      DR.vars=paste(Ref,"R",sep=".")
    }
    A.tmp=cbind(rbind(S.vars,-1,E.vars,+1), # This matrix lists all the transitions for class Ref
            rbind(E.vars,-1,P.vars,+1), 
            rbind(P.vars,-1,A.vars,+1),
            rbind(P.vars,-1,I.vars,+1),  
            rbind(A.vars,-1,R.vars,+1), 
            rbind(I.vars,-1,R.vars,+1),
            rbind(I.vars,-1,H.vars,+1),   
            rbind(I.vars,-1,V.vars,+1), 
            rbind(V.vars,-1,D.vars,+1),   
            rbind(H.vars,-1,DR.vars,+1))
    if(i==1){
      A=A.tmp
    }else{
      A=cbind(A,A.tmp)
    }
  }
  
  trans=ssa.maketrans(var.names,A) # Create the transitions list
  
  return(trans)
}




