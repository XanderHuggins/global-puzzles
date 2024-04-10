
# Prepare the groundwater depletion data at 5 armin resolution
gsh = terra::rast("D:/Geodatabase/Subsidence/GSH.tif")
gsh[is.na(gsh)] = 0 # else na.rm border conditions might affect coastlines

gsh_resampled = terra::resample(x = gsh, 
                                y = WGS84_areaRaster(5/60) |> rast(),
                                method = "max")

names(gsh_resampled) = "gsh"

writeRaster(gsh_resampled, 
            filename = here("data/input_rast/subsidence.tif"),
            overwrite = T)
