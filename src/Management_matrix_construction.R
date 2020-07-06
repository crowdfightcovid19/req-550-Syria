# ****************************************
# Management_matrix_construction.R
# ****************************************
# author = first version Jordan Klein, current  version Alberto Pascual-García
# email = jdklein@princeton.edu (alberto.pascual.garcia@gmail.com)
# date = 24th June 2020 (29th June 2020)
# description = Management/contact matrices for model with shielding strategy- 
#        1. Management matrix (m_ij)- the proportional change in population class `i`'s exposure to population class `j` from the intervention
#        2. Epsilon matrix (epsilon_ij)- factor regulating the average number of contacts of an individual of class `i` with an individual of class `j`
#        3. Contact matrix-intervention (C_ij_interv)- average number of contacts of an individual of class `i` with an individual of class `j` resulting from the intervention parametrized by the management matrix
#        Input files = "classes_structure" (N_j/N) and "classes_contacts" (cbar_i) 
#        Output files = "management_matrix.csv" (m_ij), "epsilon_matrix.csv" (epsilon_ij), "contacts_structure.csv" (C_ij_interv, this will be the input for the simulations)
# usage = Input files should be located within a folder in "data/real_models/". The name of the folder should be loaded in the var descr

library(tidyverse)
library(gplots)
#rm(list=ls())

### START EDITING
descr="shield_fam_vis28" # A string describing the model, input data should be created in a directory with this name in /data/real_models

fileContacts="classes_contacts_shield" # File with the number of contacts of the model per class
filePopStr="classes_structure_shield" # File with the fraction of population each class represents
  
# --- Set up parameters
# ..... Relative risk of infection from contact in neutral zone compared to contacts in orange/green zones
# (Assumed .2, lack of consensus in literature of precise effect of masks/distance on transmission)
RR <- .2

# ..... Family members people in green zone can visit per week
fam_vis <- 28
### STOP EDITING

# Read data --------
this.dir=strsplit(rstudioapi::getActiveDocumentContext()$path, "/src/")[[1]][1] # don't edit, just comment it if problems...
#this.dir="/pathToRepo" # ...path to the root path of your repo if the above command does not work, comment otherwise
dirDataIn=paste(this.dir,"/data/estimation_parameters/class_structured_data",sep="") # Directory for the input data
dirDataOut=paste(this.dir,"/data/estimation_parameters/contact_matrices",sep="") #
setwd(dirDataIn)

cbar_i <- read.table(fileContacts, sep = "\t")
frac_i <- read.table(filePopStr, sep = "\t")

Nclass=dim(cbar_i)[2]

idx.orange=which(grepl("orange",names(cbar_i))==TRUE)
idx.green=which(grepl("green",names(cbar_i))==TRUE)


# Proportion of population in orange & green zones
frac_o <- frac_i[,idx.orange] %>% sum()
frac_g <- frac_i[,idx.green] %>% sum()
frac_i_mat = as.numeric(as.vector(frac_i))* matrix(1,ncol=Nclass,nrow = Nclass)
frac_i_mat = t(frac_i_mat)
rownames(frac_i_mat)=names(cbar_i)
colnames(frac_i_mat)=names(cbar_i)

# total number of contacts and fraction of contacts with members of the other area per day
cbar_i_mat=as.vector(as.numeric(cbar_i)) * matrix(1,ncol=Nclass,nrow = Nclass) # matrix number of contacts between classes
#cbar_i_mat=t(cbar_i_mat)
c_fam=fam_vis/7  # contacts per day with relatives of the other zone
c_fam_norm=c_fam/cbar_i_mat
rownames(cbar_i_mat)=names(cbar_i)
colnames(cbar_i_mat)=names(cbar_i)

# estimation of rho
rho=c_fam*frac_g/frac_o
# if(rho >=1){ # this is very unlikely, it would be needed something like 28 contacts per week
#   rho=1
# }

### Estimation of epsilon
epsilon_ij <- matrix(nrow = 7, ncol = 7)
rownames(epsilon_ij) <- names(cbar_i)
colnames(epsilon_ij) <- names(cbar_i)

epsilon_ij[idx.orange,idx.green]=rho*c_fam_norm[idx.orange,idx.green]
epsilon_ij[idx.orange,idx.orange]=1-rho*c_fam_norm[idx.orange,idx.orange]
epsilon_ij[idx.green,idx.orange]=c_fam_norm[idx.green,idx.orange]
epsilon_ij[idx.green,idx.green]=1-c_fam_norm[idx.green,idx.green]


### Derivation of m_ij values
# m_ig,jo = RR *N/N_o
# m_ig,jg = N/N_g
# m_io,jg = RR *N/N_o
# m_io,jo = N/N_o
m_ij <- matrix(nrow = 7, ncol = 7)
rownames(m_ij) <- names(cbar_i)
colnames(m_ij) <- names(cbar_i)

m_ij[idx.green,idx.orange]=RR*(1/frac_o) # last two factors are (N_g/N_o)*(N/N_o)
m_ij[idx.green,idx.green]=(1/frac_g)
m_ij[idx.orange,idx.green]=RR*(1/frac_g)
m_ij[idx.orange,idx.orange]=(1/frac_o)

### Generate intervention contact matrix (C_ij_interv)
C_ij = cbar_i_mat * frac_i_mat
C_ij_interv = epsilon_ij*m_ij*C_ij
C_ij_red=(C_ij[idx.orange,idx.green]-C_ij_interv[idx.orange,idx.green])/
  C_ij[idx.orange,idx.green] # Reduction achieved from orange to green through the intervention
rowSums(C_ij)
rowSums(C_ij_interv) # Excluding the factor RR both rowSums must be the same
#C_ij_17=C_ij_interv

### Estimate how far from critical intervention
critical=(1/RR)*sqrt(frac_o*cbar_i$age2_no_comorbid_orange)
diff_crit=c_fam/critical # % of allowed family members permitted

### Export file
#stop()
setwd(dirDataOut)
labelOut=descr
fileManagement=paste("management_matrix",labelOut,sep="_")
fileEpsilon=paste("epsilon_matrix",labelOut,sep="_")
fileContacts=paste("contacts_matrix",labelOut,sep="_")
fileContNull="contacts_matrix_null_shield"

write.table(m_ij, fileManagement, sep = "\t")
write.table(epsilon_ij, fileEpsilon, sep = "\t")
write.table(C_ij_interv, fileContacts, sep = "\t")
write.table(C_ij, fileContNull, sep = "\t")

## Plot matrices
PlotOut=paste("heatmap_ContactsMatrix_intervention_",descr,".pdf",sep="")
pdf(file = PlotOut,width = 20,height=15)
heatmap.2(as.matrix(C_ij_interv),
          Rowv=FALSE,Colv=FALSE,
          density.info = "none",
          trace = "none",
          margins = c(33,33),
          dendrogram = "none",
          cexRow = 3,
          cexCol = 3,
          key.title = "",
          key.xlab = "contacts",
          key.ylab = "",
          key.par=list(cex.axis=3,cex.lab=3,mgp=c(3,2,0)),
          keysize = 1)#,
          #col=bluered)
dev.off()
PlotOut=paste("heatmap_ContactsMatrix_",descr,".pdf",sep="")
pdf(file = PlotOut,width = 20,height=15)
heatmap.2(as.matrix(C_ij),
          Rowv=FALSE,Colv=FALSE,
          density.info = "none",
          trace = "none",
          margins = c(33,33),
          dendrogram = "none",
          cexRow = 3,
          cexCol = 3,
          key.title = "",
          key.xlab = "contacts",
          key.ylab = "",
          key.par=list(cex.axis=3,cex.lab=3,mgp=c(3,2,0)),
          keysize = 1)#,
#col=bluered)
dev.off()
