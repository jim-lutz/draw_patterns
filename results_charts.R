# results_charts.R
# script to plot energy wasted, water wasted, and loads not met
# for compact and distributed core
# and for normal and low flow
# Mon Sep 24 14:40:25 2018

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the results data
load(file = paste0(wd_data,"DT_results.Rdata"))

names(DT_results)

# get order of identifier
# DT_identifier_index <- 
#   DT_results[identifier!='', list(index, identifier)]
# setkey(DT_identifier_index,index)

# ordered list of identifiers
l_identifier = DT_results[index %in% 106:125]$identifier

# convert distributed core, normal flow to long data
DT_results_long <-
  melt(DT_results[core == 'distributed' & 
                    flow == 'std' & 
                    identifier!=''],
       id.vars = c('identifier', 'index'),
       measure.vars = c('HW_energy_excess',
                        'HW_energy_not_met')
    )

# change the variable names
DT_results_long[ variable=="HW_energy_excess", variable := "Wasted Energy" ]
DT_results_long[ variable=="HW_energy_not_met", variable := "Loads Not Met" ]

str(DT_results_long)

# chart distributed core, normal flow
ggplot(data = DT_results_long) +
  # colums of HW_energy_excess 
  geom_col(aes(x=identifier, y=value, fill=variable),
           position = "dodge", width = .5) +
  
  # set the colors
  scale_color_manual(values = c("Attending_Education" = "dark green", "Not_AE" = "red"))

  
  # set expand the x-axis for labels
  scale_x_discrete( expand = expand_scale(mult = -0.1, add = 3),
                    # reverse order for when plot flipped
                    limits = rev(l_identifier)) +

  # turn plot on it's side
  coord_flip() +
  
  # fuss with category axis tick labels
  theme(axis.text.y = element_text(vjust = 1,
                                   hjust = 0,
                                   #angle = 90,
                                   size = 10))   +
  
  # add the labels
  labs(title = "Wasted Energy and Loads Not Met",
       y = "energy (BTU)") +
  
  # center the title
  theme(plot.title = element_text(hjust = 0.5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL) ) +
  
  # add some text
  # x values for data range from 1 to 20, for the numbered categories
  annotate("text", 
           x = c(20.5, 15.5, 10.5,  5.5, 3.5), 
           y = 1000, 
           label = c("Trunk and Branch",
                     "Mini-Manifold",
                     "Central Manifold",
                     "Two Water Heaters",
                     "One Trunk ")
  )
  



  # colums of HW_energy_excess 
  geom_col(aes(x=identifier, y=HW_energy_not_met),
           width =.1, position = "dodge", color='red') 
  
  
  DT_results[core == 'distributed' & flow == 'std' & !is.na(identifier),
           list(case, layout, identifier, 
                HW_energy_excess, HW_volume_excess)][order(case)]
