# Breast Cancer Risk Feature Engineering & Tidy Reshaping

This project uses the `BreastCancer` dataset from the `mlbench` package to build a simple, interpretable proxy for cancer risk and to restructure the data into analysis-friendly formats.  
The focus is on feature engineering, group-level summaries, and long/wide data transformations using the tidyverse.

---

## Overview

**File:** `breast_cancer_analysis.R`  
**Dataset:** `BreastCancer` (from `mlbench`)

Columns such as `Cl.thickness`, `Cell.size`, and `Cell.shape` are used to construct a derived risk measure and to compare patterns across benign vs malignant cases.

---

## Workflow

### 1. Data Inspection and Filtering
The script:
- loads the `BreastCancer` dataset  
- inspects variable structure  
- optionally filters “high-risk” rows using thresholds on thickness and cell size  

This step clarifies which variables matter and prepares the dataset for analysis.

---

### 2. Feature Engineering: `cancer_risk`
Several predictors are stored as factors. The script:
- converts factor columns (e.g. `Cl.thickness`, `Cell.size`) to numeric  
- constructs an engineered risk score:

```r
cancer_risk = (Cl.thickness + Cell.size) / 2
````

This creates a simple composite measure that provides an intuitive benchmark for relative cancer risk.

---

### 3. Class-Level Summary

Using `dplyr`, the script:

* groups observations by tumor class (benign vs malignant)
* calculates mean `cancer_risk` for each group

This produces a compact comparison table showing how the engineered score differs across classes.

---

### 4. Long Format Reshaping

To enable flexible comparison across features, the script:

* selects `Class`, `Cl.thickness`, `Cell.size`, and `Cell.shape`
* reshapes the dataset to **long format** using `pivot_longer()`

This results in a standard structure with:

* `feature` (feature name)
* `value` (numeric measurement)

Useful for faceted plots or grouped summaries.

---

### 5. Wide Summary by Feature

The long format is then:

* grouped by `Class` and `feature`
* summarized using the mean
* reshaped into a **wide format** using `pivot_wider()`

Finally, this wide table is joined with the class-level `cancer_risk` summary to combine both engineered and per-feature insights.

---

## Skills Demonstrated

* dataset handling from external packages (`mlbench`)
* factor-to-numeric conversion
* simple but interpretable feature engineering
* grouped summaries using `dplyr`
* long/wide transformations using `tidyr`
* table joining for consolidated reporting

---

## Requirements

The script uses:

`mlbench`, `tidyverse`, `magrittr`, `DT`

All operations run on the packaged dataset without additional files.

---

## Summary

This project provides a clear, concise workflow for turning raw medical predictor fields into engineered features, structured summaries, and tidy reshaped tables.
It demonstrates practical data wrangling skills and interpretable feature construction suitable for downstream reporting or modeling.

```
