\# Groundwaterscapes Sustainability Puzzle code repository



\[!\[](<https://img.shields.io/badge/link-active-after--acceptance/SP3/MFYCWV-yellow>)]()



This is the code repository associated with the manuscript: Huggins et al. (2025). \*\*The puzzling yet tractable diversity of global groundwater sustainability challenges\*\* -- submitted for peer review.



This repository includes all scripts necessary to preprocess input data, reproduce the problemscape typology, develop the sustainability puzzles, and evaluate their landscape metrics. Some scripts have been executed on clusters provided by the Digital Research Alliance of Canada and will not be fully executable on local machines.



\*\*`Scripts` folder sub-structure\*\*: <br/>

\- `on\_button.R`: Calls the `here()` function and sources scripts in the `\\00-setup` and `\\0-functions` folders.

\- `0-functions`: Contains custom functions with explanatory names.

\- `00-steup`: Loads required packages, sets package options, and configures plotting themes.

\- `1-preprocessing`: 

&nbsp; -  Contains preprocessing scripts to harmonize data to a 5-arcminute resolution. 

\- `2-analysis/1-SOM`:

&nbsp; -  Contains all scripts related to self-organizing maps (SOM) derivation of global groundwater problemscapes.

\- `2-analysis/a2-SOM-clustering`:

\- `2-analysis`:

&nbsp; -  Includes a script that calculates landscape metrics of groundwaterscapes within aquifers.

<br/>



Additional scripts, such as for plotting, can be made available upon request.



For any questions about this repository, please contact: <br/>

Xander Huggins : xander.huggins@ubc.ca <br/>



<p align="center">

&nbsp; <img src="https://raw.githubusercontent.com/XanderHuggins/gwscape-risks/master/assets/readme-image.png"

&nbsp; width="100%"/>

</p>

<br/>

