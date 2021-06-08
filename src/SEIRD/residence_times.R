####################
# residence_times.R
####################
# Extracts from tau-leaping simulation an estimation of the
# residence times in the infectious compartment, when individuals
# are then diverted into D and R compartments at different rates.
###################
# author = apascualgarcia.github.io
# date = June 6th, 2021
###################

residence_times = function(model.output){
  Nsteps=dim(model.output)[1]
  Nexp=model.output$R[Nsteps]+model.output$D[Nsteps] # number exposed
  library(plyr)
  I_store=model.output$I[1]; R_store=model.output$R[1]; D_store=model.output$D[1]
  I.time.in=vector(mode="numeric",length = Nexp)
  I.time.out=vector(mode="numeric",length = Nexp)
  I.time.fate=vector(mode="character",length = Nexp)
  I.tail=0;I.head=0;
  for(k in 2:Nsteps){
    time_now=model.output$time[k]
    I_now=model.output$I[k];R_now=model.output$R[k];D_now=model.output$D[k]
    if(I_now > I_store){ # new infected
      I_new=I_now-I_store
      for(u in 1:I_new){
        I.head=I.head+1 # index tracking the head of the list (new infected)
        I.time.in[I.head]=time_now
      }
      I_store=I_now
    }
    if((R_now != R_store)&(D_now != D_store)){ # both changed
      R_new=R_now - R_store # count how many changed for R
      D_new=D_now - D_store # how many for D
      all_new=R_new+D_new # we will consider both together
      R_fate=rep("R",R_new) # create a vector for their fate
      D_fate=rep("D",D_new)
      fate_tmp=c(R_fate,D_fate) # join both
      fate_tmp=sample(fate_tmp) # shuffle their fate
      for(u in 1:all_new){
        I.tail=I.tail+1 # we will distribute their fate randomly
        I.time.out[I.tail]=time_now
        I.time.fate[I.tail]=fate_tmp[u] # track the outcome
      }
      R_store=R_now
      D_store=D_now
    }else if(R_now != R_store){ # jump into R
      R_new=R_now - R_store # count how many changed for R
      for(u in 1:R_new){
        I.tail=I.tail+1 # index tracking the tail of the list (those leaving)
        I.time.out[I.tail]=time_now
        I.time.fate[I.tail]="R" # track the outcome
      }
      R_store=R_now
    }else if(D_now != D_store){ # jump into D/R
      D_new=D_now - D_store # count how many changed for R
      for(u in 1:D_new){
        I.tail=I.tail+1 # index tracking the tail of the list (those leaving)
        I.time.out[I.tail]=time_now
        I.time.fate[I.tail]="D" # track the outcome
      }
      D_store=D_now
    }
  }
  # this df contains the input and output times of each infected
  # individual, the order is the same than the order they were infected
  I.res.df=data.frame(I.time.in,I.time.out,I.time.out-I.time.in, I.time.fate); 
  colnames(I.res.df)=c("in","out","res.time","fate")
  res.time=ddply(I.res.df,"fate",
                 summarise,
                 mean=mean(res.time)
  )
  return(list(res.time,I.res.df))
}