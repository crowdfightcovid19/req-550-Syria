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

setwd("/home/ecam/workbench/req-550-Syria")

library("tidyr")

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

df.null.long <- pivot_longer(df.null,cols=2:6,names_to="class",values_to="FracDeath")
df.shield.long <- pivot_longer(df.shield,cols=2:6,names_to="class",values_to="FracDeath")

df.null.long$model <- rep("null",dim(df.null.long)[1])
df.shield.long$model <- rep("shield",dim(df.shield.long)[1])

df <- rbind(df.null.long,df.shield.long)

old_names <- c("age1.D","age2_no_comorbid.D","age2_comorbid.D","age3_no_comorbid.D","age3_comorbid.D","age1_orange.D","age2_no_comorbid_orange.D","age2_comorbid_orange.D","age3_no_comorbid_green.D","age3_comorbid_green.D")
new_names <- c("age1","age2_no_comorbid","age2_comorbid","age3_no_comorbid","age3_comorbid","age1","age2_no_comorbid","age2_comorbid","age3_no_comorbid","age3_comorbid")

for(i in 1:length(old_names)){
    df$class[ df$class == old_names[i] ] <- new_names[i]
}

df$POutbreak <- rep(0.0,dim(df)[1])

for(cl in c("age1","age2_no_comorbid","age2_comorbid","age3_no_comorbid","age3_comorbid")){
    df.null <- subset(df, class==cl & model=="null")
    df.shield <- subset(df, class==cl & model=="shield")

    p.null <- length( df.null$FracDeath[ df.null$FracDeath != 0 ] ) / length(df.null$FracDeath)
    p.shield <- length( df.shield$FracDeath[ df.shield$FracDeath != 0 ] ) / length(df.shield$FracDeath)

    df$POutbreak[ df$class == cl & df$model == "null" ] <- p.null
    df$POutbreak[ df$class == cl & df$model == "shield" ] <- p.shield
}

df <- df[ df$FracDeath > 0, ]

df$class <- factor(df$class)
df$class<-factor(df$class,levels(df$class)[c(1,3,2,5,4)])
df$model <- factor(df$model)


gg.d <- do_box_plot_mean_dot( df, "FracDeath", "class", "Population class", "Deaths (% of the class)", c("Kids","Adults (not comorbid)", "Adults (comorbid)", "Older (not comorbid)", "Older (comorbid)"), c("Mixed","Safety zone"), "Model", line=FALSE, nolegend=TRUE, groupvar="model")
#gg.f <- do_box_plot_mean_dot( df, "FracFinalSusceptible", "class", "Population class", "Deaths (% of the class)", c("Kids","Adults (not comorbid)", "Adults (comorbid)", "Older (not comorbid)", "Older (comorbid)"), c("Mixed","Safety zone"), "Model", line=FALSE, nolegend=TRUE, groupvar="model")
gg.p <- do_line_plot( df, "POutbreak", "class", "", "Probability of outbreak", "mean",c("Kids","Adults (not comorbid)", "Adults (comorbid)", "Older (not comorbid)", "Older (comorbid)"), c("Mixed","Safety zone"), "Model", nolegend=FALSE, groupvar="model")
gg.d<-gg.d+theme(axis.text.x = element_text(size=axis.text.x.size,angle=45,hjust=1,vjust=1))
gg.p<- gg.p + theme(axis.text.x = element_blank())
#gg.f<- gg.f + theme(axis.text.x = element_blank())

setwd(outPlotDir)
pdf(file="FigS8.pdf",width=12,height=20)
grid.arrange(gg.p,gg.d,nrow=3,ncol=1,heights=c(1,1,1.3))
dev.off( )

setwd("/home/ecam/workbench/req-550-Syria")
#df.null <- read.csv("data/real_models/null_model_mixed/IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV/NumFinalDeaths_SEPAIHRD_dynamics_null_model_mixed_IsolateNO_Limit0_Onset0_FateD_TcheckNO_PopSize2000_lockNO_selfNO_modSV.dat")  

#df.shield <- read.csv("data/real_models/shield_cont2_age3/IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV/NumFinalDeaths_SEPAIHRD_dynamics_shield_cont2_age3_IsolateNO_Limit0_Onset0_FateD_TcheckYES_PopSize2000_lockNO_selfNO_modSV.dat")   




setwd(currentDir) #Let's finish where we started.
