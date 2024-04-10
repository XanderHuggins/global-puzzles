
hypol = terra::rast("D:/Geodatabase/Social-data/Hydrosocial-interactions/likely-hp-risk.tif")

hypol_r = terra::resample(x = hypol,
                          y = WGS84_areaRaster(5/60) |> rast(),
                          method = "near", 
                          filename = here("data/input_rast/hypol_interaction.tif"),
                          overwrite = T)
