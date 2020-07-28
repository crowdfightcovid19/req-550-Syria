# ****************************************
# create_palette.R
# ****************************************
# 
# 
# author = Alberto Pascual-García 
# email = alberto.pascual.garcia@gmail.com 
# date = 28th July 2020
# description = This function simply creates a palette depending on whether a null model or shielding
#    strategy is considered, to differentiate green/orange zones and age classes

create_palette = function(descr){
  if(descr == "null_model_mixed"){ # five classes considered
    col_qual=c("brown4","red","deeppink1", "orange","gold") # age1, age2NC, age2C, age3NC, age3C
  }else if(descr == "shield_cont2_age3"){
    col_qual=c("brown4","red","deeppink1","green4","green3")
  }else if(descr == "shield_cont2_age3_age2"){
    col_qual=c("brown4","red","olivedrab3","green4","green3")
  }else{
    col_qual=c("brown4","greenyellow","red","olivedrab4","olivedrab3","green4","green3")
  }
  return(col_qual)
}
