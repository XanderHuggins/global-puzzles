
#    Title: Groundwater anthropocene risks manuscript
#     Author: Xander Huggins
#     Affiliations: 
#                  1. University of Victoria (Canada)
#     Last update: 31 January 2024

## note:
#    the purpose of this list of source scripts is not for users to run this script as a stand-alone script.
#    INSTEAD, consider this script as providing an overview of the sequence in which the scripts need to be 
#    executed, and this list of source scripts allows  individual 'task' to be run sequentially in a common script


# Set working directory to the location of the project
library(here)

# Source setup scripts, including: wd args, plotting themes, custom functions, etc.
invisible(sapply(list.files(here("scripts/00-setup"), full.names = T), source)) 

#/-----------------------------------------------------------------#
#/ PREPARE DATA                                             -------#