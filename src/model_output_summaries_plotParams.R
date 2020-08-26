# ****************************************
# model_output_summaries_plotParam.R
# ****************************************
# 
# 
# author = Alberto Pascual-García 
# email = alberto.pascual.garcia@gmail.com 
# date = 30th July 2020
# description = This is supporting code for model_output_summaries.R plots.  
# usage = In this script you can define the plots you want to create for a combination
#  of interventions. You should define a list with two elements:
#  1. A dataframe which contains the following fields:
#   fileIn="name_of_file", # the input file with one line for each intervention, see e.g. input_parameters_multiple_output_summaries_A.csv for format 
#   title.lab="a title for the plot",
#   subtitle.lab="a subtitle",
#   xlabel.lab="The label of the x axis",
#   plot.type="single", # either single, if only the null model is plotted, or double if both exposed and shielded pop. variables should be plotted
#   pdf.width=pdf.width.default # some plot defaults, you could add more, but should be coded at
#   pdf.height=pdf.height.default
# 2. A character vector with one descriptor of each intervention in each cell (in the same order as they come in the input file)
#   scale.manual.lab=c("intervention1","intervention2")
#

experiments.list=list()

# --- Define some defaults for most of the plots
pdf.width.default=9
pdf.height.default=7
Npop=2000
i=0

# --- Create one list for each experiment, and add it to the list of lists "experiments.list"

# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_A2.csv",
#                                       title.lab="",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="Fate",
#                                       xlabel.lab="Fate of individuals in H compartment",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("All recover","All die"))
# 
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_A.csv",
#                                       title.lab="Safety zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="contacts",
#                                       xlabel.lab="Number of contacts per week/individual",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("No isol.","10","2"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_A.csv",
#                                       title.lab="Safety zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="contacts",
#                                       xlabel.lab="Number of contacts per week/individual",
#                                       plot.type="double",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("No isol.","10","2"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_B.csv",
#                                       title.lab="Self-isolation",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="Limit",
#                                       xlabel.lab="Number of self-isolation tents",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("0","10","25","50","100","250","500","2000"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_C.csv",
#                                       title.lab="Self-isolation",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="Onset",
#                                       xlabel.lab="Time to self-isolation (h)",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("No isol.","12","24","48"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_D.csv",
#                                       title.lab="Population in safety zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="popShielded",
#                                       xlabel.lab="Population classes in safety zone",
#                                       plot.type="double",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("Elderly","Elder. + adult w.comorb.",
#                                               "Elder. + adults + kids (<20%)",
#                                               "Elder. + adults + kids (<25%)",
#                                               "Elder. + adults + kids (<30%)"))
# i=i+1
# 
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_D.csv",
#                                       title.lab="Population in safety zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="popShielded",
#                                       xlabel.lab="Population classes in safety zone",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("Elderly","Elder. + adult w.comorb.",
#                                               "Elder. + adults + kids (<20%)",
#                                               "Elder. + adults + kids (<25%)",
#                                               "Elder. + adults + kids (<30%)"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_E.csv",
#                                       title.lab="Population size",
#                                       subtitle.lab="2 contacts/week and individual in buffering zone",
#                                       varX="popSize",
#                                       xlabel.lab="Model/Number of individuals in the camp",
#                                       plot.type="double",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("null/500","null/1000","null/2000",
#                                               "safety 2/500","safety 2/1000","safety 2/2000"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_E.csv",
#                                       title.lab="Population size",
#                                       subtitle.lab="2 contacts/week and individual in buffering zone",
#                                       varX="popSize",
#                                       xlabel.lab="Model/Number of individuals in the camp",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("null/500","null/1000","null/2000",
#                                               "safety 2/500","safety 2/1000","safety 2/2000"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_F.csv",
#                                       title.lab="Health checks in buffer zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="Tcheck",
#                                       xlabel.lab="Contacts per week and individual/Health checks",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("10 cont. (no checks)","10 cont.+ checks",
#                                               "2 cont. (no checks)","2 cont.+ checks"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_F.csv",
#                                       title.lab="Health checks in buffer zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="Tcheck",
#                                       xlabel.lab="Contacts per week and individual/Health checks",
#                                       plot.type="double",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("10 cont. (no checks)","10 cont.+ checks",
#                                               "2 cont. (no checks)","2 cont.+ checks"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_G.csv",
#                                       title.lab="Lockdown of safety zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="lock",
#                                       xlabel.lab="Reduction number of contacts buffering zone (%)",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("0","50","90"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_G.csv",
#                                       title.lab="Lockdown of safety zone",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="lock",
#                                       xlabel.lab="Reduction number of contacts buffering zone (%)",
#                                       plot.type="double",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("0","50","90"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_H.csv",
#                                       title.lab="Self-distancing",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="self",
#                                       xlabel.lab="Individual reduction contacts per day (%)",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("0","20","50"))
# i=i+1
# experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_J.csv",
#                                       title.lab="Evacuation",
#                                       subtitle.lab=paste("Population size = ",Npop),
#                                       varX="Isolate",
#                                       xlabel.lab="Model/Evacuation",
#                                       plot.type="single",
#                                       pdf.width=pdf.width.default,
#                                       pdf.height=pdf.height.default),
#                            scale.manual.lab=c("null/NO","null/YES",
#                                               "safety 2/NO","safety 2/YES"))
 # i=i+1
 # experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_J.csv",
 #                                       title.lab="Evacuation",
 #                                       subtitle.lab=paste("Population size = ",Npop),
 #                                       varX="Isolate",
 #                                       xlabel.lab="Model/Evacuation",
 #                                       plot.type="double",
 #                                       pdf.width=pdf.width.default,
 #                                       pdf.height=pdf.height.default),
 #                            scale.manual.lab=c("null/NO","null/YES",
 #                                               "safety 2/NO","safety 2/YES"))
 i=i+1
 experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_K.csv",
                                       title.lab="Combined",
                                       subtitle.lab=paste("Population size = ",Npop),
                                       varX="Combined",
                                       xlabel.lab="Intervention",
                                       plot.type="double",
                                       pdf.width=12,
                                       pdf.height=9),
                            scale.manual.lab=c("none",
                                               "evac",
                                               "self 20%",
                                               "50 tents",
                                               "self 50%",
                                               "self 20% + 50 tents",
                                               "self 20% + 50 tents + evac",
                                               "self 50% + 50 tents ",
                                               "self 50% + 50 tents + evac",
                                               "safety",
                                               "safety + evac",
                                               "safety + lock 50%",
                                               "safety + self 20%",
                                               "safety + 50 tents",
                                               "safety + self 50%",
                                               "safety + 50 tents + lock 50%",
                                               "safety + 50 tents + evac",
                                               "safety + 50 tents + self 20%",
                                               "safety + 50 tents + self 50%",
                                               "safety + 50 tents + evac + lock 50% + self 20%",
                                               "safety + 50 tents + evac + lock 50% + self 50%",
                                               "safety + 50 tents + evac + lock 90% + self 50%"))
 i=i+1
 experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_K.csv",
                                       title.lab="Combined",
                                       subtitle.lab=paste("Population size = ",Npop),
                                       varX="Combined",
                                       xlabel.lab="Intervention",
                                       plot.type="single",
                                       pdf.width=12,
                                       pdf.height=9),
                            scale.manual.lab=c("none",
                                              "evac",
                                              "self 20%",
                                              "50 tents",
                                              "self 50%",
                                              "self 20% + 50 tents",
                                              "self 20% + 50 tents + evac",
                                              "self 50% + 50 tents ",
                                              "self 50% + 50 tents + evac",
                                              "safety",
                                              "safety + evac",
                                              "safety + lock 50%",
                                              "safety + self 20%",
                                              "safety + 50 tents",
                                              "safety + self 50%",
                                              "safety + 50 tents + lock 50%",
                                              "safety + 50 tents + evac",
                                              "safety + 50 tents + self 20%",
                                              "safety + 50 tents + self 50%",
                                              "safety + 50 tents + evac + lock 50% + self 20%",
                                              "safety + 50 tents + evac + lock 50% + self 50%",
                                              "safety + 50 tents + evac + lock 90% + self 50%"))
 # i=i+1 
## To generate this figure in model_output_summaries_plotDouble.R change the name of the file to "unlabelled" (see plotOut)
 # experiments.list[[i]]=list(data.frame(fileIn="input_parameters_multiple_output_summaries_K.csv",
 #                                       title.lab="",
 #                                       subtitle.lab="", #paste("Population size = ",Npop),
 #                                       varX="Combined",
 #                                       xlabel.lab="Intervention",
 #                                       plot.type="double",
 #                                       pdf.width=12,
 #                                       pdf.height=7),
 #                            scale.manual.lab=c("1",
 #                                               "2",
 #                                               "3",
 #                                               "4",
 #                                               "5",
 #                                               "6",
 #                                               "7",
 #                                               "8",
 #                                               "9",
 #                                               "10",
 #                                               "11",
 #                                               "12",
 #                                               "13",
 #                                               "14",
 #                                               "15",
 #                                               "16",
 #                                               "17",
 #                                               "18",
 #                                               "19",
 #                                               "20",
 #                                               "21",
 #                                               "22"))
 # 
 # 
