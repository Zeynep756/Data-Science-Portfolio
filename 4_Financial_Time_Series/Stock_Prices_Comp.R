library(pwt8)
library(ggplot2)
library(quantmod)

#stock prices comparison
start_date <- as.Date("2005-05-05")
end_date <- as.Date("2023-10-01")
stocks<- vector()
stocks <- c("MSFT", "AMZN")
getSymbols(stocks, src = "yahoo", from = start_date, to = end_date, periodicity = "weekly", auto.assign = TRUE)
amzn_weekly_close <- Cl(AMZN)
msft_weekly_close <- Cl(MSFT)
plot(amzn_weekly_close, main = "Weekly Closing Prices of AMZN and MSFT", type= "l", col = "lightgreen")
lines(msft_weekly_close, col = "lightpink")
info<- function(s){
  max<-max(s, na.rm = TRUE)
  min<-min(s, na.rm = TRUE)
  avg<-mean(s, na.rm = TRUE)
  sd<-sd(s, na.rm = TRUE)
  range<- max-min
  cv<- sd/avg
  cat("max is", max, "\n",
      "min is", min, "\n",
      "average is", avg, "\n",
      "standard deviation is", sd, "\n",
      "range is", range, "\n",
      "cv is", cv, "\n")
}
info(amzn_weekly_close)
info(msft_weekly_close)

amzn_roll_sd <- rollapply(amzn_weekly_close, width = 8, FUN = sd, align = 'right', by.column = TRUE, fill = NA)
msft_roll_sd <- rollapply(msft_weekly_close, width = 8, FUN = sd, align = 'right', by.column = TRUE, fill = NA)
plot(amzn_roll_sd, main = "8-Week Rolling Sd of AMZN and MSFT", col = "lightblue", ylim = range(c(amzn_roll_sd, msft_roll_sd), na.rm = TRUE))
lines(msft_roll_sd, col = "lightpink")
legend("topright", legend = c("AMZN Roll SD", "MSFT Roll SD"), col = c("lightblue", "lightpink"))


#gdp comparison
sweden<- subset(pwt8.0, isocode=="SWE" & year %in% c(1995:2005))
sweden$growth_rate<- c(NA, diff(log(sweden$rgdpo))) * 100

belgium<- subset(pwt8.0, isocode=="BEL" & year %in% c(1995:2005))
belgium$growth_rate<- c(NA, diff(log(belgium$rgdpo))) * 100

sweden_gdp<- qplot(
  year,
  growth_rate,
  data=sweden,
  geom = "line",
  na.rm = TRUE,
  main = "Sweden's GDP Growth"
)
sweden_gdp

comparison_swe_vs_bel<- ggplot() +
  geom_line(data = sweden, aes(x = year, y = growth_rate, color = "Sweden"), na.rm = TRUE) +
  geom_line(data = belgium, aes(x = year, y = growth_rate, color = "Belgium"), na.rm = TRUE) +
  labs(title = "Sweden and Belgium's GDP Per Capita Growth Rate",
       x = "Year",
       y = "Growth Rate (%)") 
comparison_swe_vs_bel

nepal<- subset(pwt8.0, isocode=="NPL" & year %in% c(1999:2005))
nepal$capital_growth <-  c(NA, diff(log(nepal$ck))) * 100
nepal_capital<- qplot(
  year,
  ck,
  data=nepal,
  geom = "line",
  main = "Nepal's Capital Stock Growth",
  na.rm = TRUE
)
nepal_capital

serbia<- subset(pwt8.0, isocode=="SRB" & year %in% c(1999:2005))
serbia$capital_growth <-  c(NA, diff(log(serbia$ck))) * 100

comparison_nep_vs_serb <- ggplot() +
  geom_line(data = nepal, aes(x = year, y = capital_growth, color = "Nepal"), na.rm = TRUE) +
  geom_line(data = serbia, aes(x = year, y = capital_growth, color = "Serbia"), na.rm = TRUE) +
  labs(title = "Nepal and Serbia's Capital Stock Growth Rate",
       x = "Year",
       y = "Growth Rate (%)") 
comparison_nep_vs_serb


#probability calculation
p <- function(n, x) {
  if (x < 2 || x > n) {
    return(0)
  }
  probability <- (365 - (0:(x-2))) / 365
  probability <- 1 - prod(probability)^choose(n, x)
  return(probability)
}

n_values <- 1:100
x_values <- 2:10

prob_matrix <- matrix(0, nrow = length(n_values), ncol = length(x_values))

for (n in n_values) {
  for (x in x_values) {
    prob_matrix[n, x - 1] <- p(n, x)
  }
}

prob_matrix <- t(prob_matrix)

persp(x_values, n_values, prob_matrix, theta = 30, phi = 30, expand = 0.5, col = "lightblue",
      xlab = "Number of People Sharing a Birthday (x)", ylab = "Class Size (n)", zlab = "Probability")


#success rate
num_experiments <- 1000
success_count <- 0
frequencies <- numeric(num_experiments)

single_experiment <- function() {
  sum(sample(c(0, 1), size = 3, replace = TRUE)) >= 1
}
for (i in 1:num_experiments) {
  if (single_experiment()) {
    success_count <- success_count + 1
  }
  frequencies[i] <- success_count / i
}

plot(frequencies, type = "l", col = "pink", xlab = "Experiment Number", ylab = "Probability of at least one head", main = "Convergence of Frequency")

abline(h = 7/8, col = "lightblue", lty = 2)

final_frequency <- success_count / num_experiments
print(final_frequency)
