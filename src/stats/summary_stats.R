# ****************************************
# summary_stats.R
# ****************************************
# ****************************************
# author = Eduard Campill-Funollet
# email = e.campillo-funollet@sussex.ac.uk
# date = 10th July 2020
# description = Stats summaries for experiment results
# usage = Run from req-550-Syria/data/real_models/results_post_processing. Produces a table (ofile) in the same folder with a summary of the anovas.

library(gtools) #Star significance

#Output filename
ofile <- "stats_summary.csv"

#List of variables (folders)
folders <- c("Final_fraction_dead","Final_fraction_recovered","Time_to_peak_infections_age3_comorbid","Time_to_steady_state")


#Output dataframe (empty dataframe with col names)
odf <- data.frame(variable=NA,experiment=NA,pvalue=NA,significance=NA,barlettp=NA,bartlett=NA,Welchp=NA,WelchSig=NA,shapirop=NA,shapiro=NA,kruskalp=NA,kruskalSig=NA)[-1,]

#Returns 1 or 0 indicating Homogeneity of Var (1) or not (0), according to Levene's
getBartlett <- function(p){
    if(p < 0.05)
        return( 0 );
    return( 1 );
}


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
        p <- unlist(summary(res.aov))["Pr(>F)1"] 

        #Star significance
        s <- stars.pval(p)[1]

        #Do Bartlett (Homogeneity of variances)
        res.bar <- bartlett.test(variable ~ model, data = df)

        pbar <- unlist(res.bar)[["p.value"]]
        bar <- getBartlett(as.numeric(pbar))


        #Welch test (when no equal variances)
        res.owt <- oneway.test(variable~model, data=df)
        pwel <- unlist(res.owt)[["p.value"]]
        swel <- stars.pval(as.numeric(pwel))[1]

        #Normality of residuals
        aov_residuals <- residuals(object = res.aov)
        res.sha <- shapiro.test(x = aov_residuals)
        psha <- unlist(res.sha)[["p.value"]]
        sha <- getBartlett(as.numeric(psha))

        #Kruskal (if normality fails)
        res.kru <- kruskal.test(variable~model,data=df)
        pkru <- unlist(res.kru)[["p.value"]]
        skru <- stars.pval(as.numeric(pkru))[1]

        #Add row to output dataframe.
        odf[nrow(odf)+1,] <- c(folder,sub(".csv","",fn),p,s,pbar,bar,pwel,swel,psha,sha,pkru,skru)
    } 
    setwd("../")
}

write.csv(odf,ofile)
