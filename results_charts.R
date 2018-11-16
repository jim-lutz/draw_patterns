# results_charts.R
# script to plot energy wasted and loads not met
# for distributed & compact core 
# for normal and small pipes
# for normal and low flow
# Mon Sep 24 14:40:25 2018

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the results data
load(file = paste0(wd_data,"DT_results.Rdata"))

names(DT_results)

# change the variable names
setnames(DT_results,
         old = c('HW_energy_excess','HW_energy_not_met','HW_volume_excess'),
         new = c('Energy Not Used','Loads Not Met','Water Not Used')
         )

# see what cases are
sort(unique(DT_results$case))
# bunch of 46 numbers 1:50 some 40s missing

# see if have all cases {core,pipes, flow}
DT_results[ , list(n = length(case)
                   ), by=core]
#           core  n
# 1:     compact 64
# 2: distributed 82

DT_results[ , list(n = length(case)
), by=layout][order(layout)]
# 24 different layouts, some w/ recirc

DT_results[ , list(n = length(case)
), by=flow]
#    flow  n
# 1:  low 73
# 2:  std 73




# find max values
DT_results[(core == 'distributed' & identifier!='') |
            core == 'compact' ,
           list(max_Wasted_Energy = max(`Wasted Energy`),
                max_Loads_Not_Met = max(`Loads Not Met`),
                max_Wasted_Water = max(`Wasted Water`)
                ),
           by = c('flow','core')
                ]
#    flow        core max_Wasted_Energy max_Loads_Not_Met max_Wasted_Water
# 1:  low     compact          2427.880          2939.532         5.312066
# 2:  std     compact          2366.549          3453.936         5.177879
# 3:  low distributed          2885.546          3129.780         6.313415
# 4:  std distributed          2554.302          3943.074         5.588671


# ordered list of identifiers
l_identifier = DT_results[index %in% 106:125]$identifier

# --- distributed core, normal flow ---
# convert distributed core, normal flow to long data
DT_results_long <-
  melt(DT_results[core == 'distributed' & 
                    flow == 'std' & 
                    identifier!=''],
       id.vars = c('identifier', 'index'),
       measure.vars = c('Wasted Energy',
                        'Loads Not Met')
    )

str(DT_results_long)

# change 'variable' from factor to character
# DT_results_long[ , variable := as.character(variable)]

# set the color choices
colorchoices <- c("Wasted Energy" = "red", 
                  "Loads Not Met" = "blue")

# chart distributed core, normal flow
ggplot(data = DT_results_long) +
  # colums of HW_energy_excess 
  geom_col(aes(x=identifier, y=value, fill=variable),
           position = "dodge", width = .5) +
  
  scale_color_manual(values = colorchoices,
                     aesthetics = c("fill")) +

  # fix the y scale
  scale_y_continuous(limits = c(0,4000)) +
  
  # set for expand the x-axis for labels to fit in group labels
  scale_x_discrete( expand = expand_scale(mult = -0.1, add = 3),
                    # reverse order for when plot flipped
                    limits = rev(l_identifier)) +

  # turn plot on it's side
  coord_flip() +
  
  # fuss with category axis tick labels
  theme(axis.text.y = element_text(vjust = 1,
                                   hjust = 0,
                                   #angle = 90,
                                   size = 5))   +
  
  # add the labels
  labs(title = "Wasted Energy and Loads Not Met",
       subtitle = "distributed core, normal flow",
       y = "energy (BTU)") +
  
  # center the title
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5, size = 5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL,
                             reverse = TRUE)
         ) +
  
  # add some text
  # x values for data range from 1 to 20, for the numbered categories
  annotate("text", 
           x = c(20.5, 15.5, 10.5,  5.5, 3.5), 
           y = 1000, 
           label = c("Trunk and Branch",
                     "Mini-Manifold",
                     "Central Manifold",
                     "Two Water Heaters",
                     "One Trunk "),
           size = 2
  ) +
  
  # adjust text size for png plot
  theme(legend.text = element_text(size = 5)) 
  
  
# save chart
ggsave(filename = paste0("distributed_normal_wasted_energy.png"), path=wd_charts,
       width = 5.25, height = 4 )


# cut and pasted same graph for low flow
# --- distributed core, low flow ---
# convert distributed core, low flow to long data
DT_results_long <-
  melt(DT_results[core == 'distributed' & 
                    flow == 'low' & 
                    identifier!=''],
       id.vars = c('identifier', 'index'),
       measure.vars = c('Wasted Energy',
                        'Loads Not Met')
  )

str(DT_results_long)

# change 'variable' from factor to character
# DT_results_long[ , variable := as.character(variable)]

# set the color choices
colorchoices <- c("Wasted Energy" = "pink", 
                  "Loads Not Met" = "light blue")

# chart distributed core, normal flow
ggplot(data = DT_results_long) +
  # colums of HW_energy_excess 
  geom_col(aes(x=identifier, y=value, fill=variable),
           position = "dodge", width = .5) +
  
  scale_color_manual(values = colorchoices,
                     aesthetics = c("fill")) +
  
  # fix the y scale
  scale_y_continuous(limits = c(0,4000)) +
  
  # set for expand the x-axis for labels to fit in group labels
  scale_x_discrete( expand = expand_scale(mult = -0.1, add = 3),
                    # reverse order for when plot flipped
                    limits = rev(l_identifier)) +
  
  # turn plot on it's side
  coord_flip() +
  
  # fuss with category axis tick labels
  theme(axis.text.y = element_text(vjust = 1,
                                   hjust = 0,
                                   #angle = 90,
                                   size = 5))   +
  
  # add the labels
  labs(title = "Wasted Energy and Loads Not Met",
       subtitle = "distributed core, low flow",
       y = "energy (BTU)") +
  
  # center the title
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5, size = 5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL,
                             reverse = TRUE)
  ) +
  
  # add some text
  # x values for data range from 1 to 20, for the numbered categories
  annotate("text", 
           x = c(20.5, 15.5, 10.5,  5.5, 3.5), 
           y = 1000, 
           label = c("Trunk and Branch",
                     "Mini-Manifold",
                     "Central Manifold",
                     "Two Water Heaters",
                     "One Trunk "),
           size = 2
  ) +
  
  # adjust text size for png plot
  theme(legend.text = element_text(size = 5)) 


# save chart
ggsave(filename = paste0("distributed_low_flow_wasted_energy.png"), path=wd_charts,
       width = 5.25, height = 4 )

