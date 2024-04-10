# import the data file 
library(kohonen)
library(aweSOM)
library(readr)
library(tibble) 
library(clusterSim)

input_data = readr::read_rds("./input_data/02_anchor_points_kmeans_1e4_centers_only.rds")

iter_index = readr::read_rds("./input_data/SOM1_iteration_index.rds")

input_iter_from_shell = as.numeric(commandArgs(trailingOnly = TRUE))

# now create the SOM for the given iteration
som_input = input_data |>  as.matrix()
som_size = iter_index$size[input_iter_from_shell]
iter_no = iter_index$size_iter[input_iter_from_shell]

som_iter = kohonen::supersom(som_input, 
                             grid = somgrid(xdim = som_size, 
                                            ydim = som_size, 
                                            topo="hexagonal"), 
                             rlen = 500, 
                             alpha = c(0.05, 0.01),
                             keep.data = TRUE)

write_rds(x = som_iter,
          file = paste0("./som_files/som1_nrc_", som_size, "_iter_", iter_no, ".rds"))

som_quality = aweSOM::somQuality(som = som_iter, traindat = som_input)
cluster_quality = clusterSim::index.DB(x = som_input, cl = som_iter$unit.classif)

som_quality_df = tibble(
  quant = som_quality$err.quant[1] |> as.numeric() |> round(5),
  varra = som_quality$err.varratio[1] |> as.numeric() |> round(5),
  k_l   = som_quality$err.kaski[1] |> as.numeric() |> round(5),
  topo  = som_quality$err.topo[1] |> as.numeric() |> round(5),
  db_x  = cluster_quality$DB[1] |> as.numeric() |> round(5),
  som_size = som_size,
  som_iter = iter_no
)
# som_quality_df

write_rds(x = som_quality_df,
          file = paste0("./som_performance/som1_nrc_", som_size, "_iter_", iter_no, ".rds"))