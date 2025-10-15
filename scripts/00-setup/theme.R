my_theme = theme_minimal()+
  theme(legend.title = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA))


met.pal.use = "Cross"

pal_arch = met.brewer(name = "Cross", n = 11, type = "continuous")[c(1:3, 5:11)]

library(MexBrewer)
pal.use.risks = mex.brewer(palette_name = "Atentado",
                           n = 10, 
                           type = "discrete",
                           direction  = -1)[c(1,3,5,6,8,10)]

risk_pal = mex.brewer(palette_name = "Atentado",
                      n = 10, 
                      type = "discrete",
                      direction  = -1)[c(3,1,10,9,7)]

risk_pal = mex.brewer(palette_name = "Atentado",
                      n = 11, 
                      type = "continuous",
                      direction  = 1)

risk_pal = mex.brewer(palette_name = "Atentado",
                      n = 8, 
                      type = "continuous",
                      direction  = 1)

risk_pal = mex.brewer(palette_name = "Atentado",
                      n = 18, 
                      type = "continuous",
                      direction = 1) #[c(3,1,10,9,7)]
risk_pal = rev(risk_pal)
