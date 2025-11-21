# Advanced Econometric and Simulation Analysis

This folder contains a cohesive group of R scripts focused on evaluating regression model reliability using simulated, correlated, and non-normal data structures.
The work highlights applied model diagnostics, reproducible simulation workflows, and statistical reasoning that are essential in data-driven analytical roles.

Beyond the technical implementation, each script demonstrates how modeling assumptions behave under realistic data conditions commonly seen in product analytics, experimentation, and insights works.

---

## 1. Monte Carlo OLS Simulation

**File:** `Monte_Carlo_Simulation.R`

This script runs a full Monte Carlo experiment for a known linear Data Generating Process:

**Y = 3 + 1·X1 + 1·X2 − 1·X3 + u**, where **u ~ N(0, 40)**.

### Key Deliverables

* Repeated sampling with 100 synthetic datasets
* Coefficient tracking vs true parameters
* Campling variability and estimator behavior
* Mean R², adjusted R², and residual variance summaries
* A full diagnostic suite on one representative replication:

  * Breusch–Pagan heteroskedasticity test
  * Robust HC1 standard errors
  * Multicollinearity via VIF
  * QQ plot, scale-location, and residual–fitted visuals

This analysis shows the ability to evaluate how stable and trustworthy regression effects remain under repeated sampling.

---

## 2. Regression with Correlated and Non-Normal Predictors

**File:** `Advanced_Regression_Analysis.R`

This script intentionally constructs predictors that break standard OLS assumptions.
It uses:

* **LKJ correlation matrices** to impose structured predictor correlation
* **PearsonDS transformations** to define skewness and kurtosis
* Dataset generation based on random moment specifications
* Transformed features via **qpearson**

### Diagnostic Focus

* VIF analysis to quantify multicollinearity
* Shapiro–Wilk tests for residual normality
* regression coefficient evaluation and significance checks
* pairs.panels for exploratory structure analysis
* model fit comparison across train/test splits

This workflow illustrates how regression performance shifts when predictors are correlated, skewed, or heavy-tailed, and how diagnostics can detect instability in estimates.

---

## 3. Non-Normal Distribution Simulation and Comparison

**File:** `Distribution_Sim_Analysis.R`

This script constructs multiple distributions based on explicit moment conditions, including:

* platykurtic samples
* leptokurtic samples
* skewed samples
* a normal baseline

### Analysis Outputs

* density curve comparisons
* histograms with mean and median overlays
* quantile tables
* skewness and kurtosis metrics
* interactive Plotly visualizations

The goal is to show how tail behavior and asymmetry affect summary statistics and the interpretation of real-world metrics that rarely follow normality.

---

## Skills Demonstrated

* regression modeling and diagnostics
* Monte Carlo simulation design
* generation of correlated data (LKJ)
* non-Gaussian transformation (PearsonDS)
* assumption testing (normality, homoskedasticity, multicollinearity)
* robust inference (HC1)
* reproducible analytic scripting
* visualization with ggplot2 and plotly

---

## Requirements

Packages used across scripts include:

`tidyverse`, `data.table`, `PearsonDS`, `moments`, `car`, `lmtest`, `sandwich`, `broom`, `rethinking`, `plotly`.

All data is simulated or read from local files expected under `data/`.

---

## Summary

Together, these scripts provide a practical demonstration of how regression models behave under controlled but challenging data environments.
The analyses focus on reliability, stability, and diagnostic reasoning — key elements in applied analytics, experimentation, and quantitative insight work.
