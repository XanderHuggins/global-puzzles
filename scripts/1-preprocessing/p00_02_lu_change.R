
# prepare land use change data

# 2015 data
lu_2015 = terra::rast("D:/Geodatabase/Land-use/Winkler_2021/hildap_vGLOB-1.0_geotiff_wgs84/hildap_GLOB-v1.0_lulc-states/hilda_plus_2015_states_GLOB-v1-0_base-map_wgs84-nn.tif")

# 1960 data
lu_1960 = terra::rast("D:/Geodatabase/Land-use/Winkler_2021/hildap_vGLOB-1.0_geotiff_wgs84/hildap_GLOB-v1.0_lulc-states/hilda_plus_1960_states_GLOB-v1-0_wgs84-nn.tif")

# grid cell area
cell_area = terra::cellSize(x = lu_2015)

# reclassfication to binary of human modified and not
reclass_matrix = data.frame(
  from = c(0, 11, 22, 33, 44, 55, 66, 77),
  to = c(0, 1, 1, 1, 0, 0, 0, 0)
) |> 
  as.matrix()

# convert both layers to binary
lu_2015_binary = terra::classify(x = lu_2015, rcl = reclass_matrix)
lu_1960_binary = terra::classify(x = lu_1960, rcl = reclass_matrix)

lu_anthro_area_2015 = lu_2015_binary * cell_area
lu_anthro_area_1960 = lu_1960_binary * cell_area

# as default resolution of lu data is not integer factor of 5 arcmin, aggregate to nearest factor 
lu_2015_aggregate = terra::aggregate(x = lu_anthro_area_2015, fact = 8, fun = "sum")
lu_1960_aggregate = terra::aggregate(x = lu_anthro_area_1960, fact = 8, fun = "sum")

# lu area change ratio
lu_change_ratio = lu_2015_aggregate / lu_1960_aggregate

lu_change_ratio_5arcmin = terra::resample(x = lu_change_ratio,
                                          y = WGS84_areaRaster(5/60) |> rast(),
                                          method = "bilinear",
                                          filename = here("data/input_rast/lu_change_ratio.tif"),
                                          overwrite = T)