### ---------------------\\ 
# Script objective:
# calculate area and plot heatmap of all GMLs
### ---------------------\\
library(here); source(here(("on_button.R")))
###
library(landscapemetrics)

rs = terra::rast(here("data/groundwater-PROBLEMSCAPES-with-mi2.tif"))
values(rs) = as.integer(values(rs))

gs = archs = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/groundwaterscapes-currentiter.tif")
values(gs) = as.integer(values(gs))

GMLs = (gs * 100) + (rs)

area_df = c(GMLs, WGS84_areaRaster(5/60) |> rast()) |>
  as_tibble() |> drop_na() |> 
  set_colnames(c("GML_id", "area")) |> 
  group_by(GML_id) |> 
  summarise(area = sum(area, na.rm = T))

############################## ///
# various statistical tests
############################## ///

# test if the area distribution of GMLs is log-normal
shapiro.test(log10(area_df$area))

hist(log(area_df$area), probability = TRUE, breaks = 30,
     main = "Log-normal fit to data",
     xlab = "Value", col = "lightgray", border = "white")

qqnorm(log(area_df$area))
qqline(log(area_df$area), col = "red")

summary(area_df$area)
sd(area_df$area)/mean(area_df$area)
############################## ///

plot_df = area_df |> 
  mutate(gs_id = trunc(GML_id/100, 0),
         rs_id = GML_id - 100*gs_id)

############################## ///
# various filtering for MS writing
############################## ///
gs_area_sum = plot_df |> group_by(gs_id) |> summarise(area_GS = sum(area))

plot_df = merge(x = plot_df, y = gs_area_sum, by = "gs_id")

plot_df$areaGS_frac = 100 * plot_df$area / plot_df$area_GS

plot_df |> group_by(gs_id) |> summarise(cov = sd(areaGS_frac)/mean(areaGS_frac))
  
plot_df |> filter(gs_id == 2) |> pull(areaGS_frac) |> summary()

plot_df |> pull(area) |> summary()

plot_df |> filter(areaGS_frac > 20) |> pull(gs_id) |> table()
############################## ///


####################


ggplot(data = plot_df, aes(x = rs_id, y = gs_id, fill = log10(areaGS_frac))) + 
  geom_tile(col = "transparent", height = 0.8) + 
  scale_fill_gradientn(colours = scico(n = 20, palette= "grayC", direction = -1)  , limits = c(-1,1), oob = scales::squish) +
  # scale_fill_viridis_c(limits = c(0, 20), oob = scales::squish, option = "C") +
  # geom_text(data = plot_df, aes(x = rs_id, y = gs_id, label = round(areaGS_frac, 1)), colour = "white", size = 2)+
  # theme_void() +
  coord_cartesian(ylim = c(0.5, 15.5), xlim = c(0.5,18.5), clip = "on", expand = 0) +
  theme(legend.position = "right", panel.border = element_rect(colour = "black", fill = "transparent")) +
  cowplot::theme_nothing()

ggsave(plot = last_plot(),
       file= here("plots/heatmap_gs_PS.png"), bg = "transparent",
       dpi= 400, width = 3.55, height = 4.21, units = "cm")


# look at case where we ignore PS6

plot_df |> 
  dplyr::filter(rs_id != 6) |> 
  group_by(GML_id) |> 
  summarise(area = sum(area, na.rm = T)) |> 
  mutate(gs_id = trunc(GML_id/100, 0),
         rs_id = GML_id - 100*gs_id)

for (ii in c(1:5, 7:15)) {
  # ii = 16
  
  plot_df_t = plot_df |> filter(gs_id == ii)
  area_t = max(plot_df_t$area_GS) - plot_df_t |> filter(rs_id == 6) |> pull(area)
  
  plot_df_t = plot_df_t |> filter(rs_id != 6)
  plot_df_t$areaf = round(100 * plot_df_t$area / area_t, 2)
  
  message("for GS ", ii, " max GS-PS frac is ", max(plot_df_t$areaf))
  
}
