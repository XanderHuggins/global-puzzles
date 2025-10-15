### ---------------------\\ 
# Script objective:
# Calculate coverage rates of input datasets
### ---------------------\\
library(here); source(here(("on_button.R")))
###

# import input data stack
in_r = terra::rast(here("data/01_risk_stack_scaled_alldata_noNAtrim.tif"))
id_r = in_r[[11]]
in_r = in_r[[1:9]]
in_r[in_r > -Inf] = 1
in_r[in_r != 1] = 0
in_r[is.na(in_r)] = 0

sum_r = sum(in_r)

# bring in problemscapes raster
ps = terra::rast(here("data/groundwater-RISK-TYPES-current-iter.tif"))
sum_r[is.na(ps)] = NA
rate_r = sum_r/9

threshold = 0.8
low_dat = terra::ifel(rate_r < threshold, 1, 0)
plot(low_dat)

# calculate percentage of surface area based on data coverage
cov_df = c(sum_r, terra::rast(WGS84_areaRaster(5/60))) |> 
  as_tibble() |> 
  magrittr::set_colnames(c('sum', 'area')) |> 
  dplyr::filter(sum > 0) |> 
  group_by(sum) |> 
  summarise(area = sum(area)) |> 
  mutate(areaf = area/sum(area, na.rm = T))


writeRaster(x = sum_r, filename = here("data/input_data_coverage_sum.tif"), overwrite = T)
writeRaster(x = rate_r, filename = here("data/input_data_coverage_rate.tif"), overwrite = T)