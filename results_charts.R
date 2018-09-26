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

# convert distributed core, normal flow to long data
DT_results_long <-
  melt(DT_results[core == 'distributed' & 
                    flow == 'std' & 
                    !is.na(identifier)],
       id.vars = c('identifier'),
       measure.vars = c('HW_energy_excess',
                        'HW_energy_not_met')
    )

# chart distributed core, normal flow
ggplot(data = DT_results_long) +
  # colums of HW_energy_excess 
  geom_col(aes(x=identifier, y=value, fill=variable),
           position = "dodge", width = .5) +
  # rotate axis tick labels
  theme(axis.text.x = element_text(angle = 90, 
                                   hjust = 1,
                                   size = 10)) +
  coord_flip()



  # colums of HW_energy_excess 
  geom_col(aes(x=identifier, y=HW_energy_not_met),
           width =.1, position = "dodge", color='red') 
  
  
  DT_results[core == 'distributed' & flow == 'std' & !is.na(identifier),
           list(case, layout, identifier, 
                HW_energy_excess, HW_volume_excess)][order(case)]
