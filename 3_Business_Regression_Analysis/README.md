# Employee Satisfaction Regression Analysis

This project explores how key workplace variables relate to employee satisfaction using linear regression and structured diagnostic workflows.
The analysis focuses on building an interpretable model, validating its assumptions, and evaluating how well it explains variation in satisfaction scores.
The workflow reflects practical skills relevant to data analysis, insights generation, and modeling for business decision-making.

---

## Overview

**File:** `Employee_Satisfac_Regression.R`
**Goal:** Identify which organizational factors most strongly predict employee satisfaction and assess the reliability of the resulting regression model.

The dataset includes commonly observed workplace metrics such as workload, supervisor quality, compensation, job autonomy, and team dynamics.
The script transforms raw data, fits an OLS model, and evaluates model performance through statistical diagnostics and exploratory analysis.

---

## Modeling Workflow

### 1. Data Preparation

* Cleaning and formatting raw inputs
* Handling missing or inconsistent values
* Converting categorical factors where applicable
* Normalizing selected variables for interpretability

The goal is to produce a clean analytical dataset suitable for regression.

### 2. Exploratory Analysis

* Distribution checks
* Pairwise correlations
* Outlier identification
* Visualization of variable relationships

These steps guide the model specification and highlight important structural patterns in the data.

### 3. Regression Model

The script fits a multiple linear regression predicting **Employee Satisfaction** from workplace and management-related inputs.

Outputs include:

* coefficient estimates and significance levels
* explained variance (R², adjusted R²)
* effect size interpretation
* direction and relative strength of predictors

This provides a structured view of which factors meaningfully contribute to satisfaction levels.

---

## Diagnostic Evaluation

To ensure the model’s stability and reliability, the script performs a full set of regression diagnostics:

* **Normality of residuals** (QQ plot, Shapiro–Wilk test)
* **Heteroskedasticity checks** (Breusch–Pagan)
* **Multicollinearity assessment** (VIF)
* **Residual structure analysis** (residual vs fitted, scale–location)
* **Influence metrics** (Cook’s distance)

These steps identify potential issues that may affect interpretation or predictive accuracy.

---

## Key Insights Generated

While results depend on the specific dataset, the workflow enables identification of:

* the strongest drivers of employee satisfaction
* variables with unstable or unreliable effects
* potential structural issues in workplace metrics
* how organizational factors interact to shape employee sentiment

The emphasis is on producing interpretable findings that translate into actionable insights for HR, operations, or organizational strategy.

---

## Skills Demonstrated

* regression modeling and coefficient interpretation
* exploratory data analysis and visualization
* assumption testing and diagnostic workflow
* business-oriented insight generation
* reproducible analytic scripting in R

---

## Requirements

The script uses common R packages including:

`tidyverse`, `car`, `lmtest`, `sandwich`, `broom`, `ggplot2`.

Place any external files in a local `data/` directory or adjust the pathing as_needed.

---

## Summary

This project presents a clear and interpretable regression-based approach to understanding employee satisfaction drivers.
The analysis demonstrates practical modeling skills, diagnostic reasoning, and insight-focused reporting suitable for organizational analytics and data-driven decision-making.
