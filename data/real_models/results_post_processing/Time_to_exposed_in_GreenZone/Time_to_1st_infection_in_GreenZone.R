# Make a table with the name of the experiment and the time to first exposition among adults with comorbidities 
# (I observed manually that they were always the first ones in the green zone to be exposed)

files <- list.files(path="C:/A", pattern="*.dat", full.names=TRUE, recursive=FALSE)

output <- data.frame(matrix(ncol=2,nrow=length(files), dimnames=list(NULL, c("name", "time_to_1st_exposed_in_GreenZone"))))

for (i in 1:length(files)) {
  t <- read.csv(files[i], header=TRUE, sep="") # load file
  output$name[i] <- files[i]                   # print name of the file in the first column of the dataframe
  for (k in 1:nrow(t)) {                       # loop through the rows of the file to find when adult_comorbid_green_E >= 1
    if (t[k,13] >= 1) {
      output$time_to_1st_exposed_in_GreenZone[i] <- t[k,1]  # print time (in days) in the second column of the dataframe
      break
    }
  }
}

write.csv(output,"Time_to_1st_exposed_GreenZone.csv", row.names = FALSE)
