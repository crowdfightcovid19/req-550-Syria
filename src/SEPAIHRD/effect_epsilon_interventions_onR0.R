###############################################
# effect_epsilon_interventions_onR0.R
###############################################
#
# author = Alberto Pascual-García
# email = alberto.pascual.garcia@gmail.com 
# date = 22nd june 2020
# description = This script tests how much R0 is reduced if epsilon is changed for each class
#         or all classes together by some factor.
# usage = Parameters are sourced from input_parameters_SEPAIHRD.R, and the remaining are read from
#         file. Then the user should desi
#
library(MASS)
rm(list=ls())

# --- Determine number of R0 values computed for each intervention.
Nrand=1000 # Determine number of randomizations
intervention=c(1,0.9,0.75,0.5,0.25,0.1) # reduction in epsilon
all=0 # should the intervention be applied class by class (=0) or to all classes together (=1)?

# --- Fix directories and file
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit comment if problems...
#this.dir="/pathToRepo" # ...path to the root path of your repo if the above command does not work, comment otherwise
dirDataIn=paste(this.dir,"/data/real_models/null_model/",sep="") # Directory for the input data
dirCodeBase=paste(this.dir,"/src",sep="") # Directory where the function with the basic code is found
dirParams=paste(this.dir,"/src/SEPAIHRD",sep="") # Directory where the function with the derivatives is coded
pathOut="data/effect_interventions_epsilon_R0"
dirPathOut=paste(this.dir,pathOut,sep="/")

file.contclass="classes_contacts" # bar(c)_i average number of contacts per class, all the remaining files and params are generated externally
fileParams="input_parameters_SEPAIHRD.R"
fileStrParams="read_classStructuredData_function.R"
fileR0fun="estimation_R0_function.R"

# --- Read class-dependent input data
setwd(dirCodeBase)
source(fileStrParams)
struct.param=read_classStructuredData_function(dirDataIn)
class.str=unlist(struct.param["class.str"][[1]])
fracItoH.str=unlist(struct.param["fracItoH.str"][[1]])
fracItoD.str=unlist(struct.param["fracItoD.str"][[1]])
class.names=unlist(struct.param["class.names"][[1]])
Nclass=length(class.names)
C=(unlist(struct.param["C"][[1]]))

setwd(dirDataIn)
av.cont=as.matrix(read.csv(file=file.contclass,sep="\t"))
#rownames(C)=colnames(C)

# --- Source remaining parameters
setwd(dirParams)
source(fileParams)

# --- Source estimation of R0
setwd(dirCodeBase)
source(fileR0fun)

# --- Design the interventions
epsilon=vector(mode="numeric",length=Nclass)
epsilon=epsilon+1
epsilonTmp=epsilon
mij=matrix(1,nrow=Nclass,ncol=Nclass)
Ninterv=length(intervention)
if(all==1){
  Nclass=1
  labelOut="AllClasses"
}else{
  labelOut="IndivClass"
}
R0.df=data.frame()
for(i in 1:Nclass){
  for(k in 1:Ninterv){
    epsilonTmp=epsilon
    if(all==1){
      epsilonTmp=epsilonTmp*intervention[k]
      namesOut="All classes"
    }else{
      epsilonTmp[i]=epsilonTmp[i]*intervention[k]
      namesOut=class.names[i]
    }
    parms=list(tau.vec=tau.vec,deltaP.vec=deltaP.vec,
                gammaA=gammaA,gammaI=gammaI,gammaH.vec=gammaH.vec,
                eta.vec=eta.vec,alpha.vec=alpha.vec,
                fracPtoI.vec=fracPtoI.vec,fracItoH.str=fracItoH.str,fracItoD.str=fracItoD.str,
                av.cont=av.cont,mij=mij,epsilon=epsilonTmp,Nrand=Nrand)
    R0.out=estimation_R0_function(parms)
    R0.mean=mean(R0.out)
    R0.error=sd(R0.out)/sqrt(Nrand)
    df.tmp=data.frame(R0=R0.mean,R0.err=R0.error,class=namesOut,epsilon=intervention[k])
    R0.df=rbind(R0.df,df.tmp)
  }
}
colnames(R0.df)=c("R0","R0.err","class","epsilon")
R0.df$decrease=(1-R0.df$epsilon)*100

setwd(dirPathOut)
ticks=(1-intervention)*100
plotOut=paste("Plot_effectEpsilonIntervOnR0_by",labelOut,".pdf",sep="")
pdf(file=plotOut,width=12)
gg=ggplot(R0.df,aes(x=decrease,y=R0,color=class))+
  geom_point()+geom_line()+
  geom_errorbar(aes(ymin=R0-R0.err, ymax=R0+R0.err), width=.3) +
  xlab("Reduction mean num. contacts (%)")+
  theme_bw()+
  theme(axis.title = element_text(size=26),axis.text = element_text(size=18),
        legend.text = element_text(size=18),legend.title = element_text(size=25))+
  scale_x_discrete(limits=ticks)
print(gg)
dev.off()
