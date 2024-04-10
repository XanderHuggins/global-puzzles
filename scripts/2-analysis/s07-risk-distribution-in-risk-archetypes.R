# calculate average data per anthropocene risk archetype

data_stack = terra::rast(here("data/04_anthropocene_risks_all_data_and_classes.tif")) 

data_tb = readr::read_rds(here("data/04_anthropocene_risks_all_data_and_classes.rds"))
data_tb$luchange[data_tb$luchange > 2] = 2
hist(data_tb$luchange)

data_summary = data_tb |> 
  group_by(archetypeID) |> 
  summarise(
    gws       = weighted.mean(x = gws, w = area_km2, na.rm = T) * 100,
    precip    = weighted.mean(x = precip, w = area_km2, na.rm = T),
    luchange  = weighted.mean(x = luchange, w = area_km2, na.rm = T),
    conspri   = weighted.mean(x = conspri, w = area_km2, na.rm = T),
    yield_gap = weighted.mean(x = yield_gap, w = area_km2, na.rm = T),
    hypol     = weighted.mean(x = hypol, w = area_km2, na.rm = T),
    gdi       = weighted.mean(x = gdi, w = area_km2, na.rm = T),
    crowding  = weighted.mean(x = crowding, w = area_km2, na.rm = T),
    area      = sum(area_km2, na.rm = T)
  )

ggplot(data = data_summary) +
  geom_point(aes(x = gws, y = precip)) +
  geom_text(aes(x = gws, y = precip, label = archetypeID))
