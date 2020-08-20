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

currentDir <- getwd()

source("plot_routines.R")

setwd("/home/ec365/workbench/req-550-Syria")

axis.text.size = 24
axis.title.size = 27
legend.title.size = 27
legend.text.size = 24
axis.text.x.size = 24

title.size = 35

varPoutbreak <- "POutbreak"
varFracDeath <- "FracFinalDeaths"
varPeak <- "TimePeakSymptomatic"

ytitPoutbreak <- "Probability of Outbreak"
ytitFracDeath <- "Fraction of Population Dying"
ytitPeak <- "Time to Peak Symptomatic (days)"

#Directories
baseDir <- getwd()
codeDir <- paste(baseDir,"/src",sep="")
dataDir <- paste(baseDir,"/data/real_models",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")
outPlotDir <- paste(baseDir,"/manuscripts/main/figures/newFig",sep="")


df.null <- read.csv("data/real_models/null_model_mixed/IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV/FracFinalDeaths_SEPAIHRD_dynamics_null_model_mixed_IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV.dat")  

df.shield <- read.csv("data/real_models/shield_cont2_age3/IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV/FracFinalDeaths_SEPAIHRD_dynamics_shield_cont2_age3_IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV.dat")   


df <- data.frame(class=NA,model=NA,deaths=NA)[-1,]

#df <- rbind(df, data.frame(cbind( class=rep("age1",500), model=rep("null",500),deaths=as.numeric(df.null$age1.D)) ))
#df <- rbind(df, data.frame(cbind( class=rep("age2_no_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age2_no_comorbid.D))))
#df <- rbind(df, data.frame(cbind( class=rep("age2_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age2_comorbid.D))))
#df <- rbind(df, data.frame(cbind( class=rep("age3_no_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age3_no_comorbid.D))))
#df <- rbind(df, data.frame(cbind( class=rep("age3_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age3_comorbid.D))))
#
df1 <- data.frame(cbind( class=rep("age1",500), model=rep("null",500),deaths=df.null$age1.D) )
df2 <- data.frame(cbind( class=rep("age2_no_comorbid",500), model=rep("null",500),deaths=df.null$age2_no_comorbid.D))
df3 <- data.frame(cbind( class=rep("age2_comorbid",500), model=rep("null",500),deaths=df.null$age2_comorbid.D))
df4 <- data.frame(cbind( class=rep("age3_no_comorbid",500), model=rep("null",500),deaths=df.null$age3_no_comorbid.D))
df5 <- data.frame(cbind( class=rep("age3_comorbid",500), model=rep("null",500),deaths=df.null$age3_comorbid.D))

df1$deaths<-as.numeric(df1$deaths)
df2$deaths<-as.numeric(df2$deaths)
df3$deaths<-as.numeric(df3$deaths)
df4$deaths<-as.numeric(df4$deaths)
df5$deaths<-as.numeric(df5$deaths)

df <- rbind(df1,df2,df3,df4,df5)

df6 <- data.frame(cbind( class=rep("age1",500), model=rep("shield",500),deaths=df.shield$age1_orange.D))
df7 <- data.frame(cbind( class=rep("age2_no_comorbid",500), model=rep("shield",500),deaths=df.shield$age2_no_comorbid_orange.D))
df8 <- data.frame(cbind( class=rep("age2_comorbid",500), model=rep("shield",500),deaths=df.shield$age2_comorbid_orange.D))
df9 <- data.frame(cbind( class=rep("age3_no_comorbid",500), model=rep("shield",500),deaths=df.shield$age3_no_comorbid_green.D))
df10 <- data.frame(cbind( class=rep("age3_comorbid",500), model=rep("shield",500),deaths=df.shield$age3_comorbid_green.D))

df6$deaths<-as.numeric(df6$deaths)
df7$deaths<-as.numeric(df7$deaths)
df8$deaths<-as.numeric(df8$deaths)
df9$deaths<-as.numeric(df9$deaths)
df10$deaths<-as.numeric(df10$deaths)

df <- rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10)
##
#df$deaths <- as.numeric(df$deaths)

#Totals in each class (SM tab 2)
age1 <- 0.407*2000
age2_noc <- 0.471*2000
age2_c <- 0.0626*2000
age3_noc <- 0.022*2000
age3_c <- 0.0373*2000

df$FracDeaths <- df$deaths

#df$FracDeaths[ df$class == "age1" ] <- 100*df$deaths[ df$class == "age1" ] / age1
#df$FracDeaths[ df$class == "age2_no_comorbid" ] <- 100*df$deaths[ df$class == "age2_no_comorbid" ] / age2_noc
#df$FracDeaths[ df$class == "age2_comorbid" ] <- 100*df$deaths[ df$class == "age2_comorbid" ] / age2_c
#df$FracDeaths[ df$class == "age3_no_comorbid" ] <- 100*df$deaths[ df$class == "age3_no_comorbid" ] / age3_noc
#df$FracDeaths[ df$class == "age3_comorbid" ] <- 100*df$deaths[ df$class == "age3_comorbid" ] / age3_c
#
df <- df[ df$FracDeaths > 1, ] #Cutoff simulations with very low deaths.

gg <- do_box_plot_mean_dot( df, "FracDeaths", "class", "Population class", "Deaths (% of the class)", c("Kids","Adults (not comorbid)", "Adults (comorbid)", "Elderly (not comorbid)", "Elderly (comorbid)"), c("Mixed","Safety zone"), "Model", line=TRUE, nolegend=FALSE, groupvar="model")
#gg <- do_line_plot( df, "FracDeaths", "class", "Population class", "Deaths (% of the class)", "mean",c("Kids","Adults (not comorbid)", "Adults (comorbid)", "Elderly (not comorbid)", "Elderly (comorbid)"), c("Mixed","Safety zone"), "Model", nolegend=FALSE, groupvar="model")
gg<-gg+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))

setwd(outPlotDir)
pdf(file="Fig_agegroups.pdf",width=20,height=15)
print(gg)
dev.off( )

setwd("/home/ec365/workbench/req-550-Syria")
df.null <- read.csv("data/real_models/null_model_mixed/IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV/NumFinalDeaths_SEPAIHRD_dynamics_null_model_mixed_IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV.dat")  

df.shield <- read.csv("data/real_models/shield_cont2_age3/IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV/NumFinalDeaths_SEPAIHRD_dynamics_shield_cont2_age3_IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV.dat")   


df <- data.frame(class=NA,model=NA,deaths=NA)[-1,]

#df <- rbind(df, data.frame(cbind( class=rep("age1",500), model=rep("null",500),deaths=as.numeric(df.null$age1.D)) ))
#df <- rbind(df, data.frame(cbind( class=rep("age2_no_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age2_no_comorbid.D))))
#df <- rbind(df, data.frame(cbind( class=rep("age2_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age2_comorbid.D))))
#df <- rbind(df, data.frame(cbind( class=rep("age3_no_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age3_no_comorbid.D))))
#df <- rbind(df, data.frame(cbind( class=rep("age3_comorbid",500), model=rep("null",500),deaths=as.numeric(df.null$age3_comorbid.D))))
#
df1 <- data.frame(cbind( class=rep("age1",500), model=rep("null",500),deaths=df.null$age1.D) )
df2 <- data.frame(cbind( class=rep("age2_no_comorbid",500), model=rep("null",500),deaths=df.null$age2_no_comorbid.D))
df3 <- data.frame(cbind( class=rep("age2_comorbid",500), model=rep("null",500),deaths=df.null$age2_comorbid.D))
df4 <- data.frame(cbind( class=rep("age3_no_comorbid",500), model=rep("null",500),deaths=df.null$age3_no_comorbid.D))
df5 <- data.frame(cbind( class=rep("age3_comorbid",500), model=rep("null",500),deaths=df.null$age3_comorbid.D))

df1$deaths<-as.numeric(df1$deaths)
df2$deaths<-as.numeric(df2$deaths)
df3$deaths<-as.numeric(df3$deaths)
df4$deaths<-as.numeric(df4$deaths)
df5$deaths<-as.numeric(df5$deaths)

df <- rbind(df1,df2,df3,df4,df5)

df6 <- data.frame(cbind( class=rep("age1",500), model=rep("shield",500),deaths=df.shield$age1_orange.D))
df7 <- data.frame(cbind( class=rep("age2_no_comorbid",500), model=rep("shield",500),deaths=df.shield$age2_no_comorbid_orange.D))
df8 <- data.frame(cbind( class=rep("age2_comorbid",500), model=rep("shield",500),deaths=df.shield$age2_comorbid_orange.D))
df9 <- data.frame(cbind( class=rep("age3_no_comorbid",500), model=rep("shield",500),deaths=df.shield$age3_no_comorbid_green.D))
df10 <- data.frame(cbind( class=rep("age3_comorbid",500), model=rep("shield",500),deaths=df.shield$age3_comorbid_green.D))

df6$deaths<-as.numeric(df6$deaths)
df7$deaths<-as.numeric(df7$deaths)
df8$deaths<-as.numeric(df8$deaths)
df9$deaths<-as.numeric(df9$deaths)
df10$deaths<-as.numeric(df10$deaths)

df <- rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10)
#

setwd(currentDir) #Let's finish where we started.
