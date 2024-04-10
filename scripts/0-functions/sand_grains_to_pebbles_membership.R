sand_grains_to_pebbles_membership = function(unsampled_points_df, sampled_points_df, intvl){

  # unsampled_points_df = input_stack_holes
  # sampled_points_df = prototype_pts
  # intvl = 1e4
  
  nloop = trunc(nrow(unsampled_points_df)/intvl, 0)+1
  message("number of loops: ", nloop)
  
  # create classification dictionary for all nonsampled cell IDs to prototype IDs
  class_dict = data.frame(
    cID = rep(NA, 0),
    pID = rep(NA, 0)
  )
  
  
  for (i in 1:nloop) { # XYZ loops
    
    # i = 1
    # i = 7267
    start_val = (intvl * (i-1)) + 1
    # start_val
    
    # if (i == 1) {start_val = 1}
    
    # calculate Euclidean distance from individual grid cell requiring prototype assignment to all prototype centroids
    dist_matrix =
      rdist.w.na(X = unsampled_points_df[start_val : min((start_val + intvl-1), nrow(unsampled_points_df)),] |>
                   dplyr::select(-c(id, area)) |> as.matrix(),
                 Y = sampled_points_df |> dplyr::select(-c(id, area)) |> as.matrix()) |>
      t() |>
      c() |>
      matrix(byrow = FALSE, ncol = min((start_val + intvl-1), nrow(unsampled_points_df)) - start_val + 1)
    
    
    # identify the closest prototype for each unsampled cell in loop
    min_dist_loc = apply(dist_matrix, 2, which.min) 
    
    # create dataframe holding the cell ID of the nearest sampled point 
    loc_to_id_df = data.frame(df_location = min_dist_loc, original_seq = seq(1:min(intvl, length(min_dist_loc))))
    
    # add rowID label to iterative object 
    sampled_points_df_iter = sampled_points_df
    sampled_points_df_iter$rowID = seq(1:nrow(sampled_points_df))
    
    sampled_simple = sampled_points_df_iter |> dplyr::select(c(id, rowID))
    
    loc_to_id_df = merge(x = loc_to_id_df, y = sampled_simple, 
                         by.x  = "df_location", by.y = "rowID", sort = F)
    head(loc_to_id_df)
    
    loc_to_id_df = loc_to_id_df |> as.data.frame()
    loc_to_id_df = loc_to_id_df[order(loc_to_id_df$original_seq),]
    
    
    # populate the classification dictionary with result
    class_dict_loop = data.frame(
      cID = unsampled_points_df[start_val : min((start_val + intvl-1), nrow(unsampled_points_df)),] |> dplyr::pull(id), # cell ID needing classification
      pID = loc_to_id_df$id # possible because position in table corresponds to the prototype ID
    )
    
    # bind looped classification dictionaries 
    class_dict = rbind(class_dict, class_dict_loop)
    # start_val = (i * intvl) + 1
    message("loop ", i, "/", nloop, " is done")
    message("number of rows in class_dict so far is ", nrow(class_dict))
    
  }
  
  return(class_dict)  
}
