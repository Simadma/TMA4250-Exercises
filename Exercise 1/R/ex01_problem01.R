#Code for project 1 in spatial statistics
library(MASS)
library(fields)
library(akima)
library(geoR)
library(gridExtra)
library(latex2exp)
library(tidyverse)
library(reshape2)

fig_path <- "./Exercise 1/Figures/"

#problem 1

#L=[1,50]
L <- 1:50
taus <- L-1

#model parameters
mu_r <- rep(0, 50) # expectation
sigma2_r <- c(1,5) # variance
phi <- 10 #range parameter
tau <- function(x1,x2){
  return (abs(x1-x2)/10)
}

#parameters for powered exponential and matern
nu_r_pexp <- c(1,1.9)
nu_r_mat <- c(1,3)



#a)
#finding the covariances for all eight model pairs
cov1 <-cov.spatial(taus, cov.model="powered.exponential",cov.pars = c(sigma2_r[1], phi), kappa=nu_r_pexp[1])
cov2 <-cov.spatial(taus, cov.model="powered.exponential",cov.pars = c(sigma2_r[2], phi), kappa=nu_r_pexp[1])
cov3 <-cov.spatial(taus, cov.model="powered.exponential",cov.pars = c(sigma2_r[1], phi), kappa=nu_r_pexp[2])
cov4 <-cov.spatial(taus, cov.model="powered.exponential",cov.pars = c(sigma2_r[2], phi), kappa=nu_r_pexp[2])
cov5 <-cov.spatial(taus, cov.model="matern",cov.pars = c(sigma2_r[1], phi), kappa=nu_r_mat[1])
cov6 <-cov.spatial(taus, cov.model="matern",cov.pars = c(sigma2_r[2], phi), kappa=nu_r_mat[1])
cov7 <-cov.spatial(taus, cov.model="matern",cov.pars = c(sigma2_r[1], phi), kappa=nu_r_mat[2])
cov8 <-cov.spatial(taus, cov.model="matern",cov.pars = c(sigma2_r[2], phi), kappa=nu_r_mat[2])


#data frame for plotting (Note: these are the covariances (but only the ones with var=1))
df_cov <- rbind(
  expand.grid(tau = taus, rho = 0, type = "Pow. exp.", nu = c(1, 1.9)),
  expand.grid(tau = taus, rho = 0, type = "Matérn", nu = c(1, 3))
)


#add data
df_cov[df_cov$type == "Pow. exp." & df_cov$nu == 1, ]$rho <- cov1
df_cov[df_cov$type == "Pow. exp." & df_cov$nu == 1.9, ]$rho <- cov3
df_cov[df_cov$type == "Matérn" & df_cov$nu == 1, ]$rho <- cov5
df_cov[df_cov$type == "Matérn" & df_cov$nu == 3, ]$rho <- cov7



#calculating the variogram function values
variogram <- function(covariance, sigma2) {
  return (sigma2 - covariance) #sigma_r^2( 1 - rho_r)=sigma_r^2 - cov
}


#sigma^2=1
variog1 <- variogram(cov1, sigma2_r[1]) 
variog3 <- variogram(cov3, sigma2_r[1])
variog5 <- variogram(cov5, sigma2_r[1])
variog7 <- variogram(cov7, sigma2_r[1])

#sigma^2 not 1
variog2 <- variogram(cov2, sigma2_r[2])
variog4 <- variogram(cov4, sigma2_r[2])
variog6 <- variogram(cov6, sigma2_r[2])
variog8 <- variogram(cov8, sigma2_r[2])

#add the values to dataframes for ggplots
df_vario <- rbind(
  expand.grid(tau = taus, gamma = 0, type = "Pow. exp.", sigma_sq = c(1, 5), nu = c(1, 1.9)),
  expand.grid(tau = taus, gamma = 0, type = "Matérn", sigma_sq = c(1, 5), nu = c(1, 3))
)

df_vario[df_vario$type == "Pow. exp." & df_vario$nu == 1 & df_vario$sigma_sq == 1, ]$gamma <- variog1
df_vario[df_vario$type == "Pow. exp." & df_vario$nu == 1 & df_vario$sigma_sq == 5, ]$gamma <- variog2
df_vario[df_vario$type == "Pow. exp." & df_vario$nu == 1.9 & df_vario$sigma_sq == 1, ]$gamma <- variog3
df_vario[df_vario$type == "Pow. exp." & df_vario$nu == 1.9 & df_vario$sigma_sq == 5, ]$gamma <- variog4
df_vario[df_vario$type == "Matérn" & df_vario$nu == 1 & df_vario$sigma_sq == 1, ]$gamma <- variog5
df_vario[df_vario$type == "Matérn" & df_vario$nu == 1 & df_vario$sigma_sq == 5, ]$gamma <- variog6
df_vario[df_vario$type == "Matérn" & df_vario$nu == 3 & df_vario$sigma_sq == 1, ]$gamma <- variog7
df_vario[df_vario$type == "Matérn" & df_vario$nu == 3 & df_vario$sigma_sq == 5, ]$gamma <- variog8


corr <- ggplot(data = df_cov, aes(x=tau, y=rho, color=as.factor(nu), linetype = type)) +
  geom_line() +
  #scale_color_manual(name="Type", labels=c("1", "2", "3", "4", "5", "6", "7", "8"), values = c()) +
  xlab(TeX("Distance, $\\tau$")) +
  ylab(TeX("Correlation, $\\rho_r(\\tau)$")) +
  labs(color = "Corr.function", linetype=TeX("$\\nu_r$")) +
  theme_bw()  
corr

#ggsave("correlation.png", plot=corr)

df_vario$sigma_sq <- as.factor(df_vario$sigma_sq)
levels(df_vario$sigma_sq) <- c(TeX("$\\sigma_r^2 = 1$"), TeX("$\\sigma_r^2 = 5$"))
vario <- ggplot(data = df_vario, aes(x=tau, y=gamma, color=as.factor(nu), linetype = type)) +
  geom_line() +
  facet_grid(. ~ sigma_sq, labeller=label_parsed) +
  xlab(TeX("Distance, $\\tau$")) +
  ylab(TeX("Variogram, $\\gamma_r(\\tau)$")) +
  labs(color = "Corr.function", linetype=TeX("$\\nu_r$")) +
  theme_bw()  
vario

# ggsave(paste0(fig_path, "variogram.pdf"),
#   plot = vario,
#   width = 4,
#   height = 4,
#   units = "in"
# )





#b)
#prior model is N_50(mu, sigma)

#function to convert the vector of covariances to the variance-covariance matrix
converttosigma <- function(cov, sigma2){
  n <- length(cov)
  Sigma <- matrix(NA, nrow=n, ncol=n)
  for (i in 1:n) {
    for (j in 1:n){
      h <- abs(j-i)
      Sigma[i, j] <- cov[h+1] #first index is 1
    }
  }
  return(Sigma)
}

#simulate four realizations for all eight sets of model parameters

#function to do the simulations
getsimulations <- function(nofsims, grid, mu_r, cov, sigma2){
  sigma <- converttosigma(cov, sigma2)
  simulations <- matrix(NA, nrow = nofsims, ncol=dim(sigma)[1]) #to store the simulations
  for (i in 1:nofsims){
    simulations[i,] <- mvrnorm(n = 1, mu=mu_r, Sigma=sigma) #simulations
  }
  return(t(simulations))
}

#function to plot the simulations
plotsimulations <- function(yscale, simulations, fn, save=FALSE){
  simulationdf <- data.frame(L=L,x1 = simulations[,1], x2 = simulations[,2], x3 = simulations[,3], x4 = simulations[,4])
  p1 <- ggplot(data=simulationdf, aes(x=L)) +
    geom_line(aes(y=x1, col="1")) +
    geom_line(aes(y=x2, col="2")) + 
    geom_line(aes(y=x3, col="3")) +
    geom_line(aes(y=x4, col="4")) +
    ylim(yscale) +
    xlab("x")+
    ylab("r(x)") +
    theme_bw()+
    theme(legend.position = "none")
  if (save==TRUE){
    ggsave(filename=fn, p1, path="./Exercise 1/Figures/")
  }
}


#1: powered exponential, sigma=1, nu=1
set.seed(1)
simulation1 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov1, sigma2=sigma2_r[1])


#2: powered exponential, sigma=5, nu=1
set.seed(2)
simulation2 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov2, sigma2=sigma2_r[2])



#3: powered exponential, sigma=1, nu=1.9
set.seed(3)
simulation3 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov3, sigma2=sigma2_r[1])



#4: powered exponential, sigma=5, nu=1.9
set.seed(4)
simulation4 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov4, sigma2=sigma2_r[2])

#plotting:
yscale <- c(min(simulation1, simulation2, simulation3, simulation4),max(simulation1, simulation2, simulation3, simulation4))

plotsimulations(yscale, simulation1, "1b1p.pdf", save=TRUE)
plotsimulations(yscale, simulation2, "1b2p.pdf", save=TRUE)
plotsimulations(yscale, simulation3, "1b3p.pdf", save=TRUE)
plotsimulations(yscale, simulation4, "1b4p.pdf", save=TRUE)
#plotsimulations(nofsims=4,simulations=simulation1, grid=L, fn = "1b1p.pdf")#, save= TRUE)
#plotsimulations(nofsims=4,simulations=simulation2, grid=L, fn = "1b2p.pdf")#, save= TRUE)
#plotsimulations(nofsims=4,simulations=simulation3, grid=L, fn = "1b3p.pdf")#, save= TRUE)
#plotsimulations(nofsims=4,simulations=simulation4, grid=L, fn = "1b4p.pdf")#, save= TRUE)


#5: Matern, sigma=1, nu=1
set.seed(5)
simulation5 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov5, sigma2=sigma2_r[1])


#6: Matern, sigma=5, nu=1
set.seed(6)
simulation6<-getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov6, sigma2=sigma2_r[2])


#7: Matern, sigma=1, nu=3
set.seed(7)
simulation7 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov7, sigma2=sigma2_r[1])


#8: Matern, sigma=5, nu=3
set.seed(8)
simulation8 <- getsimulations(nofsims=4, grid=L, mu_r=mu_r, cov=cov8, sigma2=sigma2_r[2])

yscale2 <- c(min(simulation5, simulation6, simulation7, simulation8),max(simulation5, simulation6, simulation7, simulation8))

plotsimulations(yscale2, simulation5, "1b5m.pdf", save=TRUE)
plotsimulations(yscale2, simulation6, "1b6m.pdf", save=TRUE)
plotsimulations(yscale2, simulation7, "1b7m.pdf", save=TRUE)
plotsimulations(yscale2, simulation8, "1b8m.pdf", save=TRUE)

#1d 
#Useful quantities
m<-3 #number of observed points
n<-50 #number of grid points
z_005 <- qnorm(0.05, lower.tail=FALSE) #critical value for 90% conf.int
#Useful vectors:
#identity vectors
i_n <- rep(1,n)
i_m <- rep(1,m)

#vector of the observed points
observedpoints <- c(10,25,30)

#choose what simulation to use as observed data
#here: pow.exp realisation with sigma = 5, nu= 1.9 (sim4)
r_x <- simulation4[,2]
sigma_r <- sigma2_r[2]
Sigma_r <- converttosigma(cov4, sigma_r) #sigma=5, nu=1.9 pow.exp

#possible observation errors
sigma_es <- c(0, 0.25)
#variance-covariances for the observations (with and with-out observation error)
Sigma_dr1 <- sigma_es[2]*diag(m)
Sigma_dr2 <- sigma_es[1]*diag(m)


#observation matrix
H_0 <- matrix(0, nrow = m, ncol=n)
i = 1
for (d in observedpoints){
  H_0[i,d]<-1
  i <- i+1
}

#Getting the observed values
d <- H_0%*%r_x

posteriordist_mean <- function(mu_r, d, Sigma_r, Sigma_dr, H_0){
  #Posterior mean
  mu_rd <- mu_r + Sigma_r%*%t(H_0)%*%solve(H_0%*%Sigma_r%*%t(H_0) + Sigma_dr)%*%(d-H_0%*%mu_r)
  return (mu_rd)
}
posteriordist_cov <- function(mu_r, d, Sigma_r, Sigma_dr, H_0) {
  #Posterior variance-covariance matrix
  Sigma_rd <- matrix(NA, nrow=length(mu_r), ncol=length(mu_r))
  Sigma_rd <- Sigma_r-Sigma_r%*%t(H_0)%*%solve(H_0%*%Sigma_r%*%t(H_0) + Sigma_dr)%*%H_0%*%Sigma_r
  return (Sigma_rd)
}

predictioninterval <- function(L, mu_rd, Sigma_rd, criticalvalue){
  upper_pred <- mu_rd + criticalvalue*sqrt(abs(diag(Sigma_rd)))
  lower_pred <- mu_rd - criticalvalue*sqrt(abs(diag(Sigma_rd)))
  #store the values for plotting
  df <- data.frame(grid=L, mu = mu_rd, upper = upper_pred, lower=lower_pred)
  return(df)
}

#Observation error
posteriormean1 <- posteriordist_mean(mu_r=mu_r, d=d, Sigma_r=Sigma_r, Sigma_dr=Sigma_dr1, H_0 = H_0)
posteriorcov1 <- posteriordist_cov(mu_r=mu_r, d=d, Sigma_r=Sigma_r, Sigma_dr=Sigma_dr1, H_0 = H_0)
pred1 <- predictioninterval(L=L, mu_rd =posteriormean1, Sigma_rd=posteriorcov1, criticalvalue = z_005)


#No observation error
posteriormean2 <- posteriordist_mean(mu_r=mu_r, d=d, Sigma_r=Sigma_r, Sigma_dr=Sigma_dr2, H_0 = H_0)
posteriorcov2 <- posteriordist_cov(mu_r=mu_r, d=d, Sigma_r=Sigma_r, Sigma_dr=Sigma_dr2, H_0 = H_0)
pred2 <- predictioninterval(L=L, mu_rd =posteriormean2, Sigma_rd=posteriorcov2, criticalvalue = z_005)


#df1da <- predictionposterior(L=L, mu_r = mu_r, Sigma_r =Sigma_r, Sigma_dr=Sigma_dr1, observedpoints=observedpoints, criticalvalue=z_005)
fig1da <- ggplot(data=pred1) +
  geom_line(aes(x=grid, y=mu), color="red") + 
  geom_line(aes(x=grid, y=lower), color="darkblue", linetype="dashed") +
  geom_line(aes(x=grid, y=upper), color="darkblue", linetype="dashed") +
  #geom_point(aes(x=observedpoints, y=mu[observedpoints]), color="black") + #points where we have done observations
  xlab("L") +
  ylab("r|d") + 
  labs(title="Conditional expectation with a 90% prediction interval. \nObservation error is present ") + 
  theme_minimal()
fig1da
ggsave(filename="1da.png", plot=fig1da)
fig1db <- ggplot(data=pred2) +
  geom_line(aes(x=grid, y=mu), color="red") + 
  geom_line(aes(x=grid, y=lower), color="darkblue", linetype="dashed") +
  geom_line(aes(x=grid, y=upper), color="darkblue", linetype="dashed") +
  #geom_point(aes(x=observedpoints, y=mu[observedpoints]), color="black") + #points where we have done observations
  xlab("L") +
  ylab("r|d") + 
  labs(title="Conditional expectation with a 90% prediction interval. \nNo error in the observations") +
  theme_minimal()
fig1db
ggsave(filename="1db.png", plot=fig1db)




#1e
#100 simulations for each model parameter
nsim <- 100 # use 10 for now while testing


#first model with observation error
#posterior
mu_rd1 <- posteriormean1
Sigma_rd1 <- posteriorcov1

#do 100 simulations
set.seed(123456)
simulations1 <- mvrnorm(n=nsim, mu=mu_rd1, Sigma=Sigma_rd1)

#find mean and variance for the 100 samples
postmean1 <-apply(simulations1, MARGIN = 2, mean)
postvar1 <- apply(simulations1, MARGIN = 2, var)

#lower and upper 0.90 percentile
upper1 <- postmean1 +z_005*sqrt(postvar1)
lower1 <- postmean1 -z_005*sqrt(postvar1)

df.1e1 <- data.frame(x=L, mean = postmean1, lower.pred=lower1, upper.pred=upper1)
df.1esim <- as.data.frame(t(simulations1), id.vars="simnumber")

p1 <- ggplot(data = df.1esim, aes(x = L))
for (i in 1:nsim) {
  p1 <- p1 + geom_line(aes_string(y = paste0("V", i)))
}
p1 +
  geom_line(data=df.1e1, aes(x=L, y=mean), color="red") +
  geom_line(data=df.1e1, aes(x=L, y=lower.pred), color="darkblue", linetype="dotted") +
  geom_line(data=df.1e1, aes(x=L, y=upper.pred), color="darkblue", linetype="dotted") +
  xlab("x") +
  ylab("r|d") +
  labs(title = "Prediction based on 100 realisations \nfrom prediction with observation error", color="Prediction") +
  # scale_color_manual(values= c("mean" = 'red', "lower"='blue', "upper"='blue')) +
  theme_minimal()
ggsave("pred100wobserr.pdf")


#second model with no observation error
#posterior
mu_rd2 <- posteriormean2
Sigma_rd2 <- posteriorcov2
set.seed(654321)
simulations2 <- mvrnorm(n=nsim, mu=mu_rd2, Sigma=Sigma_rd2)

postmean2 <-apply(simulations2, MARGIN = 2, mean)
postvar2 <- apply(simulations2, MARGIN = 2, var)
upper2 <- postmean2 +z_005*sqrt(postvar2)
lower2 <- postmean2 -z_005*sqrt(postvar2)

df.1e2 <- data.frame(x=L, mean = postmean2, lower.pred=lower2, upper.pred=upper2)
df.1esim2 <- as.data.frame(t(simulations1), id.vars="simnumber")
p2 <- ggplot(data = df.1esim2, aes(x = L))
for (i in 1:nsim) {
  p2 <- p2 + geom_line(aes_string(y = paste0("V", i)))
}
p2 +
  geom_line(data=df.1e1, aes(x=L, y=mean), color="red") +
  geom_line(data=df.1e1, aes(x=L, y=lower.pred), color="darkblue", linetype="dotted") +
  geom_line(data=df.1e1, aes(x=L, y=upper.pred), color="darkblue", linetype="dotted") +
  xlab("x") +
  ylab("r|d") +
  labs(title = "Prediction based on 100 realisations \nfrom prediction without observation error", color="Prediction") +
  # scale_color_manual(values= c("mean" = 'red', "lower"='blue', "upper"='blue')) +
  theme_minimal()

ggsave("pred100woobserr.pdf")


#1f

A_r <- function(r){
  return(sum((r>2)*(r-2)))
}

A_r_tilde <- A_r(postmean)

A_r_hats <- apply(simulations, MARGIN=1, A_r)
A_r_hat_u <- mean(A_r_hats) + z_005*sd(A_r_hats)
A_r_hat_l <- mean(A_r_hats) - z_005*sd(A_r_hats)

A_r_hat_int <- c(A_r_hat_l, A_r_hat_u)

