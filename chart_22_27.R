# chart_22_27.R
# a macro to make charts for table 22 & 27 from draft final report v.10
# Compact Wet Room Layouts, Small Pipe, Normal | Low Flow
# uses
#   DT_relative_long_chart    the data
#   tn                        the table number

# find the png file name parameters
DT_chart_params <-
  DT_relative_long[table==tn,
                   list(core      = unique(core),
                        flow      = unique(flow),
                        smallpipe = unique(smallpipe))]

# build the png filename for the chart
fn <-
  with(DT_chart_params,
       {
         pipe<-ifelse(smallpipe,"small","norm")
         paste0(core,"_core_",pipe,"_pipe_",flow,"_flow")
       }
  )

# get the data
DT_relative_long_chart <-
  DT_relative_long[ table == tn, ]

DT_relative_long_chart[, list(Identification, Configuration, PipeSize,table)]
# don't forget both energy wasted and loads not met are in here

# order by Identification as the tick mark labels
# gap by PipeSize in big groups, text centered
# gap by Configuration in small groups, text left justified

# add an index to get the right order of data 
# since  neither Configuration or Identification or PipeSize is unique
# this is one letter per pair of columns
# these are the x values in the plot
DT_relative_long_chart[, Identification.values:= c(letters[1:24],letters[1:24])]

str(DT_relative_long_chart)

# get the order of Identification for labels on chart, 
# this is not used for ordering the data 
# these will be the tick mark labels
Identification.labels <- DT_relative_long_chart[variable=="Load not Met (%)"]$Identification

# get list of PipeSize
unique(DT_relative_long_chart$PipeSize)
# [1] "Use 3/8 pipe"                       "Not use 1 inch pipe"               
# [3] "Use 3/8 pipe & Not use 1 inch pipe"

# get list of Configuration
unique(DT_relative_long_chart$Configuration)
# [1] "Trunk & 3 Branches"   "Hybrid Mini-Manifold" "Central Manifold"    
# [4] "One-zone w/o Recirc" 

# add gaps before each group of PipeSize and Configuration
Identification.labels <- 
  c("",                  #"Use 3/8 pipe"      
    "", Identification.labels[1:2],   # Trunk & 3 Branches
    "", Identification.labels[3:4],   # Hybrid Mini-Manifold
    "", Identification.labels[5:6],   # Central Manifold
    "", Identification.labels[7:8],   # One-zone w/o Recirc
    "",                  # "Not use 1 inch pipe"
    "", Identification.labels[9:10],   # Trunk & 3 Branches
    "", Identification.labels[11:12],   # Hybrid Mini-Manifold
    "", Identification.labels[13:14],   # Central Manifold
    "", Identification.labels[15:16],   # One-zone w/o Recirc
    "",                  #"Use 3/8 pipe & Not use 1 inch pipe"      
    "", Identification.labels[17:18],   # Trunk & 3 Branches
    "", Identification.labels[19:20],   # Hybrid Mini-Manifold
    "", Identification.labels[21:22],   # Central Manifold
    "", Identification.labels[23:24])   # One-zone w/o Recirc


# reverse it so it will show up in right order in the charts
Identification.labels <- rev(Identification.labels)

# make the limits
# A character vector that defines possible values of the scale and their order.
DT_relative_long_chart$Identification.values
Identification.limits <- c( " ", " ", "a", "b",
                            " ", "c", "d",
                            " ", "e", "f", 
                            " ", "g", "h", 
                            " ", " ", "i", "j",
                            " ", "k", "l",
                            " ", "m", "n",
                            " ", "o", "p",
                            " ", " ", "q", "r",
                            " ", "s", "t",
                            " ", "u", "v",
                            " ", "w", "x"
                            )

# chart using the data 
ggplot(data = DT_relative_long_chart) +
  
  # colums of 'Energy Wasted (%)' and 'Load not Met (%)'
  geom_col(aes(x=Identification.values, 
               y=value, fill=variable),
           position = "dodge", width = .5) +

  # specify the right order
  scale_x_discrete(  limits = rev(Identification.limits),
                     labels = Identification.labels) +
  
  # turn plot on it's side
  coord_flip() +
  
  # remove the Identification label on the X axis
  xlab("") +
  
  # label the percentages
  scale_y_continuous(name = 'Percent', 
                     labels = c('0%','10%','20%','30%','40%','50%'), 
                     breaks=c(0,0.1,0.2,0.3,0.4,0.5),
                     limits = c(0, 0.5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL, reverse = TRUE)) +
  
  # add some text to group by PipeSize
  annotate("text", 
           x = c(39,26,13 ),  # from Identification.labels 
           y = .3, hjust = 0.5,
           label = c("Use 3/8 pipe", "Not use 1 inch pipe", 
                     "Use 3/8 pipe & Not use 1 inch pipe"),
           # from unique(DT_relative_long_chart[]$PipeSize)
           size = 4
  ) + 

  # add some text to group by Configuration
  annotate("text", 
           x = c(38,35,32,29,
               25,22,19,16,
               12,9,6,3), # from Identification.labels 
           y = 0.0, hjust = 0,
           label = rep(
             c("Trunk & 3 Branches", "Hybrid Mini-Manifold",
               "Central Manifold", "One-zone w/o Recirc"), times = 3),
           # from unique(DT_relative_long_chart[]$Configuration)
           size = 3
  ) + 
  # specify color of bars gray and black for photocopying
  scale_colour_manual(values = c("gray74", "black"),
                      aesthetics = c("colour", "fill")) +
  
  # specify location of legend
  theme(legend.position = "bottom", # c(0.9, .95),
        legend.background = element_rect( size=0.25, 
                                          linetype="solid",
                                          color = "black")
  )

# get date to include in file name
d <- format(Sys.time(), "%F")

# save chart
ggsave(filename = paste0("relative_",fn,"_",d,".png"), 
       path=wd_charts) # , width = 5.25, height = 4 
# Saving 6.21 x 4.42 in image
