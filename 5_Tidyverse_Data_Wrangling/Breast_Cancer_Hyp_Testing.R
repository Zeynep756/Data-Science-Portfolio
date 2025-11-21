install.packages("DT")
install.packages("magrittr")
install.packages("mlbench")

library(data.table)
library(DT)
library(mlbench)
library(tidyverse)
library(magrittr)


data("BreastCancer")
head(BreastCancer)
BreastCancer %>% select(Cl.thickness, Cell.size, Class)
BreastCancer %>%
  filter(Cl.thickness > 6 & Cell.size > 5)
#filtered based on desired conditions (hypothized these conditions will deliver the high risk rows)
BreastCancer %>% str #The columns I wanted to modify were of factor type, so i changed them into numerical for this operation
#Modified the table to add another column which shows the cancer risk
BreastCancer %<>%
  mutate(cancer_risk  = (as.numeric(as.character(Cl.thickness)) +
                           as.numeric(as.character(Cell.size)))/2)
BreastCancer
bc_1 <- BreastCancer %>%
  group_by(Class) %>%
  summarise(avg_risk_rate = mean(cancer_risk, na.rm=TRUE))
bc_1 #Observe that malignant class has higher cancer risk as we calculated
BreastCancer_Long <- BreastCancer %>%
  select(Class, Cl.thickness, Cell.size, Cell.shape) %>%
  pivot_longer(cols      = -Class,
               names_to  = "feature",
               values_to = "value") 
BreastCancer_Long
#Changing into pivot longer table
BreastCancer_Wide <- BreastCancer_Long %>%
  group_by(Class, feature) %>%
  summarise(
    mean_value = mean(as.numeric(as.character(value)), na.rm = TRUE),
    .groups    = "drop") %>% pivot_wider(
      id_cols    = Class,
      names_from = feature,
      values_from= mean_value)
BreastCancer_Wide
#Changing into pivot wider table
BreastCancer_Wide %>% left_join(bc_1,by="Class")
#Left joined the wide pivot table with bc_1 on "Class"