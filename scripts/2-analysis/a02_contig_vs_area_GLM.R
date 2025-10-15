### ---------------------\\ 
# Script objective:
# Plot relationship between GML area and mean class contiguity (area weighted patch metric)
### ---------------------\\
library(here); source(here(("on_button.R")))
###
library(landscapemetrics)

rs = terra::rast(here("data/groundwater-PROBLEMSCAPES-with-mi2.tif"))
values(rs) = as.integer(values(rs))

gs = archs = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/groundwaterscapes-currentiter.tif")
values(gs) = as.integer(values(gs))

GMLs = (gs * 100) + (rs)

GML_df = GMLs[] |> unique() |> as.vector() |> na.omit() 
res_df = data.frame(GML_id = GML_df, contig = rep(NA), area = rep(NA))

area_ras = WGS84_areaRaster(5/60) |> rast()

for (ii in 1:length(GML_df)) {
  
  # ii = 1
  GML_ii = rast(GMLs) 
  GML_ii[GMLs[] == GML_df[ii]] = 1
  GML_ii[GMLs[] != GML_df[ii]] = NA
  
  patch_contig = lsm_p_contig(GML_ii)
  patch_size = lsm_p_area(GML_ii)
  
  res_df$contig[ii] = weighted.mean(x = patch_contig$value, w = patch_size$value)
  
  GML_area = GML_ii * area_ras
  res_df$area[ii] = sum(GML_area[], na.rm = T)
  
  message(ii/length(GML_df))
  
}

res_df$areaf = round(100 * res_df$area / sum(res_df$area), 2)

ggplot() + 
  annotate("rect",
           xmin = 0, xmax = 1,     # x range
           ymin = -Inf, ymax = Inf,  # full y range
           fill = "grey80", alpha = 0.5) + 
  geom_point(data = res_df, aes(x = log10(areaf), y = contig), shape = 21, size = 8, fill = "black", alpha = 0.8) +
  # geom_text(data = res_df |> filter(areaf > 0.1), aes(x = log10(areaf), y = contig, label = GML_id), colour = "white", size = 2)+
  coord_cartesian(xlim=c(-1, 1), ylim = c(0, 1), expand = 0) +
  my_theme + 
  # scale_x_continuous(breaks = seq(1, 11, by = 1)) +
  # coord_cartesian(xlim = c(1, 11), ylim = c(0, 0.9)) +
  scale_x_continuous(
    limits = c(log10(0.1), log10(10)),
    breaks = log10(c(0.1, 0.5, 1, 5, 10))
  ) +
  theme(axis.line = element_line(size = 1), 
        panel.grid.major = element_line(),
        axis.text = element_text(size=16),
        axis.title = element_blank()) 

ggsave(plot = last_plot(), filename = here("plots/GSPuzzles_area_contiguity.png"),
       height = 10, width = 15, units = "cm", dpi = 400)


large_GML = res_df |> filter(areaf > 1) 

large_GML$areaf |> sum()

# import population data
popdat = terra::rast("D:/Geodatabase/Social-data/Population/Wang_2022/SPP3/SSP3_2020.tif")
popdat = terra::aggregate(x = popdat, fact = 10, fun = "sum")
popdat = terra::extend(x = popdat, y = GMLs, snap = "near")
ext(popdat) = round(ext(popdat), 2)
names(popdat) = "pop"
sum(popdat[], na.rm = T)/1e9

popfrac = rast(GMLs)
popfrac[GMLs[] %in% large_GML$GML_id] = 1

popfrac = popfrac * popdat

sum(popfrac[], na.rm = T) / sum(popdat[], na.rm = T)
