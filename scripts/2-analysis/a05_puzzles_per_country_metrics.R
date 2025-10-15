### ---------------------\\ 
# Script objective:
# Calculate landscape metrics for the puzzles within all countries of the world
### ---------------------\\
library(here); source(here(("on_button.R")))
###

# develop puzzles and import other layers
rs = terra::rast(here("data/groundwater-PROBLEMSCAPES-with-mi2.tif"))
values(rs) = as.integer(values(rs))

gs = archs = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/groundwaterscapes-currentiter.tif")
values(gs) = as.integer(values(gs))

PUZZLEs = (gs * 100) + (rs)

country_ID = terra::vect(here("D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries.shp"))
country_ID$id = seq(1:nrow(country_ID))

country_ID_r = terra::rasterize(x = country_ID, y = PUZZLEs, field = "id", touches = TRUE) # rasterize alphebetized whymap order

area = WGS84_areaRaster(5/60) |> rast()


###############
# All landscape metrics
###############

# data frame to hold results
res_df = data.frame(
  id = country_ID$id,
  siei = rep(NA),
  cntg = rep(NA),
  count = rep(NA),
  count_over_1p = rep(NA),
  largest_frac = rep(NA),
  mean_frac = rep(NA),
  country_area = rep(NA)
)

for (i in 1:nrow(res_df)) {
  # i = 1
  temp_Puzzle = PUZZLEs
  temp_Puzzle[country_ID_r != res_df$id[i]] = NA
  temp_Puzzle[is.na(country_ID_r)] = NA # ensure only grids within country borders are assessed
  
  # res_df$siei[i] = lsm_l_siei(landscape = temp_Puzzle, directions = 8) |> pull(value)
  # res_df$cntg[i] = lsm_l_contag(landscape = temp_arch) |> pull(value)
  res_df$count[i] = temp_Puzzle |> as_tibble() |> drop_na() |> unique() |> nrow()
  
  # area approximation of country
  country_area_df = c(area, temp_Puzzle) |> 
    as_tibble() |> drop_na() |> 
    set_colnames(c('area', 'puzzle_id')) |> 
    dplyr::group_by(puzzle_id) |> 
    summarise(puzzle_area = sum(area, na.rm = T))
  
  country_area_df$puzzle_frac = country_area_df$puzzle_area / sum(country_area_df$puzzle_area)
  
  res_df$count_over_1p[i] = country_area_df |> dplyr::filter(puzzle_frac > 0.01) |> nrow()
  
  res_df$largest_frac[i] = max(country_area_df$puzzle_frac)
  res_df$mean_frac[i] = mean(country_area_df$puzzle_frac)
  res_df$country_area[i] = sum(country_area_df$puzzle_area)
  
  message("country ", country_ID$NAME_EN[i], " done... ", i, " out of ", nrow(res_df))
  print(res_df[i,])
  
}

mean(res_df$count)

# keep only countries with areas
keep_df = res_df |> filter(country_area > 0)
summary(keep_df)

# merge with country names
country_ID_names = country_ID |> as_tibble() |> dplyr::select(NAME, id)

keep_df = merge(x= keep_df, y = country_ID_names, by = 'id')

keep_df |> filter(country_area > 1e4) |> summary()
keep_df |> filter(country_area > 1e4) |> view()

keep_df |> filter(country_area > 1e4) |> filter(largest_frac > 0.66)
keep_df |> filter(country_area > 1e4) |> filter(count_over_1p > 30)
