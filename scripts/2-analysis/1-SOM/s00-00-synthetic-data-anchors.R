
# move to own function
# from: https://stackoverflow.com/questions/54419329/calculate-total-sum-of-squares-between-clusters-in-r
calc_SS = function(df) sum(as.matrix(dist(df)^2)) / (2 * nrow(df))
####


# create a sampled datasets of "anchor points" using k-means that represents the underlying heterogeneity of the global data

risk_stack = terra::rast(here("data/01_risk_stack_scaled_alldata_noNAtrim.tif")) |> 
  as_tibble() |> drop_na()

write_rds(risk_stack,
          file = here("data/01_risk_stack_scaled.rds"))

write_rds(risk_stack |> dplyr::select(!c(id, area)),
          file = here("data/som_files/input_data/02_full_input_data_norm.rds"))


## identify the size of kmeans cluster centers to retain 99% of data
# n.sample = 1.1e4
n.sample = 100

synthetic_anchors = kmeans(x = risk_stack[1:9], centers = n.sample, iter.max= 100)
synthetic_anchors$betweenss/synthetic_anchors$totss # 84%

risk_stack$batchID = synthetic_anchors$cluster

# within each of 100 first-batch k-means, calculate XX sub-clusters

df_batch_all = matrix(nrow = 0, ncol = ncol(risk_stack)) |>  as.data.frame()
names(df_batch_all) = names(risk_stack)

centers_all = matrix(nrow = 0, ncol = ncol(synthetic_anchors$centers)) |>  as.data.frame()
names(centers_all) = names(synthetic_anchors$centers |> as_tibble())

# n.total = 2.7e4
n.total = 0.6e4

for (i in 1:n.sample) {
  # i = 1
  # create batch df
  batch_stack = risk_stack |> filter(batchID == i)
  
  batch_kmeans = kmeans(x = batch_stack[1:9], centers = (n.total/n.sample), iter.max= 100)
  batch_stack$clustID = (n.total/n.sample*(i-1)) + batch_kmeans$cluster # this is so batches don't replicate IDs
  
  df_batch_all = rbind(df_batch_all, batch_stack) # bind batch to main df
  centers_all = rbind(centers_all, batch_kmeans$centers |> as_tibble())
  
  batch_stack = NULL
  message("done loop ", i, " out of ", n.sample)
  
}

ss_calc = df_batch_all |> 
  dplyr::select(!c(area, id, batchID)) |> 
  group_by(clustID) |> 
  nest() |> 
  summarise(
    within_SS = map_dbl(data, ~calc_SS(.x))
  )

# increase the size of second batch until this is >99%
round(1-sum(ss_calc$within_SS)/synthetic_anchors$totss, 2)

# A sample of <2% of the dataset represents ~95% of the data variance
n.total/nrow(risk_stack)

mult = trunc(nrow(risk_stack)/n.sample)

anchor_codes = centers_all
write_rds(anchor_codes, 
          file = here("data/02_synthetic_data_input.rds"))

df_batch_all
write_rds(df_batch_all, 
          file = here("data/02_input_data_with_synthetic_links.rds"))

membership_df = tibble(cellID = df_batch_all$id,
                       anchorID = df_batch_all$clustID)

write_rds(membership_df, file = here("data/Mapping_cells_to_anchor_points_dictionary.rds"))

# # import the kmeans rds file
# input_data = read_rds(here("data/01_risk_stack_scaled.rds"))
# kmeans_anchors = readr::read_rds(here("data/02_anchor_points_kmeans_1e4_all_data.rds"))
# 
# membership_df = tibble(cellID = input_data$id,
#                        anchorID = kmeans_anchors$cluster)
# 
# write_rds(membership_df, file = here("data/Mapping_cells_to_anchor_points_dictionary.rds"))



## old approach below (nearest neighbour to sampled point)
# 
# ## first -- need to handle missing data in the global datasets
# risk_stack = terra::rast(here("data/01_risk_stack_scaled.tif"))
# 
# # set all missing data to mean of individual data layer
# for (i in 1:8) { risk_stack[[i]][is.na(risk_stack[[i]])] = 0  ; message(i, " is done")}
# 
# mask_dat = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/project_mask.tif")
# risk_stack = terra::mask(x = risk_stack, mask = mask_dat)
# 
# risk_stack_df = risk_stack |> 
#   as.data.frame()
# 
# # remove sampled points from this dataset
# sampled_df = readr::read_rds(here("data/02_risk_data_scaled_sampled_to_anchor_points.rds"))
# 
# # clean sampled cells from the full set
# unsampled_df = risk_stack_df |> dplyr::filter(id %!in% sampled_df$id)
# 
# # write to file
# write_rds(unsampled_df, file = here("data/01_unsampled_points_holes_filled.rds"))
# 
# 
# # assess representativeness of synthetic anchor points
# 
# overlapping::overlap(x = list(data = risk_stack$gsh, synthetic = rep(anchor_codes$gsh, mult)), plot = T) # 0.977
# overlapping::overlap(x = list(data = risk_stack$gws, synthetic = rep(anchor_codes$gws, mult)), plot = T) # 0.977
# overlapping::overlap(x = list(data = risk_stack$precip, synthetic = rep(anchor_codes$precip, mult)), plot = T) # 96.8
# overlapping::overlap(x = list(data = risk_stack$luchange, synthetic = rep(anchor_codes$luchange, mult)), plot = T) # 0.80
# overlapping::overlap(x = list(data = risk_stack$conspri, synthetic = rep(anchor_codes$conspri, mult)), plot = T) # 0.92
# overlapping::overlap(x = list(data = risk_stack$yield_gap, synthetic = rep(anchor_codes$yield_gap, mult)), plot = T) # 0.96
# overlapping::overlap(x = list(data = risk_stack$hypol, synthetic = rep(anchor_codes$hypol, mult)), plot = T) # 0.97
# overlapping::overlap(x = list(data = risk_stack$gdi, synthetic = rep(anchor_codes$gdi, mult)), plot = T) # 0.91
# overlapping::overlap(x = list(data = risk_stack$crowding, synthetic = rep(anchor_codes$crowding, mult)), plot = T) # 0.97
# 
# # 
# # #### Old methods below... 
# # 
# # Create percentile bins for each input raster
# n.quant = 5
# 
# risk_stack$uniqueID = paste0(
#   ptile_classify(vect.in = risk_stack$gws, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$precip, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$luchange, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$conspri, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$yield_gap, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$hypol, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$gdi, weight.in = risk_stack$area, n.quant = n.quant),
#   ptile_classify(vect.in = risk_stack$crowding, weight.in = risk_stack$area, n.quant = n.quant)) |> 
#   as.numeric()
# risk_stack$uniqueID |> unique() |> length()
# 
# # create a data frame that holds the area distribution of the granular unique risk type
# risk_granual_distribuation = risk_stack |> 
#   group_by(uniqueID) |> 
#   summarise(area = sum(area, na.rm = T)) |> 
#   mutate(areaf = 100 * area / sum(area, na.rm = T))


## Tried to see if k-means clustering would create a representative sample with less points than simple resampling but did not find it to be effective -- commented out to keep in case wanting to return to 
# Create a k-means anchor dataset to represent the data but in fewer rows
# n.sample = 1e4
# synthetic_anchors = kmeans(x = risk_stack[1:8], centers = n.sample, iter.max= 10)
# 
# synthetic_anchors_df = synthetic_anchors$centers |> as_tibble()
# 
# # classify this synthetic data into the unique IDs of the input data
# synthetic_anchors_df$uniqueID = paste0(
#   base::cut(synthetic_anchors_df$gws, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$gws, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$precip, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$precip, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$luchange, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$luchange, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$conspri, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$conspri, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$yield_gap, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$yield_gap, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$hypol, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$hypol, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$gdi, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$gdi, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F),
#   base::cut(synthetic_anchors_df$crowding, 
#             breaks = ptile_cut_breaks(vect.in = risk_stack$crowding, weight.in = risk_stack$area, n.quant = n.quant), 
#             include.lowest = TRUE, labels = F))
# 
# 
# # determine which unique IDs are replicated in the synthetic anchors, and determine their cumulative area fraction
# risk_granual_distribuation |> 
#   dplyr::filter(uniqueID %in% synthetic_anchors_df$uniqueID) |> 
# #   pull(areaf) |> 
# #   sum()
# 
# sample_size = 2e5
# risk_granual_distribuation |> 
#   dplyr::filter(uniqueID %in% (risk_stack |> slice_sample(n = sample_size) |> pull(uniqueID))) |> 
#   pull(areaf) |> 
#   sum()
# 
# # A sample of 53% of the dataset represents 95% of the data patterns
# sample_size/nrow(risk_stack)
# 
# risk_df_sample = risk_stack |> slice_sample(n = sample_size)
# 
# write_rds(risk_df_sample, 
#           file = here("data/02_risk_data_scaled_sampled_to_anchor_points.rds"))
# 
