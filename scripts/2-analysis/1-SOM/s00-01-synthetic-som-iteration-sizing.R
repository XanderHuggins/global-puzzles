
# determine range of SOM1 iterations
input_data = readr::read_rds(here("data/02_synthetic_data_input.rds"))
write_rds(input_data, file = here("data/som_files/input_data/01_synthetic_input_data.rds")) # put into SOM iterations folder

# estimate number of unique patters in data set
n_patterns = input_data |> nrow() #27,000
k_max = n_patterns ^ (0.4)  # 59
P_min = 2*k_max # 118
P_max = 0.15 * n_patterns # 4050
r_min = sqrt(P_min)  # 10
r_max = sqrt(P_max) # 63
no_cores = 8

n_patterns
r_min
r_max

# overwrite r_min and r_max parameters based on justification provided in SI 
r_min = floor(r_min) + floor(r_min) %% 2
r_max = floor(r_max) + floor(r_max) %% 2

# create vector of all SOM size parameters to try:
som_sizes = seq(r_min, r_max,by=2)

iter_index = expand.grid(size_iter = c(1:60),
                         size = som_sizes)

write_rds(iter_index, file = here("data/som_files/input_data/00_synthetic_SOM_iteration_sizing_index.rds"))
