



eta <- 1./7
gammaI <- 1./7
alpha <- 1./10

qH <- c(0.064,0.067,0.199,0.183,0.445)
qD <- c(0.0065,0.02,0.094,0.063,0.222)

g <- gammaI / ( alpha / qD + gammaI*alpha*qH / eta / qD + gammaI - alpha*qH / qD - alpha)
h <- g * alpha * qH / eta / qD 

print(h)
print(g)


#Sanity check

testqH <- qH - h*eta / ( (1 - h - g)*gammaI + h*eta + g*alpha)
testqD <- qD - g*alpha / ( (1 - h - g)*gammaI + h*eta + g*alpha)

print(testqH)
print(testqD)

