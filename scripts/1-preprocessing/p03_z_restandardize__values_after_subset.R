
### ============================================
### calculate bias/shift in z distribution in full coverage subset
### to back-transform z scores for plotting (but not for derivations)
### ============================================


risk_stack_all = terra::rast(here("data/01_risk_stack_scaled_alldata_noNAtrim.tif")) |> 
  as_tibble()

risk_stack_complete_case = terra::rast(here("data/01_risk_stack_scaled_alldata_noNAtrim.tif")) |> 
  as_tibble() |> drop_na()

results_df = tibble(var = names(risk_stack_all)[1:9],
                    mean_all = rep(NA),
                    mean_cc = rep(NA),
                    sd_cc = rep(NA))

for (ii in 1:nrow(results_df)) {
  # ii = 1
  
  results_df$mean_all[ii] = risk_stack_all[,ii] |> as_tibble() |> pull() |> mean(na.rm = T)
  results_df$mean_cc[ii] = risk_stack_complete_case[,ii] |> as_tibble() |> pull() |> mean(na.rm = T)
  results_df$sd_cc[ii] = risk_stack_complete_case[,ii] |> as_tibble() |> pull() |> sd(na.rm = T)
  
}

write_rds(results_df, file = here("data/z_score_restandardize_all_to_cc.RDS"))
