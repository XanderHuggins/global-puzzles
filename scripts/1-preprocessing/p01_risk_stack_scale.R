
# Create raster stack of all Anthro risk datasets, and apply common land mask

risk_stack = c(terra::rast(here("data/input_rast/subsidence.tif")),
               terra::rast(here("data/input_rast/grace_clsm_da_gws.tif")),
               terra::rast(here("data/input_rast/mswep-daily-freq-change-2010s-to-1980s-over-10mm-d.tif")),
               terra::rast(here("data/input_rast/lu_change_ratio_v2.tif")),
               terra::rast(here("data/input_rast/conservation_priority.tif")),
               terra::rast(here("data/input_rast/yield_gap.tif")),
               terra::rast(here("data/input_rast/hypol_interaction.tif")),
               terra::rast(here("data/input_rast/gdi.tif")),
               terra::rast(here("data/input_rast/water_crowding_change.tif")))
names(risk_stack) = c('gsh', 'gws', 'precip', 'luchange', 'conspri', 'yield_gap', 'hypol', 'gdi', 'crowding')

# add area layer 
risk_stack$area = WGS84_areaRaster(5/60) |> terra::rast()

# keep extent from groundwaterscapes study: 
gscapes = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/input-data-stack-norm.tif")
gscapes = gscapes$id
mask_dat = gscapes
mask_dat[mask_dat >=1] = 1

# mask_dat = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/archived_data/project_mask.tif") 
# # remove Greenland from analysis -- which is masked out of the hypol data
# mask_dat[is.na(risk_stack$hypol)] = NA
risk_stack = terra::mask(x = risk_stack, mask = mask_dat)
risk_stack_copy = risk_stack

# add cell id 
id_rast = gscapes$id
# id_rast[] = 1:ncell(mask_dat)
# id_rast = terra::mask(x = id_rast, mask = mask_dat)
risk_stack$id = id_rast

risk_stack[is.nan(risk_stack)] = NA

writeRaster(x = risk_stack,
            filename = here("data/01_risk_stack_raw_data.tif"),
            overwrite = T)

for (i in 1:9) {
  risk_stack[[i]] = raster_scale(risk_stack[[i]], exception.val = -999)  # -999 is same as ignore
  message(i)
}

risk_stack$area = WGS84_areaRaster(5/60) |> terra::rast()

# # ok so land subsidence doesn't look positiviely biased here, from the scaled raster
# plot(risk_stack[[1]])
# ggplot(data.frame(x = risk_stack[[1]] |> as_tibble() |> drop_na() |> pull(gsh)), aes(x)) +
#   geom_histogram(bins = 30, fill = "skyblue", color = "white") +
#   labs(title = "Histogram of my_vector", x = "Values", y = "Count") +
#   theme_minimal()

writeRaster(x = risk_stack,
            filename = here("data/01_risk_stack_scaled_alldata_noNAtrim.tif"),
            overwrite = T)


risk_stack_df = risk_stack |> as_tibble()
write_rds(risk_stack_df,
          file = here("data/01_risk_stack_scaled_alldata_noNAtrim.rds"))


### ================================================================= 
## identify imputed scaled values for NA layers with physical meaning 
### ================================================================= 

### #############
### for yield gap/ag intensification
df_temp = c(risk_stack_copy$yield_gap, risk_stack$yield_gap)
names(df_temp) = c('raw', 'scaled')
df_temp = df_temp |> as_tibble() |> dplyr::filter(raw >= 0) 
lowval = df_temp$raw[which.min(df_temp$raw)]

df_temp |> dplyr::filter(raw == lowval) |> pull(scaled) |> summary()
#> no yield gap --> set to -2


### #############
### for land use change
df_temp = c(risk_stack_copy$luchange, risk_stack$luchange)
names(df_temp) = c('raw', 'scaled')
df_temp = df_temp |> as_tibble() |> dplyr::filter(raw >= 0) 
# lowval = df_temp$raw[which.min(df_temp$raw)]
# not interested in lowest value, but where lu change change is 0 (i.e. rel change is 1)

df_temp |> dplyr::filter(raw == 1) |> pull(scaled) |> summary()
#> no land use change --> set to -0.2872 


### #############
### for water crowding
df_temp = c(risk_stack_copy$crowding, risk_stack$crowding)
names(df_temp) = c('raw', 'scaled')
df_temp = df_temp |> as_tibble() |> dplyr::filter(raw >= 0) 
# not interested in lowest value, but where pop change is 0 (i.e. rel change is 1)

df_temp |> dplyr::filter(raw == 1) |> pull(scaled) |> summary()
#> no land use change --> set to -0.367 