# summary_charts.R
# script to plot relative energy wasted and loads not met
# for all 8 combinations {flow, core, pipe size}
# "Tue Oct 16 20:51:41 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load all four relative data.tables then recombine

# load the summary results data
# first distributed_norm
load(file = paste0(wd_data,"summary_relative_distributed_norm.Rdata"))

tables()
#           NAME NROW NCOL MB
# 1: DT_relative   42    6  0
# 2:  DT_summary   42    6  0

# remove the summary table
rm(DT_summary)

# rename the relative table 
# this actually just relinks to the same data, since nothing is modified
DT_relative_dist_norm <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# then distributed_low
load(file = paste0(wd_data,"summary_relative_distributed_low.Rdata"))

tables()

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_dist_low <- DT_relative
# remove the DT_relative name
rm(DT_relative)


# then compact_norm
load(file = paste0(wd_data,"summary_relative_compact_norm.Rdata"))

tables()

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_compact_norm <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# then compact_low
load(file = paste0(wd_data,"summary_relative_compact_low.Rdata"))

tables()

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_compact_low <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# combine all four tables
DT_relative <-
  rbindlist(list(DT_relative_dist_norm, DT_relative_dist_low,
                 DT_relative_compact_norm, DT_relative_compact_low))

# work with DT_relative
str(DT_relative)
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
DT_relative[,
            list(max_Wasted_Energy = max(`Energy Wasted (%)`),
                 max_Wasted_Water  = max(`Water Wasted (%)`),
                 max_Wasted_Time   = max(`Time Wasted (%)`),
                 max_Loads_Not_Met = max(`Load not Met (%)`)
                )]
#    max_Wasted_Energy max_Wasted_Water max_Wasted_Time max_Loads_Not_Met
# 1:         0.9434275        0.5608854       0.1820058         0.2527405

# look at the really bad energy wasters
DT_relative[`Energy Wasted (%)` > .5]
# it's the recircs

# remove the recircs w/ manual & timer
DT_relative <-
  DT_relative[!(str_detect(Configuration, "recirc") &
                str_detect(Configuration, "w/ ") ) ,
              ]

# list of all the Configuration
DT_relative[ , list(unique(Configuration))]

# what's with the " 3 branches"?
DT_relative[ str_detect(Configuration, "3 branches") , 
             list(Configuration, Identification)]
# some are distributed core, others are small pipes

# make the " 3 branches" consistent
DT_relative[ str_detect(Configuration, "3 branches") , 
             Configuration := "Trunk&Branch - 3 branches"]

# list of all the Identification
DT_relative[ , list(Configuration, Identification)]
# looks OK

# remove 'Energy (%)', 'Water (%)', 'Time (%)', 'Water Wasted (%)', 'Time Wasted (%)'
DT_relative[ , c('Energy (%)', 'Water (%)', 
                 'Time (%)', 'Water Wasted (%)', 
                 'Time Wasted (%)') := NULL
             ]

names(DT_relative)
# 138 rows

# convert to long data
DT_relative_long <-
  melt(DT_relative[],
       id.vars = c('Configuration', 'Identification'),
       measure.vars = c("Load not Met (%)", "Energy Wasted (%)")
  )

names(DT_relative_long)

# set the color choices, using grey and black for photocopying
colorchoices <- c("Energy Wasted (%)" = "gray74", 
                  "Load not Met (%)" = "black")



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

# save as csv
write_excel_csv(DT_relative_long,
                path = paste0(wd_data, "distributed_normal_wasted_energy_2018-10-16.csv"),
                na = "")

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
