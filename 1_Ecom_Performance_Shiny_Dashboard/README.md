# E-commerce Category Performance Dashboard

This Shiny app was created to optimize reports for Hepsiburada and reads a matrix-style Google Sheet of 
category/metric/date values, cleans the data, and visualizes performance over time interactively.

### Features
- Google Sheets integration (`googlesheets4`) and synchronization
- Tidyverse data wrangling (`pivot_longer`)
- Two independant date ranges for side-by-side comparison on the same graph
- Ability to visually compare within the same category with different metrics or
  across categories with the same metrics in a time series fashion
- Interactive time series graphs (`plotly`)
- KPI Summary Table
- Downloadable raw data with CSV tables

## How to run
1. Open `app.R` in RStudio.
2. Install required packages (see top of the script).
3. Run `shinyApp(ui, server)` or click "Run App".
