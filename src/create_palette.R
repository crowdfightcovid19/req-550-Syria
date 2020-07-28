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
    # age1, age2NC, age2C, age3NC, age3C
    col_qual=c("brown4","red","deeppink1", "orange","gold")
  }else if(descr == "shield_cont2_age3"){
    # age1, age2NC, age2C, age3NC_g, age3C_g
    col_qual=c("brown4","red","deeppink1","green4","green3")
  }else if(descr == "shield_cont2_age3_age2"){
    # age1, age2NC, age2C_g, age3NC_g, age3C_g
    col_qual=c("brown4","red","gold","green4","green3")
  }else{
    # age1_g, age1_o, age2_c_g, age2_nc_g, age2_nc_o, age3_c_g, age3_nc_g 
    col_qual=c("greenyellow","brown4","gold","khaki1","red","green4","green3")
  }
  return(col_qual)
}
