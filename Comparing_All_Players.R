library(readr)
df <- read_csv("/Users/amithnair/Documents/Assignments/Sem2/Applied Statistical Modelling/Final assignment/data/analysis.csv")

library(dplyr)
df = df[,c("White.Player", "White.ACPL")]
colnames(df) <- c("Player", "ACPL")

ggplot(df) + geom_boxplot(aes(x = reorder(Player, ACPL, median), ACPL, 
                              fill = reorder(Player, ACPL, median)), 
                          show.legend=FALSE) + 
  theme(axis.text.x=element_text(angle=90, hjust=1))

ggplot(df, aes(x = reorder(Player, Player, length))) + 
  stat_count()+ theme(axis.text.x=element_text(angle=90, hjust=1))

ggplot(df, aes(ACPL)) + stat_bin()

ggplot(data.frame(size = tapply(df$ACPL, df$Player, length), 
                  mean_acpl = tapply(df$ACPL, df$Player, mean)), 
       aes(size, mean_acpl)) + geom_point()

player_names <-levels(factor(df$Player))
df$Player = factor(as.numeric(factor(df$Player)))

compare_m_gibbs <- function(y, ind, maxiter = 5000)
{
  
  ### weakly informative priors
  a0 <- 1 ; b0 <- 225 ## tau_w hyperparameters
  eta0 <-1 ; t0 <- 225 ## tau_b hyperparameters
  mu0<-30 ; gamma0 <- 1/100
  ###
  
  ### starting values
  m <- nlevels(ind)
  ybar <- theta <- tapply(y, ind, mean)
  tau_w <- mean(1 / tapply(y, ind, var)) ##within group precision
  mu <- mean(theta)
  tau_b <-var(theta) ##between group precision
  n_m <- tapply(y, ind, length)
  an <- a0 + sum(n_m)/2
  ###
  
  ### setup MCMC
  theta_mat <- matrix(0, nrow=maxiter, ncol=m)
  mat_store <- matrix(0, nrow=maxiter, ncol=3)
  ###
  
  ### MCMC algorithm
  for(s in 1:maxiter) 
  {
    
    # sample new values of the thetas
    for(j in 1:m) 
    {
      taun <- n_m[j] * tau_w + tau_b
      thetan <- (ybar[j] * n_m[j] * tau_w + mu * tau_b) / taun
      theta[j]<-rnorm(1, thetan, 1/sqrt(taun))
    }
    
    #sample new value of tau_w
    ss <- 0
    for(j in 1:m){
      ss <- ss + sum((y[ind == j] - theta[j])^2)
    }
    bn <- b0 + ss/2
    tau_w <- rgamma(1, an, bn)
    
    #sample a new value of mu
    gammam <- m * tau_b + gamma0
    mum <- (mean(theta) * m * tau_b + mu0 * gamma0) / gammam
    mu <- rnorm(1, mum, 1/ sqrt(gammam)) 
    
    # sample a new value of tau_b
    etam <- eta0 + m/2
    tm <- t0 + sum((theta - mu)^2) / 2
    tau_b <- rgamma(1, etam, tm)
    
    #store results
    theta_mat[s,] <- theta
    mat_store[s, ] <- c(mu, tau_w, tau_b)
  }
  colnames(mat_store) <- c("mu", "tau_w", "tau_b")
  return(list(params = mat_store, theta = theta_mat))
}

fit2 <- compare_m_gibbs(df$ACPL, df$Player)

theta_df <- data.frame(samples = as.numeric(fit2$theta),
                       player = rep(player_names, each = nrow(fit2$theta)))

ggplot(theta_df) + geom_boxplot(aes(x = reorder(player, samples, median), samples,
                    fill = reorder(player, samples, median)), show.legend=FALSE) +
  theme(axis.text.x=element_text(angle=90, hjust=1))
theta_df$player  <- factor(theta_df$player)




