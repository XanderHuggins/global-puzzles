
# import data layers and identify hotspot regions for each layer

risk_stack = terra::rast(here("data/01_risk_stack_raw_data.tif"))
risk_stack$area = WGS84_areaRaster(5/60) |> rast()

risk_df = risk_stack |> 
  as_tibble()

# for each layer, identify a statistical threshold denoting a hotspot region
thresh = 0.7

risk_thresholds = risk_df |> 
  summarise(
    gsh_t = wtd.quantile(x = gsh, weight = area, q = 1-thresh, na.rm = T),
    gws_t = wtd.quantile(x = gws, weight = area, q = 1-thresh, na.rm = T),
    pcp_t = wtd.quantile(x = precip, weight = area, q = 1-thresh, na.rm = T),
    luc_t = wtd.quantile(x = luchange, weight = area, q = thresh, na.rm = T),
    ydg_t = wtd.quantile(x = yield_gap, weight = area, q = thresh, na.rm = T),
    cns_t = wtd.quantile(x = conspri, weight = area, q = 1-thresh, na.rm = T),
    hpl_t = wtd.quantile(x = hypol, weight = area, q = thresh, na.rm = T),
    gdi_t = wtd.quantile(x = gdi, weight = area, q = 1-thresh, na.rm = T),
    cwd_t = wtd.quantile(x = crowding, weight = area, q = thresh, na.rm = T)
  )

# now convert to binary maps 
hotspots = terra::rast(risk_stack, nlyrs = 9, vals = 0)
hotspots[is.na(risk_stack$id)] = NA
names(hotspots) = names(risk_stack)[1:9]

hotspots$gsh[] = 0
hotspots$gsh[risk_stack$gsh             >= 5] = 1
hotspots$gws[risk_stack$gws             < risk_thresholds$gws_t] = 1
hotspots$precip[risk_stack$precip       < risk_thresholds$pcp_t] = 1 
hotspots$luchange[risk_stack$luchange   > risk_thresholds$luc_t] = 1
hotspots$conspri[risk_stack$conspri     < risk_thresholds$cns_t] = 1
hotspots$yield_gap[risk_stack$yield_gap > risk_thresholds$ydg_t] = 1
hotspots$hypol[risk_stack$hypol         > risk_thresholds$hpl_t] = 1
hotspots$gdi[risk_stack$gdi             < risk_thresholds$gdi_t] = 1
hotspots$crowding[risk_stack$crowding   > risk_thresholds$cwd_t] = 1
plot(hotspots)

hotspots$sum = NULL
hotspots$sum = sum(c(hotspots))
plot(hotspots$sum)
writeRaster(hotspots, filename = here("data/MAP_00_risk_hotspots.tif"), overwrite = T)


# Now repeat the process -- NOT for hotspots, but for critical values (e.g., if threat exists or not...)
riskspots = terra::rast(risk_stack, nlyrs = 9, vals = 0)
riskspots[is.na(risk_stack$id)] = NA
names(riskspots) = names(risk_stack)[1:9]

riskspots$gsh[risk_stack$gsh             >= 3] = 1
riskspots$gws[risk_stack$gws             < 0] = 1
riskspots$precip[risk_stack$precip       < 1] = 1 
riskspots$luchange[risk_stack$luchange   > 1] = 1
riskspots$conspri[risk_stack$conspri     < 80] = 1
riskspots$yield_gap[risk_stack$yield_gap > 20] = 1
riskspots$hypol[risk_stack$hypol         > 0.1] = 1
riskspots$gdi[risk_stack$gdi             < 0.999] = 1
riskspots$crowding[risk_stack$crowding   > 1] = 1
plot(riskspots)

riskspots$sum = sum(c(riskspots))
plot(riskspots$sum)
writeRaster(riskspots, filename = here("data/MAP_00_riskspots.tif"), overwrite = T)
