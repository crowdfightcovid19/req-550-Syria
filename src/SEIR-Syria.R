# ****************************************
# author = Eduard Campillo-Funollet
# email = e.campillo-funollet@sussex.ac.uk
# date = 26th May 2020
# description = SEIR model with shielded population.
# usage = Edit the script (lines 13 to 32) to set initial contidions and parameters.
# Based on J. Villers SIR-Syria.R.

library(deSolve)   # package to solve the model
library(reshape2)  # package to change the shape of the model output
library(ggplot2)

# Set initial conditions S, I, R ("y")
START.S <- 1800    # one possible size of an informal camp
START.S_S <- 200 #Shielded popoulation (10%)
START.E <- 1 #one infectious, asymptomatic individual in gen pops
START.E_S <- 0
START.I <- 1
START.R <- 0
#START.D <- 0

START.N <- START.S + START.S_S + START.E + START.E_E + START.I + START.R #+ START.D


# Set parameter values of gamma ("parms")
gamma_E <- 0.1            # average infectious period ranging from 8 to 10 days
gamma_I <- 0.1          # average symptomatic period 
beta <- 0.5             # R0 of 5 (on the higher end based on the Rohingya paper)
beta_S <- 0.5           # within shielded pop
beta_S_ext <- 0.05      # shielded pop with rest of camp

mu <- 5.4/1000/365      # crude birth rate in Syria
birth <- 23.7/1000/365  # crude death rate in Syria
 

# This function models a time step for the SIR:
dx.dt.SIR <- function(t, y, parms) {
  
  # Calculating the total population size N (the sum of the number of people in each compartment)
  N <- y["S"] + y["S_S"] + y["E"]+ y["E_S"] + y["I"] + y["R"] #+ y["D"]
  
  # Defining lambda as a function of beta and I:
  lambda <- parms["beta"] * y["E"] / N
  lambda_S <- parms["beta_S"] * y["E_S"] / N
  lambda_S_ext <- parms["beta_S_ext"] * y["E"] / N
  
  # Calculate the change in Susceptibles
  dS <- - lambda * y["S"] + parms["birth"] * N - parms["mu"] * y["S"]
  dS_S <- - lambda_S * y["S_S"] - lambda_S_ext * y["S_S"] #Could also include births/deaths here
  dE <- lambda * y["S"] - parms["gamma_E"] * y["E"] - parms["mu"] * y["E"]
  dE_S <- lambda_S * y["S_S"] + lambda_S_ext * y["S"] - parms["gamma_E"] * y["E_S"] - parms["mu"] * y["E"]
  dI = parms["gamma_E"] * y["E"] + parms["gamma_E"] * y["E_S"] - parms["gamma_I"]*y["I"] - parms["mu"] * y["I"]
  dR <- parms["gamma_I"] * y["I"] - parms["mu"] * y["R"] #Could be splitted into R and D.
  
  # Return a list with the changes in S, I, R at the current time step
  return(list(c(dS,dS_S,dE,dE_S, dI, dR)))
}

# Create the parameter vector
parms_vector <- c(gamma_I=gamma_I, gamma_E=gamma_E,beta=beta,beta_S=beta_S,beta_S_ext=beta_S_ext, mu=mu, birth=birth)

# Sequence of times at which we estimate 
# (here, we do daily for 365 days - you can change this value)
times_vector <- seq(from=0, to=365, by=1)

# Run the ODE solver
SIR.output <- as.data.frame(lsoda(y=c(S=START.S,S_S=START.S_S,E=START.E,E_S=START.E_S, I=START.I, R=START.R), 
                                  times=times_vector, 
                                  func=dx.dt.SIR, 
                                  parms=parms_vector))

# Print the output: this is a matrix of S, I and R values at each time point						
#SIR.output

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
