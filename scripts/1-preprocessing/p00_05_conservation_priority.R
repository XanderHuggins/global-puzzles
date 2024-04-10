
cons_pri = terra::rast("D:/Geodatabase/Ecological/Jung-conservation-priority/BiodiversityCarbonWater/10km/minshort_speciestargets_biome.id_withPA_carbon__water__esh10km_repruns10_ranked.tif")

cons_pri = terra::project(x = cons_pri, 
                          y = WGS84_areaRaster(5/60) |> rast(),
                          method = "bilinear",
                          filename = here("data/input_rast/conservation_priority.tif"),
                          overwrite = TRUE)
