#***************************************
#generate_table_results.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 30th July 2020
#description = Generates a table of relevant simulations results in a format suitable for producing plots afterwards. Main structure based on Alberto Pascual-Garcia mean-stderr script.
#usage = Run from src/

setwd("/home/ec365/workbench/req-550-Syria/src")

library(dplyr)
library(stringi)
library(stringr)

assemble_df <- function( deaths, reco, time, group, oParam){
    l = length(deaths)
    df <- data.frame( rep(oParam[1],l),
                      rep(oParam[2],l),
                      rep(oParam[3],l),
                      rep(oParam[4],l),
                      rep(oParam[5],l),
                      rep(oParam[6],l),
                      rep(oParam[7],l),
                      rep(oParam[8],l),
                      rep(oParam[9],l),
                      rep(oParam[10],l),
                      rep(group,l),
                      deaths,
                      reco,
                      time )

    return(df)
}

keywordS="green" # a keyword to identify (S)hielded pop
keywordE="orange" # non-shielded pop (E)xposed 

# Files to process (header). Also variable col names.
files.list=c("NumFinalDeaths","NumFinalRecovered","TimePeakSymptomatic")

idDir="modSV" # this is a string contained in all the directories that should be processed
fileOut=paste("results_table_",idDir,".csv",sep="")


#Group -> T,E,S (total, Exposed, Shielded)
header.names=c("contacts","Isolate","Limit","Onset","Fate","Tcheck","PopSize","lock","self","mod","group",files.list)

#Empty dataframe
df.output <- data.frame(matrix(NA,nrow=1,ncol=length(header.names)))[-1,]
colnames(df.output) <- header.names

# Function to get output directories (by Alberto).
get_output_directories <- function(directory) {
  list.dirs(directory) %>% 
    .[grepl(idDir, .) & !grepl("figures", .)]
}

#Directories
setwd("..")
baseDir <- getwd()
codeDir <- paste(baseDir,"/src",sep="")
dataDir <- paste(baseDir,"/data/real_models",sep="")
outDir <- paste(baseDir,"/data/real_models/results_post_processing",sep="")

setwd(dataDir)
subLabel="_SEPAIHRD_dynamics"
dir.list=get_output_directories(".")

for(dirIn in dir.list){
    contents=list.files(path = dirIn)
    if(length(contents) < 30){
        warning(paste("Directory contains less than 30 items: ",dirIn)) 
    }

    #Extract popsize from dir name
    str.PopSize=stri_split_fixed(dirIn,"PopSize")[[1]][2] #Needed here?
    setwd(dirIn)
    cat("> Processing folder ",dirIn,"\n")
    #Labels (by Alberto)
    fileLabel=gsub("/","_",dirIn) # Retrieve the label that all files have, related to the directory
    fileLabel=gsub("^\\.","",fileLabel) # but some processing needed 

# ... Identify if the intervention involves setting up isolation tents (isoThr>0)
    files.list.local=files.list # From now we will use different names depending on the scenario
    isoThr.key=grep("Limit0",fileLabel) # If this search is non-empty 
    if(is_empty(isoThr.key)){ # It means the intervention is active
        file.class=apply(as.matrix(unlist(files.list)),MARGIN = 1,   # Symptomatic files change their name
                 FUN=function(x){!is_empty(grep("Symptomatic",x))}) # identify these files
        file.idx=which(file.class==TRUE) # only for the positions with these files
        files.list.local[file.idx]=lapply(files.list.local[file.idx], # apply the change in the names
                        FUN=function(x){str_replace(x,"Symptomatic","Symp_Iso-stage")})
    }

    # ... Extract all the parameters from directory description
    shieldLab=stri_split_fixed(fileLabel,"Isolate")[[1]][1] # retrieve the label identifying the contacts matrix
    shieldLab=gsub("^_","",shieldLab) # remove starting and final "_"
    shieldLab=gsub("_$","",shieldLab)
    otherLab=stri_split_fixed(fileLabel,shieldLab)[[1]][2]
    otherLab=gsub("^_","",otherLab)
    otherLabList=unlist(stri_split_fixed(otherLab,"_"))
    outputParam=c(shieldLab,otherLabList)

    for(file2proc in files.list.local){
        cat("> Processing file: ", file2proc,"\n")
        fileIn <- paste(file2proc, subLabel, fileLabel, ".dat", sep = "") 
        df.all <- read.csv(file = fileIn)
        df.all <- subset(df.all, select = -c(X))
        Nrealiz.all=dim(df.all)[1] # store the original number of realizations
        idx.classS = grep(keywordS, colnames(df.all)) # cols for shielded population
        idx.classE = grep(keywordE, colnames(df.all)) # remaining pop

        #We process final deaths first, use it to filter.
        if (file2proc == "NumFinalDeaths"){
            death.totals = rowSums(df.all) # because we will identify simulations with no deaths
            nodeath.obs = which(death.totals > 0) # and create an index to work only with them
            death.totals.E=rowSums(df.all[,idx.classE])
            nodeath.obs.E = which(death.totals.E > 0)
            death.totals.S=rowSums(df.all[,idx.classS])
            nodeath.obs.S = which(death.totals.S > 0)
        }

        df = df.all[nodeath.obs, ] # gather statistics only for cases where deaths are observed
        Nrealiz=dim(df)[1] # Number realizations for all set
        df.E = df.all[nodeath.obs.E, idx.classE] # only exposed
        df.S = df.all[nodeath.obs.S, idx.classS] # only susceptible
        Nrealiz.E = dim(df.E)[1] # this will reduce the number of realizations to those with no deaths
        Nrealiz.S = dim(df.S)[1] # this will reduce the number of realizations to those with no deaths

        #Gather appropiate stats
        if (file2proc == "NumFinalDeaths"){
            df.deaths = rowSums(df)
            df.deaths.E = rowSums(df.E)
            df.deaths.S = rowSums(df.S)
        }
        else if (file2proc == "NumFinalRecovered"){
            df.reco= rowSums(df)
            df.reco.E = rowSums(df.E)
            df.reco.S = rowSums(df.S)
        }
        else{ #For time peak, we take the MEAN of the total/exposed/shielded
            df.time= rowMeans(df)
            df.time.E = rowMeans(df.E)
            df.time.S = rowMeans(df.S)
        } 
    }

    #Create temporal frame
    df.tmp <- assemble_df(df.deaths,df.reco,df.time,"T",outputParam)

    #Add it to the output
    df.output <- rbind(df.output,df.tmp)

    if(length(df.deaths.E) > 0){
        df.tmp <- assemble_df(df.deaths.E,df.reco.E,df.time.E,"E",outputParam)
        df.output <- rbind(df.output,df.tmp)
    }     

    if(length(df.deaths.S) > 0){
        df.tmp <- assemble_df(df.deaths.S,df.reco.S,df.time.S,"S",outputParam)
        df.output <- rbind(df.output,df.tmp)
    }     

    setwd(dataDir)
}

#fix col names
colnames(df.output) <- header.names

#Move to output dir
setwd(outDir)
#Save the table
write.csv(df.output,file=fileOut)

setwd(codeDir) #Let's finish where we started.
