
# Prepare the groundwater depletion data at 5 armin resolution
gws = terra::rast("D:/Geodatabase/GRACE/JPL_mascon/gws_trends_200302_202302_downscaled_ccr.nc")
# gws = terra::rast("D:/Geodatabase/GRACE/JPL_mascon/gws_nil_trends_jpl_200302_2023021_ccr_0.5x0.5.nc")

# convert gws to 
gws = gws * 1e12 # Gt to kg 
gws = gws / 1e3  # kg to m3 using using assumed density of 1000kg/m3
cellsize = terra::cellSize(gws, unit = "m")
gws = gws/cellsize # units of m/yr

gws_resampled = terra::resample(x = gws, 
                                y = WGS84_areaRaster(5/60) |> rast(),
                                method = "near")

names(gws_resampled) = "gws_trend_m.yr"

writeRaster(gws_resampled, 
            filename = here("data/input_rast/grace_gws.tif"),
            overwrite = T)

## as another alternative, take trend data from GRACE-DA CLSM product
gws = terra::rast("D:/Geodatabase/Groundwater/GLDAS-CLSM/Preprocessing/gldas-clsm-gws-trend-2003-2021.tif")

gws_resampled = terra::resample(x = gws, 
                                y = WGS84_areaRaster(5/60) |> rast(),
                                method = "near")

names(gws_resampled) = "gws_trend_m.yr"

writeRaster(gws_resampled, 
            filename = here("data/input_rast/grace_clsm_da_gws.tif"),
            overwrite = T)