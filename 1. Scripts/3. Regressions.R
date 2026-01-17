

# Run libraries

source("1. Scripts/0. Libs.R")


# Import dataset -----

eqi <- read_parquet("3. Data/eqi_clean") %>% 
  mutate(pe_quality = str_extract(pe_quality, "\\d+")) %>% 
  mutate(gender = case_when(
    gender == "Male" ~ 1,
    gender == "Female" ~ 0)) %>% 
  mutate(age = as.numeric(str_sub(age, 1,2))) %>% 
  mutate(pe_quality = as.numeric(pe_quality))



# Regressions ----

## Public_Education_Quality_{i} = education_number_{i} + gender_{i} + age_{i} + nuts3_code_{i}

model1 <- feols(pe_quality ~ education_number | nuts3_code,
   data = eqi)


model2 <- feols(pe_quality ~ education_number + gender | nuts3_code,
                data = eqi)

model3 <- feols(pe_quality ~ education_number + gender + age | nuts3_code,
                data = eqi)

modelsummary::modelsummary(
  list(model1, model2, model3),
             title = "Outcome variable: Public Education Quality (1-10)",
  stars = T,
  gof_omit = "AIC|BIC|Log.Lik.|R2 Pseudo")

