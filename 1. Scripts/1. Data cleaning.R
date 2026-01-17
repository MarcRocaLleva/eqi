
# Run libraries

source("1. Scripts/0. Libs.R")

# Import dataset

eqi_raw <- read_csv("3. Data/eqi_ind_24.csv")


eqi <- eqi_raw %>% 
  clean_names() %>% 
  select(
    country, starts_with("nuts"),
    # Demographics
    gender = d1, age = d2, education = d3,
    education_recoded = d3recode, hh_income = d4, hh_income_recoded = recoded4,
    occupation_sector = d5a, occupation_detail = d5b,
    population = d9,
    # Survey questions (pe = public education)
    pe_quality = q4,
    pe_special_advantages = q7, # certain people are given special advantages
    pe_equality = q10,
    pe_corruption = q14,
    pe_gift_asked = q18_1,
    pe_gift_given = q19_1,
    # Weights
    dweight, # compensate for certain people having a higher or lower likelihood of being surveyed
    pweight # adjust for a country’s proportion in the sample relative to its actual population of
            # the total population of all countries in the survey
  ) %>% 
  mutate(education_number = case_when(
    education == "Elementary (primary) school or less (no diploma)" ~ 1,
    education == "High (secondary) school (but did not graduated from it)" ~ 2,
    education == "Graduation from high (secondary) school"  ~ 3,
    education == "Graduation from college, university or other third-level institute" ~ 4,
    education == "Post-graduate degree (Masters, PHD) beyond your initial college degree" ~ 5)) %>% 
  relocate(education_number, .after = education)


write_parquet(eqi, "3. Data/eqi_clean")


