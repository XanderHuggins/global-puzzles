

som2_prot_to_arch = readr::read_rds(here("data/som_files/som_selections/som2_selection.rds"))
som1_anch_to_prot = readr::read_rds(here("data/som_files/som_files_full/som1_nrc_64_iter_52.rds"))
# cell_to_anch = readr::read_rds(here("data/som_files/som_derivation_data/01_synthetic_kmeans_all_data.rds"))
full_data_df = readr::read_rds(here("data/01_risk_stack_scaled.rds"))

# create prototype to archetype dictionary
prot_to_arch_dict = data.frame(
  archetypeID = som2_prot_to_arch$unit.classif,
  prototypeID = seq(1, length(som2_prot_to_arch$unit.classif))
)

# create (COMPLETE) input data to prototype dictionary
cell_to_prot_dict = data.frame(
  cellID = full_data_df$id,
  prototypeID =  som1_anch_to_prot$unit.classif
)

#  (HOLEY) input data to prototype dictionary
hole_to_prot = readr::read_rds(here("data/02_holey_data_to_prototypes.rds"))
names(hole_to_prot) = c("cellID", "prototypeID")


# combined input data to prototype dictionary
cell_to_prot_dict = rbind(cell_to_prot_dict, hole_to_prot)

main_reclass_dictionary = merge(x = cell_to_prot_dict,
                                y = prot_to_arch_dict,
                                by.x = "prototypeID",
                                by.y = "prototypeID")


## 
####### RECLASSIFY TO MAPS ----------------------------------\
##

# now reclassify grid cell ID raster to prototypes, archetypes, and mask 
grid_id_raster = terra::rast(here("data/01_risk_stack_scaled.tif"))
grid_id_raster = grid_id_raster$id

prototypes_map = rasterDT::subsDT(x = raster(grid_id_raster),
                                  dict = data.frame(from = main_reclass_dictionary$cellID,
                                                    to   = main_reclass_dictionary$prototypeID),
                                  # filename = here("data/groundwater-SYSTEM-prototypes_.tif"),
                                  overwrite = TRUE)

archetypes_map = rasterDT::subsDT(x = raster(grid_id_raster),
                                  dict = data.frame(from = main_reclass_dictionary$cellID,
                                                    to   = main_reclass_dictionary$archetypeID), 
                                  filename = here("data/MAP_01_archetypes.tif"),
                                  overwrite = TRUE)

# perform 3x3 modal smoothing over archetypes
archetypes_map_3x3 = terra::focal(x = rast(archetypes_map), w = 3, fun = "modal", expand = FALSE, na.rm = TRUE,
                                  filename = here("data/groundwater-RISK-archetypes_3x3_currentiter.tif"),
                                  overwrite = T)

archetypes_map_3x3[is.na(archetypes_map |> rast())] = NA
writeRaster(x = archetypes_map_3x3,
            filename = here("data/groundwater-RISK-archetypes_3x3_currentiter.tif"),
            overwrite = T)

plot(archetypes_map_3x3)

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
