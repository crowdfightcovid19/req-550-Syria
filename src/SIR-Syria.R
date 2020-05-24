# ****************************************
# SimpleSIR.R
# ****************************************
# author = Eduard Campillo-Funollet
# email = funollet@sussex.ac.uk
# date = 21st May 2020
# description = 
# usage = 

library(deSolve)   # package to solve the model
library(reshape2)  # package to change the shape of the model output
library(ggplot2)

# Set initial conditions S, I, R ("y")
START.S <- 2000    # one possible size of an informal camp
START.I <- 1
START.R <- 0

START.N <- START.S + START.I + START.R
START.N

# Set parameter values of gamma ("parms")
gamma <- 0.1            # average infectious period ranging from 8 to 10 days
beta <- 0.5             # R0 of 5 (on the higher end based on the Rohingya paper)
mu <- 5.4/1000/365      # crude birth rate in Syria
birth <- 23.7/1000/365  # crude death rate in Syria
 

# This function models a time step for the SIR:
dx.dt.SIR <- function(t, y, parms) {
  
  # Calculating the total population size N (the sum of the number of people in each compartment)
  N <- y["S"] + y["I"] + y["R"]
  
  # Defining lambda as a function of beta and I:
  lambda <- parms["beta"] * y["I"] / N
  
  # Calculate the change in Susceptibles
  dS <- - lambda * y["S"] + parms["birth"] * N - parms["mu"] * y["S"]
  
  # Calculate the change in Infecteds
  dI <- lambda * y["S"] - parms["gamma"] * y["I"] - parms["mu"] * y["I"]
  
  # Calculate the change in Recovereds
  dR <- parms["gamma"] * y["I"] - parms["mu"] * y["R"]
  
  # Return a list with the changes in S, I, R at the current time step
  return(list(c(dS, dI, dR)))
}

# Create the parameter vector
parms_vector <- c(gamma=gamma, beta=beta, mu=mu, birth=birth)

# Sequence of times at which we estimate 
# (here, we do daily for 365 days - you can change this value)
times_vector <- seq(from=0, to=365, by=1)

# Run the ODE solver
SIR.output <- as.data.frame(lsoda(y=c(S=START.S, I=START.I, R=START.R), 
                                  times=times_vector, 
                                  func=dx.dt.SIR, 
                                  parms=parms_vector))

# Print the output: this is a matrix of S, I and R values at each time point						
SIR.output

# plot(SIR.output$time,SIR.output$I)

#check the output, and plot
output_long <- melt(as.data.frame(SIR.output), id = "time")

ggplot(data = output_long,
       aes(x = time,
           y = value,
           colour = variable,
           group = variable)) +  # assign columns to axes and groups
  geom_line() +                  # represent data as lines
  xlab("Time (days)")+           # add label for x axis
  ylab("Number of people") +     # add label for y axis
  labs(title = paste("Number infected and recovered over time when gamma =",
                     parms_vector,"days^-1")) # add title


# #Plotting the proportion of people in each compartment over time
# 
# output_long$proportion <- output_long$value/START.N
# 
# ggplot(data = output_long,
#        aes(x = time,
#            y = proportion,
#            colour = variable,
#            group = variable)) +  # assign columns to axes and groups
#   geom_line() +                  # represent data as lines
#   xlab("Time (days)")+           # add label for x axis
#   ylab("Number of people") +     # add label for y axis
#   labs(title = paste("Proportion of susceptible, infected and recovered over time")) # add title
