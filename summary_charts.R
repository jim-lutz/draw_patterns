# summary_charts.R
# script to plot energy wasted and loads not met
# for distributed core, normal flow
# "Tue Oct 16 20:51:41 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the summary results data
load(file = paste0(wd_data,"summary_relative_distributed_norm.Rdata"))

tables()
#           NAME NROW NCOL MB
# 1: DT_relative   42    6  0
# 2:  DT_summary   42    6  0

# work with DT_relative
names(DT_relative)

# change names
setnames(DT_relative,
         old = c("Energy into HWDS (BTU)", "Water into HWDS (gallons)",
                 "Time Water is Flowing (seconds)", "Load not Met (BTU)"),
         new = c('Energy (%)','Water (%)', 'Time (%)', 'Load not Met (%)')
         )

# add wasted energy, water & time, not 'Load not Met (%)', it's already relative to reference
DT_relative[ , `:=` (`Energy Wasted (%)` = `Energy (%)` - 1.0,
                     `Water Wasted (%)`  = `Water (%)` - 1.0, 
                     `Time Wasted (%)`   = `Time (%)` - 1.0)]

# find max values
DT_relative[grep("WH Loc", Identification, invert = TRUE), # exclude these
            list(max_Wasted_Energy = max(`Energy Wasted (%)`),
                 max_Wasted_Water  = max(`Water Wasted (%)`),
                 max_Wasted_Time   = max(`Time Wasted (%)`),
                 max_Loads_Not_Met = max(`Load not Met (%)`)
                )]
#    max_Wasted_Energy max_Wasted_Water max_Wasted_Time max_Loads_Not_Met
# 1:         0.4693084        0.4693084         0.18194         0.2527405

# set the color choices
colorchoices <- c("Energy Wasted (%)" = "red", 
                  "Load not Met (%)" = "blue")

# fix Trunk&Branck - 3 branches
DT_relative[grep("3 branches",Configuration), 
            Configuration := 'Trunk & 3 branches']

names(DT_relative)

# convert long data
DT_relative_long <-
  melt(DT_relative[],
       id.vars = c('Configuration', 'Identification'),
       measure.vars = c('Energy (%)', 'Water (%)', 'Time (%)', 'Load not Met (%)', 
                        'Energy Wasted (%)', 'Water Wasted (%)', 'Time Wasted (%)')
  )

names(DT_relative_long)

# prune DT_relative_long
DT_relative_long <- # exclude these
  DT_relative_long[grep("WH Loc", Identification, invert = TRUE) ] 

DT_relative_long <-  # keep these, Two Heaters & Not use 1 inch pipe = -1
  DT_relative_long[ value > 0 ]

DT_relative_long <- # exclude skinny pipes
  DT_relative_long[grep("pipe", Identification, invert = TRUE)]

DT_relative_long <- # only keep these variables
  DT_relative_long[ variable == 'Energy Wasted (%)' |
                    variable == 'Load not Met (%)' ]

str(DT_relative_long)

# get original order of Identification
Identification_levels <- rev(DT_relative[2:21, Identification])

# set Identification as order factor
DT_relative_long[ , 
                  Identification := factor(Identification, 
                           levels = Identification_levels)]

# chart using data from pruned DT_relative_long
ggplot(data = DT_relative_long) +
  
  # colums of 'Energy Wasted (%)' and 'Load not Met (%)'
  geom_col(aes(x=Identification, y=value, fill=variable),
         position = "dodge", width = .5) +
  
  # turn plot on it's side
  coord_flip() +

  # fuss with category axis tick labels
  theme(axis.text.y = element_text(vjust = .5, hjust = 0, size = 6)) + # 
  
  # add the labels
  labs(title = "Wasted Energy and Loads Not Met",
       subtitle = "distributed core, normal flow" ) +
  
  # remove the Identification label
  xlab("") +
  
  # set for expand the x-axis for labels to fit in group labels
  scale_x_discrete( expand = expand_scale(mult = -0.1, add = 3)) +
  
  # label the percentages
  scale_y_continuous(name = 'Percent', 
                     labels = c('0%','10%','20%','30%','40%','50%'), limits = NULL,
                     expand = waiver(), na.value = NA_real_,
                     trans = "identity", position = "left", sec.axis = waiver()) +

  # center the title
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) + #, size = 10
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL, reverse = TRUE)) +
  
  # add some text
  # x values for data range from 1 to 20, for the numbered categories
  annotate("text", 
           x = c(20.5, 15.5, 10.5,  5.5, 3.5), 
           y = .1, hjust = 0,
           label = c("Trunk and Branch",
                     "Mini-Manifold",
                     "Central Manifold",
                     "Two Water Heaters",
                     "One Trunk ")
           , size = 2
           ) + #
  
  # adjust text size for png plot
  theme(legend.text = element_text(size = 5)) 

# get date to include in file name
d <- format(Sys.time(), "%F")

# save chart
ggsave(filename = paste0("distributed_normal_wasted_energy_",d,".png"), 
       path=wd_charts) # , width = 5.25, height = 4 
# Saving 6.21 x 4.42 in image
