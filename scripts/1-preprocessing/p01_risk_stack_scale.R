
# Create raster stack of all Anthro risk datasets, and apply common land mask

risk_stack = c(terra::rast(here("data/input_rast/subsidence.tif")),
               terra::rast(here("data/input_rast/grace_clsm_da_gws.tif")),
               terra::rast(here("data/input_rast/extreme_t10_relchange.tif")),
               terra::rast(here("data/input_rast/lu_change_ratio.tif")),
               terra::rast(here("data/input_rast/conservation_priority.tif")),
               terra::rast(here("data/input_rast/yield_gap.tif")),
               terra::rast(here("data/input_rast/hypol_interaction.tif")),
               terra::rast(here("data/input_rast/gdi.tif")),
               terra::rast(here("data/input_rast/water_crowding_change.tif")))
names(risk_stack) = c('gsh', 'gws', 'precip', 'luchange', 'conspri', 'yield_gap', 'hypol', 'gdi', 'crowding')

# add area layer 
risk_stack$area = WGS84_areaRaster(5/60) |> rast()


# keep extent from groundwaterscapes study: 
gscapes = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/input-data-stack-norm.tif")
gscapes = gscapes$id
mask_dat = gscapes
mask_dat[mask_dat >=1] = 1

# mask_dat = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/archived_data/project_mask.tif") 
# # remove Greenland from analysis -- which is masked out of the hypol data
# mask_dat[is.na(risk_stack$hypol)] = NA
risk_stack = terra::mask(x = risk_stack, mask = mask_dat)

# add cell id 
id_rast = gscapes$id
# id_rast[] = 1:ncell(mask_dat)
# id_rast = terra::mask(x = id_rast, mask = mask_dat)
risk_stack$id = id_rast

writeRaster(x = risk_stack,
            filename = here("data/01_risk_stack_raw_data.tif"),
            overwrite = T)

for (i in 1:9) {
  risk_stack[[i]] = raster_scale(risk_stack[[i]], exception.val = -999)  # -999 is same as ignore
  message(i)
}

risk_stack$area = WGS84_areaRaster(5/60) |> rast()
plot(risk_stack)

writeRaster(x = risk_stack,
            filename = here("data/01_risk_stack_scaled_alldata_noNAtrim.tif"),
            overwrite = T)


risk_stack = risk_stack |> as_tibble()
write_rds(risk_stack,
          file = here("data/01_risk_stack_scaled_alldata_noNAtrim.rds"))