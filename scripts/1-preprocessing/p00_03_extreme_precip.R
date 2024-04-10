helps to affirm and symbolize the new approach to groundwater sustainability 


# climate extremes / extreme precipitation

precip = terra::rast("D:/Geodatabase/Precipitation/Extreme_events/Gruendemann_2022/difT10_MEV_weighted-mean-med-ipr_all_ssps.nc")

# precip_t10 = (precip$mean_ssp585)
precip_t10 = (precip$mean_ssp370)

# shit from 0 to 360 to -180 to 180

precip_t10 = precip_t10 |> as.matrix(wide = T)

precip_L = precip_t10[,721:1440]
precip_R = precip_t10[,1:720]
precip_rearranged = cbind(precip_L, precip_R) |> rast()

plot(precip_rearranged)
crs(precip_rearranged) = crs(precip)
ext(precip_rearranged) = c(-180, 180, -90, 90)
names(precip_rearranged) = "t10_rel_change"

precip_extreme_t10_5arcmin = terra::resample(x = precip_rearranged,
                                             y = WGS84_areaRaster(5/60) |> rast(),
                                             method = "near",
                                             filename = here("data/input_rast/extreme_t10_relchange.tif"),
                                             overwrite = TRUE)
