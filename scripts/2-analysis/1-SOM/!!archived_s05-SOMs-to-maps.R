
# Create membership master dictionary to map archetype : prototype : anchor point : cell ID 

# import the SOM data frames
som2_prot_to_arch = readr::read_rds(here("data/som_files/som_selections/som2_selection.rds"))
som1_anch_to_prot = readr::read_rds(here("data/som_files/som_files_full/som1_nrc_64_iter_52.rds"))
hole_to_prot = readr::read_rds(here("data/02_holey_data_to_prototypes.rds"))
full_data_df = readr::read_rds(here("data/01_risk_stack_scaled.rds"))

cell_to_anch = readr::read_rds(here("data/02_input_data_with_synthetic_links.rds"))

# create prototype to archetype dictionary
prot_to_arch_dict = data.frame(
  archetypeID = som2_prot_to_arch$unit.classif,
  prototypeID = seq(1, length(som2_prot_to_arch$unit.classif))
)

# create synthetic anchor point to prototype dictionary
anch_to_prot_dict = data.frame(
 prototypeID =  som1_anch_to_prot$unit.classif,
 anchorpt_ID = 1:(cell_to_anch$centers |> nrow())
)

# combine archetype with prototype 
vertical_dictionary = merge(x = prot_to_arch_dict,
                          y = anch_to_prot_dict,
                          by.x = "prototypeID",
                          by.y = "prototypeID")

# link cell IDs with their synthetic anchor point (derived using kmeans)
full_cells_dictionary = data.frame(cellID      = full_data_df$id,
                                   anchorpt_ID = cell_to_anch$cluster)
  
full_cells_dictionary = merge(x = full_cells_dictionary,
                              y = vertical_dictionary,
                              by.x = "anchorpt_ID",
                              by.y = "anchorpt_ID")


# link cell IDs with their prototype for holey data
holey_cells_dictionary = merge(x = hole_to_prot,
                         y = prot_to_arch_dict,
                         by.x = "pID",
                         by.y = "prototypeID")
names(holey_cells_dictionary) = c("prototypeID", "cellID", "archetypeID")
holey_cells_dictionary$anchorpt_ID  = rep(NA)
holey_cells_dictionary = holey_cells_dictionary |> dplyr::select(c("anchorpt_ID", "cellID", "prototypeID", "archetypeID"))



# combine these two reclassification dictionaries
main_reclass_dictionary = rbind(full_cells_dictionary, holey_cells_dictionary)
write_rds(main_reclass_dictionary, here("data/03_main_reclass_dictionary.rds"))

####### RECLASSIFY TO MAPS ----------------------------------\
# now reclassify grid cell ID raster to prototypes, archetypes, and mask 
grid_id_raster = terra::rast(here("data/01_risk_stack_scaled.tif"))

prototypes_map = rasterDT::subsDT(x = raster(grid_id_raster$id),
                                  dict = data.frame(from = main_reclass_dictionary$cellID,
                                                    to   = main_reclass_dictionary$prototypeID), 
                                  filename = here("data/MAP_01_prototypes.tif"),
                                  overwrite = TRUE)

archetypes_map = rasterDT::subsDT(x = raster(grid_id_raster$id),
                                  dict = data.frame(from = main_reclass_dictionary$cellID,
                                                    to   = main_reclass_dictionary$archetypeID), 
                                  filename = here("data/MAP_01_archetypes.tif"),
                                  overwrite = TRUE)

# perform 3x3 modal smoothing over archetypes
archetypes_map_3x3 = terra::focal(x = rast(archetypes_map), w = 3, fun = "modal", expand = F,
                                  filename = here("data/groundwater-RISK-archetypes_3x3_currentiter.tif"),
                                  overwrite = T)

# create master raster stack of all input data, prototypes, and archetypes
input_data_stack = terra::rast(here("data/01_risk_stack_raw_data.tif"))

full_stack = c(input_data_stack, rast(prototypes_map), archetypes_map_3x3)
names(full_stack)[12:13] = c("prototypeID", "archetypeID")

terra::writeRaster(full_stack, 
                   filename = here("data/04_anthropocene_risks_all_data_and_classes.tif"),
                   overwrite = TRUE)

data_tb = full_stack |> 
  as_tibble()
write_rds(x = data_tb,
          file = here("data/04_anthropocene_risks_all_data_and_classes.rds"))


# ##
# 
# 
# 
# # now create a reclassification dictionary for full data cells:
# 
# cell_to_anch$cluster
# 
# 
# names(master_dictionary) = c('prototypeID', 'cellID', 'archetypeID')
# 
# # distribute master dictionary to unsampled data points
# supplemental_dictionary = merge(x = grain_2pro,
#                                 y = arch2prot_dict,
#                                 by.x = "pID",
#                                 by.y = "prototypeID")
# names(supplemental_dictionary) = c('prototypeID', 'cellID', 'archetypeID')
# 
# # format to combine
# master_dictionary = rbind(master_dictionary, supplemental_dictionary)
# # write to file
# 
# write_rds(master_dictionary, here("data/03_master_cell_dictionary.rds"))
# 
# 
# # now reclassify grid cell ID raster to prototypes, archetypes, and mask 
# grid_id_raster = terra::rast(here("data/01_risk_stack_scaled.tif"))[[10]]
# 
# prototypes_map = rasterDT::subsDT(x = raster(grid_id_raster),
#                                   dict = data.frame(from = master_dictionary$cellID,
#                                                     to   = master_dictionary$prototypeID), 
#                                   filename = here("data/MAP_01_prototypes.tif"),
#                                   overwrite = TRUE)
# 
# archetypes_map = rasterDT::subsDT(x = raster(grid_id_raster),
#                                   dict = data.frame(from = master_dictionary$cellID,
#                                                     to   = master_dictionary$archetypeID), 
#                                   filename = here("data/MAP_01_archetypes.tif"),
#                                   overwrite = TRUE)
# 
# 
# # create master raster stack of all input data, prototypes, and archetypes
# input_data_stack = terra::rast(here("data/01_risk_stack_raw_data.tif"))
# 
# full_stack = c(input_data_stack, rast(prototypes_map), rast(archetypes_map), rast(WGS84_areaRaster(5/60)))
# names(full_stack)[9:11] = c("prototypeID", "archetypeID", "area_km2")
# 
# terra::writeRaster(full_stack, 
#                    filename = here("data/04_anthropocene_risks_all_data_and_classes.tif"),
#                    overwrite = TRUE)
# 
# data_tb = full_stack |> 
#   as_tibble()
# 
# write_rds(x = data_tb,
#           file = here("data/04_anthropocene_risks_all_data_and_classes.rds"))
