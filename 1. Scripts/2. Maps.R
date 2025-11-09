

# Run libraries

source("1. Scripts/0. Libs.R")

# Import dataset

eqi <- read_parquet("3. Dades/eqi_clean") 


education <- eqi %>% 
  mutate(education = case_when(
    education == "Elementary (primary) school or less (no diploma)" ~ 1,
    education == "High (secondary) school (but did not graduated from it)" ~ 2,
    education == "Graduation from high (secondary) school"  ~ 3,
    education == "Graduation from college, university or other third-level institute" ~ 4,
    education == "Post-graduate degree (Masters, PHD) beyond your initial college degree" ~ 5)) %>% 
  group_by(nuts1_name, nuts2_name, nuts3_name, nuts3_code) %>% 
  summarise(education = mean(education)) %>% 
  ungroup

# NUTS Map

nuts <- read_sf("3. Dades/NUTS_RG_20M_2024_4326.geojson") %>% 
  clean_names() %>% 
  # Obtain latitude and altitude
  mutate(lat = st_coordinates(st_centroid(geometry))[, 1]) %>% 
  mutate(alt = st_coordinates(st_centroid(geometry))[, 2])


nuts %>%
  left_join(education %>% 
              select(nuts_id = nuts3_code,
                     education)) %>% 
  filter(levl_code == 3) %>% 
  filter(alt > 35) %>%
  filter(alt < 70) %>%
  filter(lat > -10) %>%
  drop_na(education) %>%
  ggplot() +
  geom_sf(aes(fill = education)) + 
  theme_void() +
  scale_fill_viridis_c(option = "viridis", direction = -1) +
  # scale_fill_distiller(palette = "PuOr", direction = 1)
  theme(legend.position = "bottom")
