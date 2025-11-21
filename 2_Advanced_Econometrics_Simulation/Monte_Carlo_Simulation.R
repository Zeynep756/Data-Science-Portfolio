# Monte Carlo OLS Regression Experiment on Project1_data.xlsx
#
# - Data: two predictor sets (set_1, set_2) with X1, X2, X3
# - True DGP: Y = 3 + 1*X1 + 1*X2 - 1*X3 + u
#             u ~ N(0, 40)
# - For each dataset:
#     * Simulate n_rep outcomes Y^(r)
#     * Estimate OLS: Y^(r) ~ X1 + X2 + X3
#     * Store coefficient paths and performance metrics
#     * Summarize bias & variability of estimates
#     * Run full diagnostics (robust SE, BP, VIF, residual plots)

library(readxl)
library(dplyr)
library(tidyr)
library(broom)
library(lmtest)
library(sandwich)
library(car)
library(ggplot2)
library(tibble)

file_path <- "/Users/zeynepgirginer/Downloads/Project1_data.xlsx"

# Monte Carlo parameters
set.seed(21)
n_rep   <- 100
sigma2  <- 40
sigma_u <- sqrt(sigma2)

# True betas (DGP)
beta_true <- c(
  `(Intercept)` = 3,
  X1 = 1,
  X2 = 1,
  X3 = -1
)

# DATA IMPORT
set_1 <- read_excel(file_path, sheet = 1)
set_2 <- read_excel(file_path, sheet = 2)

check_and_prepare_X <- function(df, dataset_name) {
  num_cols <- names(df)[sapply(df, is.numeric)]
  if (!all(c("X1", "X2", "X3") %in% num_cols)) {
    stop(
      "In dataset '", dataset_name,
      "': expected numeric columns X1, X2, X3 but got: ",
      paste(num_cols, collapse = ", ")
    )
  }
  df %>%
    select(X1, X2, X3) %>%
    drop_na()
}

X1_df <- check_and_prepare_X(set_1, "set_1")
X2_df <- check_and_prepare_X(set_2, "set_2")

# SINGLE OLS DIAGNOSTICS

run_single_ols_diagnostics <- function(y, X, dataset_name = "dataset") {
  df_model <- data.frame(y = y, X)
  fit      <- lm(y ~ ., data = df_model)
  preds    <- names(coef(fit))[-1]  # predictors except intercept
  
  cat("\n============================\n")
  cat("Single OLS diagnostics for:", dataset_name, "\n")
  cat("============================\n\n")
  
  # OLS Summary
  cat("--- OLS summary (", dataset_name, ") ---\n", sep = "")
  print(summary(fit))
  
  # Tidy coefficients
  cat("\n--- Tidy coefficients (", dataset_name, ") ---\n", sep = "")
  print(tidy(fit))
  
  # Robust (HC1) SE
  cat("\n--- Robust (HC1) standard errors (", dataset_name, ") ---\n", sep = "")
  robust_vcov  <- vcovHC(fit, type = "HC1")
  robust_coefs <- coeftest(fit, vcov = robust_vcov)
  print(robust_coefs)
  
  # Breusch-Pagan (heteroskedasticity)
  cat("\n--- Breusch-Pagan test (", dataset_name, ") ---\n", sep = "")
  print(bptest(fit))
  
  # Multicollinearity (VIF)
  if (length(preds) >= 2) {
    cat("\n--- VIF (multicollinearity) (", dataset_name, ") ---\n", sep = "")
    print(vif(fit))
  } else {
    cat("\n[Info] Only one predictor: VIF not computed.\n")
  }
  
  # Performance metrics
  y_true <- df_model$y
  y_hat  <- fitted(fit)
  resid  <- resid(fit)
  rmse   <- sqrt(mean(resid^2))
  
  perf <- tibble(
    rmse   = rmse,
    r2     = summary(fit)$r.squared,
    adj_r2 = summary(fit)$adj.r.squared
  )
  
  cat("\n--- Model performance (", dataset_name, ") ---\n", sep = "")
  print(perf)
  
  # Residual diagnostic plots
  aug <- augment(fit)
  
  p_resid_vs_fitted <- ggplot(aug, aes(.fitted, .resid)) +
    geom_point(alpha = 0.6) +
    geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
    labs(
      title = paste("Residuals vs Fitted -", dataset_name),
      x = "Fitted values",
      y = "Residuals"
    ) +
    theme_minimal()
  
  p_qq <- ggplot(aug, aes(sample = .std.resid)) +
    stat_qq(alpha = 0.6) +
    stat_qq_line(color = "red") +
    labs(
      title = paste("Normal Q-Q of standardized residuals -", dataset_name),
      x = "Theoretical quantiles",
      y = "Standardized residuals"
    ) +
    theme_minimal()
  
  p_scale_location <- ggplot(aug, aes(.fitted, sqrt(abs(.std.resid)))) +
    geom_point(alpha = 0.6) +
    geom_smooth(se = FALSE, color = "blue") +
    labs(
      title = paste("Scale-Location -", dataset_name),
      x = "Fitted values",
      y = "√|Standardized residuals|"
    ) +
    theme_minimal()
  
  list(
    fit        = fit,
    perf       = perf,
    plots      = list(
      resid_vs_fitted = p_resid_vs_fitted,
      qq_plot         = p_qq,
      scale_location  = p_scale_location
    ),
    robust_vcov  = robust_vcov,
    robust_coefs = robust_coefs
  )
}

# MONTE CARLO OLS EXPERIMENT

simulate_ols_experiment <- function(X,
                                    beta_true,
                                    sigma_u,
                                    n_rep = 100,
                                    dataset_name = "dataset") {
  n <- nrow(X)
  
  if (!all(c("X1", "X2", "X3") %in% names(X))) {
    stop("X must contain columns X1, X2, X3.")
  }
  
  # True linear predictor
  eta <- beta_true["(Intercept)"] +
    beta_true["X1"] * X$X1 +
    beta_true["X2"] * X$X2 +
    beta_true["X3"] * X$X3
  
  # Error terms: n x n_rep
  U <- matrix(
    rnorm(n * n_rep, mean = 0, sd = sigma_u),
    nrow = n,
    ncol = n_rep
  )
  
  all_coefs <- list()
  all_perf  <- list()
  first_fit <- NULL
  
  for (r in seq_len(n_rep)) {
    y_r <- eta + U[, r]
    df_r <- data.frame(y = y_r, X)
    
    fit_r <- lm(y ~ X1 + X2 + X3, data = df_r)
    if (r == 1) {
      first_fit <- fit_r
    }
    
    s_r <- summary(fit_r)
    
    coefs_r <- tidy(fit_r) %>%
      mutate(rep = r, dataset = dataset_name)
    
    perf_r <- tibble(
      rep     = r,
      dataset = dataset_name,
      r2      = s_r$r.squared,
      adj_r2  = s_r$adj.r.squared,
      sigma   = s_r$sigma
    )
    
    all_coefs[[r]] <- coefs_r
    all_perf[[r]]  <- perf_r
  }
  
  coefs_tbl <- bind_rows(all_coefs)
  perf_tbl  <- bind_rows(all_perf)
  
  # Coefficient distribution summary: bias vs true beta
  coef_summary <- coefs_tbl %>%
    group_by(term) %>%
    reframe(
      true_beta = beta_true[term][1],
      mean_est  = mean(estimate),
      sd_est    = sd(estimate),
      bias      = mean_est - true_beta
    )
  
  cat("\n========================================\n")
  cat("Monte Carlo coefficient summary for:", dataset_name, "\n")
  cat("========================================\n\n")
  print(coef_summary)
  
  cat("\n--- Average model performance over replications (", dataset_name, ") ---\n", sep = "")
  print(
    perf_tbl %>%
      summarise(
        mean_r2     = mean(r2),
        mean_adj_r2 = mean(adj_r2),
        mean_sigma  = mean(sigma)
      )
  )
  
  # Full diagnostics for the first replication
  diag_first <- run_single_ols_diagnostics(
    y            = eta + U[, 1],
    X            = X,
    dataset_name = paste0(dataset_name, " - first replication")
  )
  
  list(
    dataset_name = dataset_name,
    beta_true    = beta_true,
    coefs        = coefs_tbl,
    coef_summary = coef_summary,
    perf         = perf_tbl,
    first_fit    = diag_first$fit,
    first_diag   = diag_first
  )
}

# RUN EXPERIMENTS FOR set_1 AND set_2
res_set1 <- simulate_ols_experiment(
  X           = X1_df,
  beta_true   = beta_true,
  sigma_u     = sigma_u,
  n_rep       = n_rep,
  dataset_name = "set_1"
)

res_set2 <- simulate_ols_experiment(
  X           = X2_df,
  beta_true   = beta_true,
  sigma_u     = sigma_u,
  n_rep       = n_rep,
  dataset_name = "set_2"
)

# EXAMPLES: RESULTS
res_set1$coef_summary          # bias vs true beta (set_1)
res_set1$coefs                 # coefficient paths across replications
res_set1$perf                  # R^2, adj R^2, sigma across replications
res_set1$first_diag$plots$qq_plot

res_set2$coef_summary         
res_set2$first_diag$plots$resid_vs_fitted
