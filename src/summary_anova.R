library(dplyr)

do_anova <- function(filename){
    #Experiment name - filename without extension
    name <- sub(".csv","",filename)
    output_file <- sub(".csv",".txt",filename)

    #Load data
    df <- read.csv(filename)

    #Data summary
    s <- group_by(df,Model)%>% 
          summarise( 
            count = n(), 
            mean = mean(Fraction_Dead, na.rm = TRUE), 
            sd = sd(Fraction_Dead, na.rm = TRUE) 
            )

    #ANOVA
    res.aov <- aov(Fraction_Dead ~ Model, data=df)
    
    #ANOVA summary
    sa <- summary(res.aov)
    
    sink(output_file)
    #print(name)
    #print(s)
    #print(sa)
    #print("*****************")
    print(paste(c("Fraction_Dead",name,sa[[1]][["Pr(>F)"]]),sep=","))
    sink()
}


#Get filenames in folder
file_vec <- list.files(pattern="*.csv") 

for (fn in file_vec){
    do_anova(fn)
} 

