library(readr)
df <- read_csv("/Users/amithnair/Documents/Assignments/Sem2/Applied Statistical Modelling/Final assignment/data/analysis.csv")

install.packages("dplyr")
library(dplyr)
df = filter(df, White.Player == "Anand, Viswanathan" | White.Player == "Carlsen, Magnus")
df = df[,c("White.Player", "White.ACPL")]
colnames(df) <- c("Player", "ACPL")
df$Player = factor(df$Player)
library("ggplot2")
ggplot(df) + geom_boxplot(aes(Player, ACPL, fill = Player)) + 
  geom_jitter(aes(Player, ACPL, shape = Player))
t.test(ACPL ~ Player, data = df, var.equal = TRUE)

compare_2_gibbs <- function(y, ind, mu0 = 20, tau0 = 1/49, del0 = 0, 
                            gamma0 = 1/529, a0 = 1, b0 = 20, maxiter = 5000)
{
  y1 <- y[ind == "Anand, Viswanathan"]
  y2 <- y[ind == "Carlsen, Magnus"]
  
  n1 <- length(y1) 
  n2 <- length(y2)
  
  ##### starting values
  mu <- (mean(y1) + mean(y2)) / 2
  del <- (mean(y1) - mean(y2)) / 2
  
  mat_store <- matrix(0, nrow = maxiter, ncol = 3)
  #####
  
  ##### Gibbs sampler
  an <- a0 + (n1 + n2)/2
  
  for(s in 1 : maxiter) 
  {
    
    ##update tau
    bn <- b0 + 0.5 * (sum((y1 - mu - del) ^ 2) + sum((y2 - mu + del) ^ 2))
    tau <- rgamma(1, an, bn)
    ##
    
    ##update mu
    taun <-  tau0 + tau * (n1 + n2)
    mun <- (tau0 * mu0 + tau * (sum(y1 - del) + sum(y2 + del))) / taun
    mu <- rnorm(1, mun, sqrt(1/taun))
    ##
    
    ##update del
    gamman <-  gamma0 + tau*(n1 + n2)
    deln <- ( del0 * gamma0 + tau * (sum(y1 - mu) - sum(y2 - mu))) / gamman
    del<-rnorm(1, deln, sqrt(1/gamman))
    ##
    
    ## store parameter values
    mat_store[s, ] <- c(mu, del, tau)
  }
  colnames(mat_store) <- c("mu", "del", "tau")
  return(mat_store)
}
library(mcmc)
library(coda)
fit <- compare_2_gibbs(df$ACPL, as.factor(df$Player))
plot(as.mcmc(fit))

raftery.diag(as.mcmc(fit))
