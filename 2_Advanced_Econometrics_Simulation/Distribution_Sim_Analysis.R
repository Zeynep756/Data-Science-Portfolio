#install.packages("tidyverse")
#install.packages("data.table")
#install.packages("BBmisc")
#install.packages("PearsonDS")
#install.packages("moments")
#install.packages("plotly")


library(tidyverse)
library(data.table)
library(BBmisc)
library(PearsonDS)
library(moments)
library(plotly)
kurtranges <- list(c(2, 2.5), c(4, 5))
sizex <- 1e3
skewsign <- c(-1, 1)
normrange <- function(x, rang) rang[1] + diff(rang) * x
set.seed(62)
kurtlp <- sample(2)
skewnp <- sample(2)
kurtsamp1 <- runif(2)
kurtvals <- mapply(normrange, kurtsamp1, kurtranges[kurtlp])
skewrang <- mapply("*", lapply(sqrt(kurtvals - 1), c, 0.5), skewsign[skewnp], SIMPLIFY = F) %>% lapply(sort)
skewvals <- sapply(skewrang, function(x) runif(1, x[1], x[2]))
distnames <- c("sample 1", "sample 2", "normal")
samplesize <- 1e4
set.seed(10)
samples1 <- mapply(function(x, y) rpearson(samplesize, moments = c(0, 1, y, x)), kurtvals, skewvals, SIMPLIFY = F)
samples2 <- list(rnorm(samplesize))
samples2 <- lapply(samples2, normalize)
samples <- c(samples1, samples2)
samples_dt <- mapply(function(x, y) data.table(vals = x, distname = y),
                     samples, distnames, SIMPLIFY = F) %>% rbindlist
samples_dt %>%
  group_by(distname) %>%
  summarize(meanx = mean(vals), median = median(vals), sdx = sd(vals), skewx = skewness(vals), kurtx = kurtosis(vals)) %>%
  mutate_if(is.numeric, round, 2)

qvals <- seq(-5, 5, 0.1)
densities1 <- mapply(function(x, y) dpearson(qvals, moments = c(0, 1, y, x)), kurtvals, skewvals, SIMPLIFY = F)
densities2 <- list(normal = dnorm(qvals))
densities <- c(densities1, densities2)
densities_dt <- mapply(function(x, y) data.table(qval = qvals, dens = x, distname = y),
                       densities, distnames, SIMPLIFY = F) %>% rbindlist                     
densep <- densities_dt %>%
  highlight_key(~distname) %>%
  ggplot(aes(x = qval, y = dens, col = distname)) +
  geom_line()
ggplotly(densep) %>%
  highlight(
    on = "plotly_click",
    off = "plotly_relayout",
    opacityDim = .1
  )

histplot2 <- samples_dt[, (c("meanx", "medianx")) := .(mean(vals), median(vals)), by = distname][] %>%
  ggplot(aes(x = vals)) +
  geom_histogram() +
  geom_vline(aes(xintercept = meanx), color = "red") +
  geom_vline(aes(xintercept = medianx), color = "blue") +
  xlim(c(-5, 5)) +
  facet_wrap(. ~ distname, nrow = 7)
ggplotly(histplot2) %>% layout(autosize = F, width = 800, height = 800)

samples_dt[, as.list(quantile(vals, seq(0, 1, 0.1)) %>% round(2)), by = distname] %>% t

#Sample 1 is a platykurtic distribution. The skewness value is 0.87 which is also visible in both the density plot and histogram, because most values are on the left and observations which deviate the most from the mean extend to the right. The mean is larger than the median (mean=0 > median=−0.68), which further confirms the right-skewedness. The kurtosis value is 2.02 and it is lower than the normal distribution’s kurtosis. We can also see this by the quantile table where lower quantiles are concentrated around −0.77, while the right tail stretches more without having extreme values(low kurtosis). In conclusion, Sample 1 deviates from the normal distribution.

Sample 2 is leptokurtic. The skewness value is −0.87, which can be seen in the histogram and density plot where values go further in the negative direction. The median is greater than the mean (median=0.15 > mean=0.02). The kurtosis value is 4.35 and higher than normal distribution's 3, meaning that Sample 2 has heavier tails than the normal distribution. We can also see this with the quantile table, where both low and high extreme values deviate more heavily than they do with the normal distribution. Sample 2 is closer to the normal distribution with a high kurtosis and left-skewness.