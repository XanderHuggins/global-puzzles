
# yield gaps across 10 crops

yield_gap = terra::rast("D:/Geodatabase/Agriculture/Gerber_2024_yield_gap/Fig1Data_AllCrops2010YieldGapPercent.tif")

yield_gap_5arcmin = terra::resample(x = yield_gap,
                                    y = WGS84_areaRaster(5/60) |> rast(),
                                    filename = here("data/input_rast/yield_gap.tif"),
                                    overwrite = T)