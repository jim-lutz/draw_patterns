# chart_19_24.R
# a macro to make charts for table 19 & 24 from draft final report v.10
# Distributed Wet Room Layouts, Normal Pipe, Normal | Low Flow
# uses
#   DT_relative_long_chart    the data
#   tn                        the table number

# set the color choices, using grey and black for photocopying
colorchoices <- c("Energy Wasted (%)" = "gray74", 
                  "Load not Met (%)" = "black")

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

DT_relative_long_chart[, list(Identification, Configuration, table)]
# don't forget both energy wasted and loads not met are in here

str(DT_relative_long_chart)

# get the order for Identification
Identification.order <- DT_relative_long_chart[variable=="Load not Met (%)"]$Identification

# add gaps before each group of Configuration
Identification.order <- 
  c("", Identification.order[1:5],    # Trunk & 3 Branches
    "", Identification.order[6:10],   # Hybrid Mini-Manifold
    "", Identification.order[11:15],  # Central Manifold
    "", Identification.order[16:17],  # Two Heaters
    "", Identification.order[18:20])  # One-zone w/o Recirc

# reverse it so it will show up in right order in the charts
Identification.order <- rev(Identification.order)

# chart using this data 
ggplot(data = DT_relative_long_chart) +
  
  # colums of 'Energy Wasted (%)' and 'Load not Met (%)'
  geom_col(aes(x=Identification, y=value, fill=variable),
           position = "dodge", width = .5) +
  
  # get specify the right order
  scale_x_discrete(limits = Identification.order) +
  
  # turn plot on it's side
  coord_flip() +
  
  # remove the Identification label
  xlab("") +
  
  # label the percentages
  scale_y_continuous(name = 'Percent', 
                     labels = c('0%','10%','20%','30%','40%','50%'), 
                     breaks=c(0,0.1,0.2,0.3,0.4,0.5),
                     limits = c(0, 0.5)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL, reverse = TRUE)) +
  
  # add some text
  annotate("text", 
           x = c(25, 19, 13,  7, 4),  # find from Identification.order 
           y = .1, hjust = 0,
           label = unique(DT_relative_long_chart$Configuration),
           size = 4
  ) + #
  
  # specify color of bars
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
