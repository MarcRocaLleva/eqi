

# Run libraries

source("1. Scripts/0. Libs.R")

# Import dataset -----

eqi <- read_parquet("3. Data/eqi_clean") 

# Clean dataset -----


education <- eqi %>% 
  group_by(nuts1_name, nuts2_name, nuts3_name, nuts3_code) %>% 
  summarise(education = mean(education_number)) %>% 
  ungroup %>% 
  # Bin education
  mutate(
    education_bin = cut(
      education,
      breaks = c(0, 1, 2, 3, 4,5),
      include.lowest = TRUE
    )
  )

# NUTS coordinates data ----

nuts <- read_sf("3. Data/NUTS_RG_20M_2024_4326.geojson") %>% 
  clean_names() %>% 
  # Obtain latitude and altitude
  mutate(lat = st_coordinates(st_centroid(geometry))[, 1]) %>% 
  mutate(alt = st_coordinates(st_centroid(geometry))[, 2])


# Merge and export Education and NUTS ----


education_nuts <- nuts %>%
  left_join(education %>% 
              select(nuts_id = nuts3_code,
                     education, education_bin))



# Visualise data -----

education_nuts %>% 
  filter(levl_code == 3) %>% 
  filter(alt > 35) %>%
  filter(alt < 70) %>%
  filter(lat > -10) %>%
  drop_na(education) %>%
  ggplot() +
  geom_sf(aes(fill = education)) + 
  theme_void() +
  scale_fill_viridis_c(option = "viridis", direction = -1) +
  labs(fill = "Education")
  # scale_fill_distiller(palette = "PuOr", direction = 1)
  # theme(legend.position = "bottom")


ggsave("2. Outputs/Europe_Education_NUTS_RG.jpeg", height = 5, width = 5)

