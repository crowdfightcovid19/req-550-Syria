# ****************************************
# SimpleSIR.R
# ****************************************
# author = Jennifer Villers
# email = villers.jennifer@gmail.com
# date = 21st May 2020
# description = Basic SIR model in R
# usage = Edit the script (lines 15 to 24) to set initial contidions and parameters.

library(deSolve)   # package to solve the model
library(reshape2)  # package to change the shape of the model output
library(ggplot2)

# Set initial conditions S, I, R ("y")
START.S <- 10^6-1
START.I <- 1
START.R <- 0

START.N <- START.S + START.I + START.R
START.N

# Set parameter values of gamma ("parms")
gamma <- 0.1
beta <- 0.5/START.N

# This function models a time step for the SIR:
dx.dt.SIR <- function(t, y, parms) {
  
  # Calculate the change in Susceptibles
  dS <- - parms["beta"] * y["S"] * y["I"] 
  
  # Calculate the change in Infecteds
  dI <- parms["beta"] * y["S"] * y["I"] - parms["gamma"] * y["I"] 
  
  # Calculate the change in Recovereds
  dR <- parms["gamma"] * y["I"] 
  
  # Return a list with the changes in S, I, R at the current time step
  return(list(c(dS, dI, dR)))
  
}

# Create the parameter vector
parms_vector <- c(gamma=gamma, beta=beta)

# Sequence of times at which we estimate 
# (here, we do daily for 365 days - you can change this value)
times_vector <- seq(from=0, to=60, by=1)

# Run the ODE solver
SIR.output <- lsoda(y=c(S=START.S, I=START.I, R=START.R), 
                   times=times_vector, 
                   func=dx.dt.SIR, 
                   parms=parms_vector)

# Print the output: this is a matrix of S, I and R values at each time point						
SIR.output

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

