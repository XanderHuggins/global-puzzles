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



############## -- / option 2: change in 10mm/day precip exceedance
precip_80s_l = list.files("D:/Geodatabase/Precipitation/MSWEP/Daily_1980s/", pattern = ".nc$", full.names = T)

# we are interested in daily precip >10mm
rcl.m = c(-Inf, 10, 0,
          10, Inf, 1) |> matrix(ncol = 3, byrow = TRUE)

precip_80s_r = rast(precip_80s_l[1])
precip_80s_r = terra::classify(x= precip_80s_r, rcl = rcl.m, include.lowest = T)

for (ii in 2:length(precip_80s_l)) {
  # ii = 2
  
  precip_80s_r_temp = rast(precip_80s_l[ii])
  precip_80s_r_temp = terra::classify(x= precip_80s_r_temp, rcl = rcl.m, include.lowest = T)
  
  precip_80s_r = precip_80s_r + precip_80s_r_temp
  
  precip_80s_r_temp = NULL
  message("iters ", 100*ii/length(precip_80s_l), "% done")
}

writeRaster(precip_80s_r, "D:/Geodatabase/Precipitation/MSWEP/mswep-1980-1989-precip-daily-count-over-10mm-d.tif", overwrite = T)

precip_80s_r = precip_80s_r/length(precip_80s_l)
writeRaster(precip_80s_r, "D:/Geodatabase/Precipitation/MSWEP/mswep-1980-1989-precip-daily-freq-over-10mm-d.tif", overwrite = T)

# now repeat for the 2010 decade
precip_10s_l = list.files("D:/Geodatabase/Precipitation/MSWEP/Daily_2010s/", pattern = ".nc$", full.names = T)

precip_10s_r = rast(precip_10s_l[1])
precip_10s_r = terra::classify(x= precip_10s_r, rcl = rcl.m, include.lowest = T)

for (ii in 2:length(precip_10s_l)) {
  # ii = 3
  
  precip_10s_r_temp = rast(precip_10s_l[ii])
  precip_10s_r_temp = terra::classify(x= precip_10s_r_temp, rcl = rcl.m, include.lowest = T)
  
  precip_10s_r = precip_10s_r + precip_10s_r_temp
  
  precip_10s_r_temp = NULL
  message("iters ", 100*ii/length(precip_10s_l), "% done")
}

writeRaster(precip_10s_r, "D:/Geodatabase/Precipitation/MSWEP/mswep-2010-2019-precip-daily-count-over-10mm-d.tif", overwrite = T)

precip_10s_r = precip_10s_r/length(precip_10s_l)
writeRaster(precip_10s_r, "D:/Geodatabase/Precipitation/MSWEP/mswep-2010-2019-precip-daily-freq-over-10mm-d.tif", overwrite = T)


# calculate relative change in 10mm precipitation days across decades
rel_change = precip_10s_r / precip_80s_r
writeRaster(rel_change, "D:/Geodatabase/Precipitation/MSWEP/mswep-daily-freq-change-2010s-to-1980s-over-10mm-d.tif", overwrite = T)

rel_change[rel_change>2] = 2
rel_change[precip_10s_r > 0 & precip_80s_r == 0] = 2

rel_change_r = terra::resample(x = rel_change, y = WGS84_areaRaster(5/60) |> rast(), method = "bilinear")
plot(rel_change)

writeRaster(rel_change_r, here("data/input_rast/mswep-daily-freq-change-2010s-to-1980s-over-10mm-d.tif"), overwrite = T)

temp_r = rast( here("data/input_rast/mswep-daily-freq-change-2010s-to-1980s-over-10mm-d.tif"))