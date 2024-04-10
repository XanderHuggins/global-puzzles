
# calculate grid-cell level water crowding

runoff_grids = terra::rast("D:/Geodatabase/Streamflow/GRUN-ensemble/G-RUN_ENSEMBLE_MMM.nc")

# calculate average runoff over decade of 2010-2019 (October 2009 to September 2019)
runoff_grids = runoff_grids[[1300:1419]] # 120 months
runoff_grids = mean(c(runoff_grids))
plot(runoff_grids)

# import population counts
pop_2020 = terra::rast("D:/Geodatabase/Social-data/Population/Wang_2022/SPP3/SSP3_2020.tif")
pop_2050 = terra::rast("D:/Geodatabase/Social-data/Population/Wang_2022/SPP3/SSP3_2050.tif")

# aggregate to same resolution as runoff
pop_2020 = terra::aggregate(x = pop_2020, fact = 60, fun = "sum", cores = 6)
pop_2050 = terra::aggregate(x = pop_2050, fact = 60, fun = "sum", cores = 6)

pop_2020 = terra::resample(x = pop_2020, y = runoff_grids, method = "near")
pop_2050 = terra::resample(x = pop_2050, y = runoff_grids, method = "near")


future_steamflow = terra::rast("C:/Users/xande/Downloads/Zhang_SourceData_Fig4.tif")


# calculate water crowding per grid cell (people per runoff)
crowding_2020 = pop_2020/runoff_grids
crowding_2050 = pop_2050/runoff_grids

# ratio of 2050 water crowding to 2020 water crowding
crowding_change_ratio = crowding_2050 / crowding_2020


crowding_change_ratio = terra::resample(x = crowding_change_ratio, 
                                        y = WGS84_areaRaster(5/60) |> rast(),
                                        method = "near",
                                        filename = here("data/input_rast/water_crowding_change.tif"),
                                        overwrite = T)