#***************************************
#sample_size.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 15th February 2021
#description = Plots length of confidence interval vs sample size for Bernoulli trials using. 
#usage = Run to see the plot.

library(binom) #To compute conf. internvals
library(ggplot2) #Plots

P <- c(0.7,0.75,0.80,0.85) #Underlying probabilities
N <- c(1:40)*500 #Samples sizes to explore
df <- data.frame(method=NA,n=NA,p=NA,length=NA)[-1,] #Empty dataframe

#Fill the dataframe
for(p in P){
    df <- rbind(df,data.frame(binom.length(p,N,method="wilson")))
}

df$p <- as.factor(df$p) #To plot p as a discrete factor

gg<- ggplot(df)+geom_line(aes(x=n,y=length,color=p)) + scale_color_discrete() 

#Uncomment to save the plot.
#pdf(file="sample_size.pdf",title="Sample size") 
#dev.off()
