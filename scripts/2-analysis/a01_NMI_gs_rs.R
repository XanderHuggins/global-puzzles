### ---------------------\\ 
# Script objective:
# Calculate normalized mutual entropy between groundwaterscapes and riskscapes
### ---------------------\\
library(here); source(here(("on_button.R"))); library(entropy)
###

rs = terra::rast(here("data/groundwater-PROBLEMSCAPES-with-mi2.tif"))
values(rs) = as.integer(values(rs))

gs = archs = terra::rast("C:/Users/xande/Documents/2.scripts/gcs-archetypes/data/groundwaterscapes-currentiter.tif")
values(gs) = as.integer(values(gs))


# Stack and extract values
df = data.frame(values(rs), values(gs)) |> drop_na()  # Remove NA pairs

# Create joint frequency table
joint_table = table(df[,1], df[,2])

# Convert to joint probability matrix
joint_prob = joint_table / sum(joint_table)

# marginal probabilities
pa = rowSums(joint_prob)
pb = colSums(joint_prob)

# Compute Mutual Information (in bits)
MI = entropy::mi.plugin(joint_table)

# Compute entropies
H_A = entropy::entropy.plugin(pa)
H_B = entropy::entropy.plugin(pb)

# Compute Normalized Mutual Information (symmetric form)
NMI = MI / sqrt(H_A * H_B); NMI
NMI = 2 * MI / (H_A + H_B); NMI
NMI