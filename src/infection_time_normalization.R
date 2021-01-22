#***************************************
#infection_time_normalization.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 21st January 2021
#description = Compute the correction coefficients for the infectious periods.
#usage = eta, gammaI, alpha





eta <- 1./7 #severe cases rate
alpha <- 1./10 #critical cases rate
gammaI <- 1./7 #rest of the cases

h <- c(0.064,0.067,0.199,0.183,0.445) #Fractions of severe cases (by age group)
g <- c(0.0065,0.02,0.094,0.063,0.222) #Fractions of critical cases (by age group)

b <- gammaI / ( alpha / g + gammaI*alpha*h / eta / g + gammaI - alpha*h / g - alpha)
a <- b * alpha * h / eta / g

print(a)
print(b)


#Sanity check

testh <- h - a*eta / ( (1 - a - b)*gammaI + a*eta + b*alpha)
testg <- g - b*alpha / ( (1 - a - b)*gammaI + a*eta + b*alpha)

print(testh)
print(testg)

