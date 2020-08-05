# ****************************************
# model_output_summaries_plotMaster.R
# ****************************************
# 
# 
# author = Alberto Pascual-García 
# email = alberto.pascual.garcia@gmail.com 
# date = 30th July 2020
# description = This is supporting code for model_output_summaries.R plots. It controls the calls
#   to functions plotting results from the output of that script. The plots are sets of interventions
#   whose descriptors and parameters for the plots must be defined in model_output_summaries_plotParam.R
#   and whose definition to be retrieved from the main table (Summary_interventions_$label.csv) should
#   be defined in an external csv file for each of them (see e.g. input_parameters_multiple_output_summaries_A.csv 
#   for an example of the format)
# usage = Once the experiments are defined, simply provide the name of the Summary file and source. 
#
rm(list=ls())
library(ggplot2)
# ---- Define the input file
file.all.exp="Summary_interventions_modSV.csv"

# ---- Set the directories if needed
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] 
dirCode=paste(this.dir,"/src",sep="")
dirData=paste(this.dir,"/data/real_models/",sep="")
dirDataIn=paste(dirData,"results_post_processing",sep="")
dirPlotOut=paste(dirDataIn,"/Summary_figures",sep="")

# --- Read file with the summary of results
setwd(dirDataIn)
df.all=read.csv(file=file.all.exp)

# --- Source the experiments and the possible types of plots
setwd(dirCode)
source("model_output_summaries_plotParams.R")
source("model_output_summaries_plotSingle.R")
source("model_output_summaries_plotDouble.R")
source("extract_subtable_output_summaries.R")

for(experiment in experiments.list){
  df.local=experiment[[1]]
  plot.type=df.local$plot.type
  if(plot.type == "single"){ # first type of plot
      model_output_summaries_plotSingle(df.all,experiment,dirCode,dirPlotOut)  
  }else{ # second type of plot
    model_output_summaries_plotDouble(df.all,experiment,dirCode,dirPlotOut)  
  }
  
}







setwd(dirPlotOut)
