

# geneder development inequalities

gdl_shps = terra::vect("D:/Geodatabase/Admin-ocean-boundaries/Global_Data_Lab_borders/GDL Shapefiles V6.2 large.shp")

# GDI
gdi = readr::read_csv("D:/Geodatabase/Social-data/Gender_inequality/GDL-Subnational-GDI-data.csv")

gdl_shps = merge(x = gdl_shps, by.x = "gdlcode",
                 y = gdi, by.y = "GDLCODE")

names(gdl_shps)

gdi_r = terra::rasterize(x = gdl_shps, 
                         y = WGS84_areaRaster(5/60) |> rast(),
                         field = "2021",
                         touches = TRUE,
                         fun = "max",
                         filename = here("data/input_rast/gdi.tif"),
                         overwrite = T)
