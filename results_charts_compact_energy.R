# results_charts_compact_energy.R
# script to plot energy wasted and loads not met
# for compact core
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
         new = c('Wasted Energy','Loads Not Met','Wasted Water')
         )


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

# change from wet room rectangle to laundry
DT_results[core == 'compact', list(n=.N), by=WH_location ]
DT_results[core == 'compact' & 
             WH_location == 'WH in wet room rectangle', 
           WH_location := 'laundry']
DT_results[core == 'compact' & 
             WH_location == 'WH in garage', 
           WH_location := 'garage']
str(DT_results)

names(DT_results)

# figure out what to plot
DT_results[core == 'compact' , list(case, layout, flow, WH_location)]
DT_results[core == 'compact' , list(case, layout, flow, WH_location, identifier)]

# different charts for std|low
# split layout into layout and pipe_size
# different facets for pipe_size
#   need column for pipe_size 'current practice', '3/8 pipe', 'no 1 inch' '3/8 pipe & no 1 inch'
# melt id.vars flow, pipe_size, layout, WH_location
#   measure.vars c('Wasted Energy', 'Loads Not Met'))

# split layout into layout and pipe_size
DT_results[core == 'compact', list(n=.N),by=layout]

# layout2
DT_results[core == 'compact' & str_detect(layout, 'Trunk&Branch'), 
           layout2 := 'Trunk&Branch']
DT_results[core == 'compact' & str_detect(layout, 'Mini-manifold'), 
           layout2 := 'Mini-manifold']
DT_results[core == 'compact' & str_detect(layout, 'Home Run'), 
           layout2 := 'Home Run']
DT_results[core == 'compact' & str_detect(layout, 'One-zone'), 
           layout2 := 'One-zone']
DT_results[core == 'compact', list(n=.N),by=layout2]

# pipe_size
DT_results[core == 'compact' & !str_detect(layout, 'pipe'), 
           pipe_size := 'current practice']
DT_results[core == 'compact' & str_detect(layout, "& 3/8 pipe$"), 
           pipe_size := '3/8 pipe']
DT_results[core == 'compact' & str_detect(layout, '& 3/8 pipe & no 1 inch pipe'), 
           pipe_size := '3/8 pipe & no 1 inch pipe']
DT_results[core == 'compact' & is.na(pipe_size), 
           pipe_size := 'no 1 inch pipe']
DT_results[core == 'compact', list(n=.N),by=pipe_size]

# clean up layout
DT_results[ , layout := NULL]
setnames(DT_results, old = c('layout2'), new = c('layout'))

# check layout and pipe_size
DT_results[core == 'compact', list(n=.N),by=c('layout','pipe_size')]

# add a pipe_size_factor in the desired order
DT_results[core == 'compact', 
           pipe_size_factor := factor(pipe_size, 
                                      levels=c('current practice',
                                               '3/8 pipe',
                                               'no 1 inch pipe',
                                               '3/8 pipe & no 1 inch pipe')
                                      )
           ]

# --- compact core, normal flow ---
# convert compact core, normal flow to long data
DT_results_long <-
  melt(DT_results[core == 'compact'],
       id.vars = c('flow', 'pipe_size_factor', 'layout', 'WH_location'),
       measure.vars = c('Wasted Energy',
                        'Loads Not Met')
    )

str(DT_results_long)

# change 'variable' from factor to character
# DT_results_long[ , variable := as.character(variable)]

# set the color choices
colorchoices <- c("Wasted Energy" = "red", 
                  "Loads Not Met" = "blue")

# for testing
test_flow = 'std'
test_pipe_size = 'current practice'
test_layout = NULL


# chart distributed core, flow
ggplot(data = DT_results_long[flow==test_flow],
       aes(label=WH_location)) +
  # colums of HW_energy_excess 
  geom_col(aes(x=WH_location, y=value, fill=variable),
           position = "dodge", width = .5) +
  
  scale_color_manual(values = colorchoices,
                     aesthetics = c("fill")) +
  
  # fix the y scale
  scale_y_continuous(limits = c(0,4000)) +
  
  # facet
  facet_wrap(vars(layout)) +
  # facet_wrap(vars(pipe_size_factor))
  
  # add the labels
  labs(title = "Wasted Energy and Loads Not Met",
       subtitle = "compact core, normal flow",
       y = "energy (BTU)",
       x = "water heater location") +
  
  # center the title
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL)
         ) +

    # adjust text size for png plot
  theme(legend.text = element_text(size = 5)) 
  
  
# save chart
ggsave(filename = paste0("compact_normal_wasted_energy.png"), path=wd_charts,
       width = 5.25, height = 4 )


# --- compact core, normal flow, trunk&branch ---
# facet by pipe_size_factor

# chart distributed core, flow
ggplot(data = DT_results_long[flow==test_flow & layout=='Trunk&Branch'],
       aes(label=WH_location)) +
  # colums of HW_energy_excess 
  geom_col(aes(x=WH_location, y=value, fill=variable),
           position = "dodge", width = .5) +
  
  scale_color_manual(values = colorchoices,
                     aesthetics = c("fill")) +
  
  # fix the y scale
  scale_y_continuous(limits = c(0,4000)) +
  
  # facet
  facet_wrap(vars(pipe_size_factor)) +
  
  # add the labels
  labs(title = "Wasted Energy and Loads Not Met",
       subtitle = "compact core, normal flow trunk & branch by pipe size",
       y = "energy (BTU)",
       x = "water heater location") +
  
  # center the title
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL)
  ) +
  
  # adjust text size for png plot
  theme(legend.text = element_text(size = 5)) 


# save chart
ggsave(filename = paste0("compact_normal_TB_pipe_size_wasted_energy.png"), path=wd_charts,
       width = 5.25, height = 4 )


