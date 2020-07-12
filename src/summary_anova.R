# ****************************************
# summary_anova.R
# ****************************************
# ****************************************
# author = Eduard Campill-Funollet
# email = e.campillo-funollet@sussex.ac.uk
# date = 10th July 2020
# description = ANOVA for experiment results
# usage = Run from req-550-Syria/data/real_models/results_post_processing. Produces a table (ofile) in the same folder with a summary of the anovas.

library(gtools) #Star significance

#Output filename
ofile <- "anova_summary.csv"

#List of variables (folders)
folders <- c("Final_fraction_dead","Final_fraction_recovered","Time_to_peak_infections_age3_comorbid","Time_to_steady_state")


#Output dataframe (empty dataframe with col names)
odf <- data.frame(variable=NA,experiment=NA,pvalue=NA,significance=NA)[-1,]


for (folder in folders){
    setwd(paste("./",folder,sep=""))

    #Get filenames in folder
    file_vec <- list.files(pattern="*.csv") 
    for (fn in file_vec){
        #Load data
        df <- read.csv(fn)

        colnames(df) <- c("id","model","variable")

        #Do ANOVA
        res.aov <- aov(variable ~ model, data=df)

        #Extract p-value
        p = unlist(summary(res.aov))["Pr(>F)1"] 

        #Star significance
        s = stars.pval(p)[1]

        #Add row to output dataframe.
        odf[nrow(odf)+1,] <- c(folder,sub(".csv","",fn),p,s)
    } 
    setwd("../")
}

write.csv(odf,ofile)
