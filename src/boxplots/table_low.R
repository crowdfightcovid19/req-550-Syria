source("panel_plot_Fig3.R")
res <- data.frame(df %>% group_by(intervention,group) %>% summarise(low = sum(NumFinalCases < 20)))
table.combined <- pivot_wider(res,names_from="group",values_from="low")

res <- data.frame(df %>% group_by(intervention,group) %>% summarise(low = sum(NumFinalCases < 20),total=length(NumFinalCases)))
res$fraction_low <- res$low/res$total

#table.fraction <- pivot_wider(res,names_from="group",id_cols=c("intervention","group"),values_from="fraction_low")[,c("intervention","T","E","S")]
#table.low <- pivot_wider(res,names_from="group",id_cols=c("intervention","group"),values_from="low")[,c("intervention","T","E","S")]
#table.total <- pivot_wider(res,names_from="group",id_cols=c("intervention","group"),values_from="total")[,c("intervention","T","E","S")]

table.low <- pivot_wider(res,names_from="group",id_cols=c("intervention","group"),values_from="low")[,c("intervention","S")]
table.total <- pivot_wider(res,names_from="group",id_cols=c("intervention","group"),values_from="total")[,c("intervention","S")]
#table.res <- bind_cols(table.low,table.total$S)

table.res <- bind_cols(table.low,table.total)                                                                                                                                            
table.res <- table.res[,!names(table.res) %in% c("intervention1")]     
table.res <- table.res[!is.na(table.res$S1),] #total not NA
table.res$percent <- signif(100.*table.res$S / table.res$S1,digits=2)
colnames(table.res)<-c("Intervention","<20 cases","Total","% of total")

setwd("/media/scratch/ecam/workbench/req-550-Syria/data/real_models/results_post_processing/")
write.csv(table.low,file="table_low.csv")
#write.csv(table.fraction,file="table_fraction.csv")
write.csv(table.total,file="table_total.csv")
write.csv(res,file="table_long_format.csv")
write.csv(table.combined,file="table_combined.csv")
write.csv(table.res,file="table_combined_low_total_S.csv")
cat("Edit the table to be Latex compatible")


