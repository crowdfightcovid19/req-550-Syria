###############################################
# read_classStructuredData_function.R
###############################################
#
# author = Alberto Pascual-García
# email = alberto.pascual.garcia@gmail.com 
# date = 22th june 2020
# description = This function reads files from class structured data. It expects as inputs the directory where the
#             files should be found.
# Read input data ---------


read_classStructuredData_function=function(dirDataIn){
  # --- Parameters read from file, should be the same for allmodels
  file.class="classes_structure" # Fraction of the population that each class represents
  file.fracItoH="fracItoH_structure"  # fraction of symptomatic that would be hospitalized
  file.fracItoD="fracItoD_structure" # fraction that will directly die
  file.contmat="contacts_structure" # contact matrix
  setwd(dirDataIn)
  sep="\t" # separator of input files
  class.str=read.table(file=file.class,sep=sep,header = TRUE)
  #fracPtoI=as.vector(read.table(file=file.fracPtoI,sep="\t",header = TRUE)) 
  fracItoH.str=as.vector(read.table(file=file.fracItoH,sep=sep,header = TRUE))
  fracItoD.str=as.vector(read.table(file=file.fracItoD,sep=sep,header = TRUE))
  class.names=colnames(class.str) # Store the name of the classes  
  C=as.matrix(read.table(file=file.contmat,sep=sep))
  return(list(class.str=class.str,fracItoH.str=fracItoH.str,
              fracItoD.str=fracItoD.str,class.names=class.names,C=C))
}
