#***************************************
# safety_age_groups.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 30th July 2020
#description = plots for deaths in green zone 
#usage = Run from src

df.null <- read.csv("../../data/real_models/null_model_mixed/IsolateNO_Limit2000_Onset24_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV/FracFinalDeaths_SEPAIHRD_dynamics_null_model_mixed_IsolateNO_Limit2000_Onset24_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV.dat")  

df.shield <- read.csv("../../data/real_models/shield_cont2_age3/IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV/FracFinalDeaths_SEPAIHRD_dynamics_shield_cont2_age3_IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV.dat")   

df <- data.frame(class=NA,model=NA,FracDeaths=NA)[-1,]

df <- rbind(df, cbind( class=rep("age1",500), model=rep("null",500),FracDeaths=df.null$age1.D) )
df <- rbind(df, cbind( class=rep("age2_no_comorbid",500), model=rep("null",500),FracDeaths=df.null$age2_no_comorbid.D))
df <- rbind(df, cbind( class=rep("age2_comorbid",500), model=rep("null",500),FracDeaths=df.null$age2_comorbid.D))
df <- rbind(df, cbind( class=rep("age3_no_comorbid",500), model=rep("null",500),FracDeaths=df.null$age3_no_comorbid.D))
df <- rbind(df, cbind( class=rep("age3_comorbid",500), model=rep("null",500),FracDeaths=df.null$age3_comorbid.D))

df <- rbind(df, cbind( class=rep("age1",500), model=rep("shield",500),FracDeaths=df.shield$age1_orange.D))
df <- rbind(df, cbind( class=rep("age2_no_comorbid",500), model=rep("shield",500),FracDeaths=df.shield$age2_no_comorbid_orange.D))
df <- rbind(df, cbind( class=rep("age2_comorbid",500), model=rep("shield",500),FracDeaths=df.shield$age2_comorbid_orange.D))
df <- rbind(df, cbind( class=rep("age3_no_comorbid",500), model=rep("shield",500),FracDeaths=df.shield$age3_no_comorbid_green.D))
df <- rbind(df, cbind( class=rep("age3_comorbid",500), model=rep("shield",500),FracDeaths=df.shield$age3_comorbid_green.D))
