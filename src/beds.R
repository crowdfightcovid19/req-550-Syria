# ****************************************
# beds.R
# ****************************************
# ****************************************
# author = Eduard Campill-Funollet
# email = e.campillo-funollet@sussex.ac.uk
# date = 10th July 2020
# description = Estimate max. number of required hospital beds 
# usage = Just a set of tools, not an script that automatically produce results. Generates table following approach in beds.pdf 



closestPop <- function(x){
    if(x < 750)
        return(500)

    if(x < 1500)
        return(1000)

    return(2000)
}

scalePop <- function(pop){
   closest <- closestPop(pop)

   scale <- pop/closest

   return(scale) 
}

getdfPop <-function(pops){
    df <- data.frame(population=NA,closest=NA,scale=NA)[-1,]
    for(pop in pops$Total.number.of.individuals.living.in.the.camp){
        df[nrow(df)+1,] <- c( pop, closestPop(pop), scalePop(pop) )
    }

    return(df)
}

getdcamps <-function(pops){
    df <- data.frame(population=NA,
                     closest=NA,
                     scale=NA,
                     age1_max=NA,
                     age1_t=NA,
                     age2c_max=NA,
                     age2c_t=NA,
                     age2nc_max=NA,
                     age2nc_time=NA,
                     age3c_max=NA,
                     age3c_time=NA,
                     age3nc_max=NA,
                     age3nc_time=NA)[-1,]

    for(pop in pops$Total.number.of.individuals.living.in.the.camp){
       scale <- scalePop(pop)
       closest <- closestPop(pop)

       if( closest == 500 ){
        dfm <- maxH500
        dft <- timePeak500
       } else if (closest == 1000) {
        dfm <- maxH1000
        dft <- timePeak1000
       } else {
        dfm <- maxH2000
        dft <- timePeak2000
       }

        df[nrow(df)+1,] <- c( pop, 
                              closest,
                              scale,
                              mean(dfm$age1.H)*scale,
                              mean(dft$age1.H),
                              mean(dfm$age2_comorbid.H)*scale,
                              mean(dft$age2_comorbid.H),
                              mean(dfm$age2_no_comorbid.H)*scale,
                              mean(dft$age2_no_comorbid.H),
                              mean(dfm$age3_comorbid.H)*scale,
                              mean(dft$age3_comorbid.H),
                              mean(dfm$age3_no_comorbid.H)*scale,
                              mean(dft$age3_no_comorbid.H))


    }

    return(df)
}



genMaxH <- function(pops,maxH500,maxH1000,maxH2000,timePeak500,timePeak1000,timePeak2000){
   pop <- pops[sample(nrow(pops),1),]
   scale <- scalePop(pop)
   closest <- closestPop(pop)

   if( closest == 500 ){
    df <- maxH500
    dft <- timePeak500
   } else if (closest == 1000) {
    df <- maxH1000
    dft <- timePeak1000
   } else {
    df <- maxH2000
    dft <- timePeak2000
   }

   row<-sample(nrow(df),1)

   r <- df[row,]
   r <- r*scale

   time<-dft[row,]
  

   return(c(as.list(r),as.list(time))) 
}

#dfpops <- getdcamps(pops) 
#r$> max(dfpops$age1_max+dfpops$age2c_max+dfpops$age2nc_max+dfpops$age3c_max+dfpops$age3nc_max)                                                                         [#[1] 182.5519

