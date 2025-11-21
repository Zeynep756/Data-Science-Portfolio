
library(readxl)
data <- read_excel("/Users/zeynepgirginer/Downloads/1data.xlsx")
head(data)
getwd()
setwd("/Users/zeynepgirginer/Downloads")
names(data) 
regression_data <- data[, c("msq", "perf_promo", "perf_jobsecurity", "perf_pay", "perf_mgr", "perf_peers", "division")]
regression_data$division <- as.factor(regression_data$division)
model <- lm(msq ~ perf_promo + perf_jobsecurity + perf_pay + perf_mgr + perf_peers + division, data = regression_data)
summary(model)
library(ggplot2)
library(readxl)
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(readxl))
data <- read_excel("/Users/zeynepgirginer/Downloads/1data.xlsx")
head(data)
library(dplyr)
library(ggplot2)
search()

avg_satisfaction <- regression_data %>%
  group_by(division) %>%
  summarise(mean_msq = mean(msq, na.rm = TRUE)) 

print(avg_satisfaction)
ggplot(avg_satisfaction, aes(x = division, y = mean_msq)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme_minimal() +
  labs(title = "Average Job Satisfaction by Division",
       x = "Division", y = "Average Job Satisfaction (msq)") +
  geom_text(aes(label=round(mean_msq, 2)), vjust=-0.3, color="black", size=3.5)

ggplot(avg_satisfaction, aes(x = division, y = mean_msq)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme_minimal() +
  labs(title = "Average Job Satisfaction by Division",
       x = "Division", y = "Average Job Satisfaction (msq)") +
  geom_text(aes(label=round(mean_msq, 2)), vjust=-0.3, color="black", size=3.5)

ggplot(regression_data, aes(x = perf_promo, y = msq)) +
  geom_point(color = "blue", alpha = 0.5) +  
  geom_smooth(method = "lm", color = "red") + 
  theme_minimal() +
  labs(title = "Regression of MSQ on Performance Promotion",
       x = "Performance Promotion",
       y = "Mean Satisfaction (msq)")

regression_data$residuals <- residuals(model)

# Plot residuals
ggplot(regression_data, aes(x = fitted(model), y = residuals)) +
  geom_point(color = "darkgreen") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Residual Plot For Performance Promotion",
       x = "Fitted Values",
       y = "Residuals")
library(broom)

coef_df <- tidy(model)
ggplot(coef_df, aes(x = term, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = estimate - std.error, ymax = estimate + std.error), width = 0.2) +
  coord_flip() +  # Flip coordinates for better readability
  theme_minimal() +
  labs(title = "Regression Coefficients",
       x = "Terms",
       y = "Estimate")

ggplot(regression_data, aes(x = perf_promo, y = msq, color = division)) +
  geom_point(alpha = 0.6) + 
  geom_smooth(method = "lm", aes(group = division), se = FALSE) +  
  scale_color_manual(values = c("red", "blue", "green", "violet", "orange")) +  
  theme_minimal() +
  labs(title = "Interaction Plot: Performance Promotion vs. MSQ by Division",
       x = "Performance Promotion",
       y = "Mean Satisfaction (msq)")

ggplot(regression_data, aes(x = perf_mgr, y = msq, color = division)) +
  geom_point(alpha = 0.6) + 
  geom_smooth(method = "lm", aes(group = division), se = FALSE) + 
  scale_color_manual(values = c("red", "blue", "green", "violet", "orange")) +
  theme_minimal() +
  labs(title = "Interaction Plot: Performance Recognition by Manager vs. MSQ by Division",
       x = "Performance Recognition by Manager",
       y = "Mean Satisfaction (msq)")
