# Aim: get and summarise cycle counter data for Edinburgh

library(tidyverse)
cycle_count_data_original = read_csv(
  "https://github.com/ITSLeeds/od/releases/download/v0.3.1/City.of.Edinburgh.Council_Edinburgh_2020-03-01_2022-01-10.csv"
)
summary(cycle_count_data_original$endTime)#
# Min.               1st Qu.                Median                  Mean               3rd Qu.                  Max. 
# "2020-03-02 00:00:00" "2020-08-17 00:00:00" "2021-02-01 12:00:00" "2021-02-01 13:44:41" "2021-07-20 00:00:00" "2022-01-05 00:00:00" 


cycle_counts = cycle_count_data_original %>% 
  group_by(longitude, latitude) %>% 
  summarise(
    n = n(),
    count = sum(count),
    mean_count = count / n
  )

nrow(cycle_counts) # 59 of them...

cycle_counts %>% 
  ggplot() +
  geom_point(aes(count, mean_count)) # 100% correlation

cycle_counts_sf = cycle_counts %>% 
  sf::st_as_sf(., coords = c("longitude", "latitude"), crs = 4326)
sf::st_write(cycle_counts_sf, "cycle_counts_59_edinburgh_summary_2020-03-02-2022-01-05.geojson")
piggyback::pb_upload("cycle_counts_59_edinburgh_summary_2020-03-02-2022-01-05.geojson")
piggyback::pb_download_url("cycle_counts_59_edinburgh_summary_2020-03-02-2022-01-05.geojson")

mapview::mapview(cycle_counts_sf)
