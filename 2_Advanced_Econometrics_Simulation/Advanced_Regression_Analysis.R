#install.packages("caret")
#install.packages("psych")
#install.packages("rethinking")
library(tidyverse)
library(data.table)
library(broom) # for tidy statistical summaries
library(caret) # for regression performance measures
library(psych) # for pairwise comparisons
library(car) # for multicollinearity
library(moments) # for higher moments 
library(PearsonDS) # for Pearson distribution
library(rethinking) # for LKJ distribution


set.seed(55)
nvar <- 6
sampsize <- 1e3
etax <- 1e-3
train_ratio <- 0.7
matx <- rlkjcorr(1, nvar, etax)
sampx <- rmvnorm(1e3, sigma = matx)
sampx <- pnorm(sampx)
means <- rnorm(nvar)
vars <- rexp(nvar, 1)
kurts <- rexp(nvar, 1) + 3
skews <- (rbeta(nvar, 3, 3) - 0.5)*2

colnamesx <- paste(sample(words, nvar + 1), "1", sep = "")
sampx_dt <- as.data.table(sampx)
sampx_dt <- as.data.table(mapply(function(x, a, b, c, d) qpearson(x, moments = c(a, b, c, d)), sampx_dt,
                                 means, vars, skews, kurts))
paramst <- as.matrix(runif(nvar, -5, 5))
errx <- as.matrix(rnorm(sampsize, 0, sqrt(rexp(1, 0.1))))

responsex <- as.matrix(sampx_dt) %*% paramst + errx
sampx_dt <- cbind(responsex, sampx_dt)
setnames(sampx_dt, colnamesx)

train_indices <- sampx_dt[,sample(.N * train_ratio)]
train_data <- sampx_dt[train_indices]
test_data <- sampx_dt[-train_indices]


normlz <- function(x)
{
  meanr <- mean(x, na.rm = T)
  varr <- var(x, na.rm = T)
  skewr <- skewness(x, na.rm = T)
  kurtr <- kurtosis(x, na.rm = T)
  normlx <- qnorm(ppearson(x, moments = c(meanr, varr, skewr, kurtr)))
  ifelse(is.infinite(normlx), NA, normlx)
}


options(repr.plot.width = 15, repr.plot.height = 15)
pairs.panels(train_data)
#All variables are very similar to normal distributions, however almost all of them are skewed except must1. We can observe some correlation among variables, although not as high as 0.8. The strongest correlation is between enter1 and must1 or thing1, we can also observe moderately high correlation between quarter1 and various1 or which1, as well as some others. We do not see any non-linear relationships.

model1 <- lm(enter1 ~ quarter1 + various1 + must1 + thing1 + record1 + which1, train_data)
summary(model1)
#We can see that the p-value is extremely low, therefore we can say that the model is statistically significant at 5% level in terms of the null model. R-squared value is extremely close to 0.8, meaning that a meaningful portion of the variance of enter1 is explained by our model and is sufficiently high. By the p-values, we can judge that all variable coefficients besides the intercept and thing1 are statistically significant at 5% level. Intercept estimate is −2.6678, meaning that the expected value of enter1 when all predictors equal zero is −2.6678. However as we have established, it is not a good estimator. must1, record1 and which1 have positive signs and all the rest have negative signs.

options(repr.plot.width = 7, repr.plot.height = 7)
plot(model1)
#The fitted residuals form a circular shape around the center, showing heteroscedasticity, although not strong. This means that the error terms are not independant. The residuals are normally distributed as they fit very well onto the diognal line with mild deviations on the tails. Shapiro–Wilk test shows a p-value of 0.3624, which is above the 5% significance level. Therefore, we fail to reject the null hypothesis of normality, confirming that the residuals are normally distributed.

shapiro.test(model1$residuals)
vif(model1)
#The VIF results show a strong multicollinearity. Several predictors have VIF values far above the threshold of 5. Among these, various1 shows the highest VIF value at 117, making it the strongest contributor to multicollinearity. We could test again, excluding various1 and maybe quarter1 since it also has an extremely high multicollinearity.