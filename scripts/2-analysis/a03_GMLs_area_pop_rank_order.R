### ---------------------\\ 
# Script objective:
# Calculate and plot rank order distribution of GLMs across population and surface area
### ---------------------\\
library(here); source(here(("on_button.R")))

# import the riskscape and groundwaterscape rasters
rs = terra::rast(here("data/groundwater-PROBLEMSCAPES-with-mi2.tif"))
values(rs) = as.integer(values(rs))

gs = archs = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/groundwaterscapes-currentiter.tif")
values(gs) = as.integer(values(gs))

# create the groundwater management lanscape raster
GMLs = (gs * 100) + (rs)
names(GMLs) = "GML_id"

# Import and snap the population data
popdat = terra::rast("D:/Geodatabase/Social-data/Population/Wang_2022/SPP3/SSP3_2020.tif")
popdat = terra::aggregate(x = popdat, fact = 10, fun = "sum")
popdat = terra::extend(x = popdat, y = GMLs, snap = "near")
ext(popdat) = round(ext(popdat), 2)
names(popdat) = "pop"
sum(popdat[], na.rm = T)/1e9

# Import and snap food kcal data (SPAM)
food_kcal = terra::rast("D:/Geodatabase/Agriculture/SPAM/SPAM_2010_foodcrops_kcal.tif")
names(food_kcal) = "food_kcal"

rast_stack = c(GMLs, popdat, WGS84_areaRaster(5/60) |> rast(), food_kcal)
names(rast_stack)[[3]] = "area"

### plot area distribution of unique GMLs
data_summary = rast_stack |>
  as_tibble() |>
  drop_na() |>
  group_by(GML_id) |>
  summarise(area = sum(area, na.rm = T),
            pop  = sum(pop, na.rm = T),
            kcal = sum(food_kcal, na.rm = T)) |>
  mutate(areaf = area / sum(area),
         popf = pop / sum(pop),
         calf = kcal/sum(kcal)) |>
  mutate(gs_id = trunc(GML_id / 100)) |>
  mutate(rs_id = GML_id - gs_id*100)

# plot based on area
data_summary = data_summary[order(-data_summary$areaf),]
data_summary$cumsum = cumsum(data_summary$areaf)
data_summary$rank = 1:nrow(data_summary)

head(data_summary)
# view(data_summary)

x.p50 = data_summary |> filter(cumsum > 0.5) |> pull(rank) |> min()
x.p75 = data_summary |> filter(cumsum > 0.75) |> pull(rank) |> min()

ymax.set = 10
xmax.set = 18*15
ggplot() +
  # explained variance
  # geom_line(aes(y = rank_s), col = "#EF440C", linewidth = 2) +
  geom_bar(data = data_summary[1:xmax.set,], stat = "identity",  aes(x= rank, y = 100*areaf), fill = "black", col = "black") +
  geom_line(data = data_summary[1:xmax.set,], aes(x= rank, y = cumsum*ymax.set), col = "red", linewidth = 1.5) +
  # geom_point(data = best_at_size, aes(x= nrc, y = perf), col = "black", size = 5) +
  coord_cartesian(ylim=c(0, ymax.set), xlim = c(0.5, xmax.set+0.5), expand = 0, clip = "off") +
  # geom_hline(yintercept = 0.5*ymax.set) +
  # scale_x_continuous(breaks = seq(4, 30, by = 2)) +
  scale_y_continuous(breaks = seq(0, ymax.set, by = 2)) +
  
  geom_segment(aes(x = x.p50, xend = x.p50, y = 0, yend = ymax.set*0.5), 
               linetype = "dashed", lwd = 1,
               color = "red") +
  
  geom_segment(aes(x = x.p75, xend = x.p75, y = 0, yend = ymax.set*0.75), 
               linetype = "dashed", lwd = 1, 
               color = "red") + 
  my_theme +
  theme(axis.line = element_line(size = 1),
        panel.grid.major = element_line(),
        axis.text = element_text(size=13),
        axis.title = element_blank())

ggsave(plot = last_plot(),
       filename = here("plots/GSP_rank_order_area_distribution.png"),
       height = 7,
       width = 18,
       units = "cm",
       dpi = 400)


############################### //
# create rank order comparison df 
############################### //
rank_df = tibble(ID = data_summary$GML_id,
                 area_order = data_summary$rank)


############################### //
# repeat for population
############################### //

data_summary = data_summary[order(-data_summary$popf),]
data_summary$cumsum = cumsum(data_summary$popf)
data_summary$rank = 1:nrow(data_summary)
head(data_summary)

x.p50 = data_summary |> filter(cumsum > 0.5) |> pull(rank) |> min()
x.p75 = data_summary |> filter(cumsum > 0.75) |> pull(rank) |> min()

ymax.set = 10
xmax.set = 270
ggplot() +
  # explained variance
  # geom_line(aes(y = rank_s), col = "#EF440C", linewidth = 2) +
  geom_bar(data = data_summary[1:xmax.set,], stat = "identity",  aes(x= rank, y = 100*popf), fill = "black", col = "black") +
  geom_line(data = data_summary[1:xmax.set,], aes(x= rank, y = cumsum*ymax.set), col = "blue", linewidth = 1.5) +
  # geom_point(data = best_at_size, aes(x= nrc, y = perf), col = "black", size = 5) +
  coord_cartesian(ylim=c(0, ymax.set), xlim = c(0.5, xmax.set+0.5), expand = 0, clip = "off") +
  # geom_hline(yintercept = 0.5*ymax.set) +
  # scale_x_continuous(breaks = seq(4, 30, by = 2)) +
  scale_y_continuous(breaks = seq(0, ymax.set, by = 2)) +
  geom_segment(aes(x = x.p50, xend = x.p50, y = 0, yend = ymax.set*0.5), 
               linetype = "dashed", lwd = 1,
               color = "blue") +
  
  geom_segment(aes(x = x.p75, xend = x.p75, y = 0, yend = ymax.set*0.75), 
               linetype = "dashed", lwd = 1, 
               color = "blue") + 
  my_theme +
  theme(axis.line = element_line(size = 1),
        panel.grid.major = element_line(),
        axis.text = element_text(size=13),
        axis.title = element_blank())

ggsave(plot = last_plot(),
       filename = here("plots/GSP_rank_order_pop_distribution.png"),
       height = 7,
       width = 18,
       units = "cm",
       dpi = 400)


rank_df = merge(x= rank_df, y = data_summary |> dplyr::select(GML_id, rank) |> set_colnames(c('ID', 'popl_order')),
                by = "ID")

############################### //
# repeat for food kcal
############################### //

data_summary = data_summary[order(-data_summary$calf),]
data_summary$cumsum = cumsum(data_summary$calf)
data_summary$rank = 1:nrow(data_summary)

x.p50 = data_summary |> filter(cumsum > 0.5) |> pull(rank) |> min()
x.p75 = data_summary |> filter(cumsum > 0.75) |> pull(rank) |> min()

ymax.set = 14
xmax.set = 270
ggplot() +
  # explained variance
  # geom_line(aes(y = rank_s), col = "#EF440C", linewidth = 2) +
  geom_bar(data = data_summary[1:xmax.set,], stat = "identity",  aes(x= rank, y = 100*calf), fill = "black", col = "black") +
  geom_line(data = data_summary[1:xmax.set,], aes(x= rank, y = cumsum*ymax.set), col = "green4", linewidth = 1.5) +
  # geom_point(data = best_at_size, aes(x= nrc, y = perf), col = "black", size = 5) +
  coord_cartesian(ylim=c(0, ymax.set), xlim = c(0.5, xmax.set+0.5), expand = 0, clip = "off") +
  # geom_hline(yintercept = 0.5*ymax.set) +
  # scale_x_continuous(breaks = seq(4, 30, by = 2)) +
  scale_y_continuous(breaks = seq(0, ymax.set, by = 2)) +
  geom_segment(aes(x = x.p50, xend = x.p50, y = 0, yend = ymax.set*0.5), 
               linetype = "dashed", lwd = 1,
               color = "green4") +
  
  geom_segment(aes(x = x.p75, xend = x.p75, y = 0, yend = ymax.set*0.75), 
               linetype = "dashed", lwd = 1, 
               color = "green4") + 
  my_theme +
  theme(axis.line = element_line(size = 1),
        panel.grid.major = element_line(),
        axis.text = element_text(size=13),
        axis.title = element_blank())

ggsave(plot = last_plot(),
       filename = here("plots/GSP_rank_order_kcal_distribution.png"),
       height = 7,
       width = 18,
       units = "cm",
       dpi = 400)

rank_df = merge(x= rank_df, y = data_summary |> dplyr::select(GML_id, rank) |> set_colnames(c('ID', 'kcal_order')),
                by = "ID")

rank_df = rank_df |> 
  mutate(sum = rowSums(across(2:4))/3) 
view(rank_df)

# calculate rank consistency -- Kendall’s Coefficient of Concordance (W)
library(irr)

irr::kendall(rank_df[2:4])

irr::kendall(rank_df[3:4])

irr::kendall(rank_df[c(2,4)])

irr::kendall(rank_df[c(2,3)])
