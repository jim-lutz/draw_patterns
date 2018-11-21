# chart_20_25.R
# a macro to make charts for table 20 & 25 from draft final report v.10
# Distributed Wet Room Layouts, Small Pipe, Normal | Low Flow
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

# list the PipeSizes
DT_relative_long_chart[variable=="Load not Met (%)",list(unique(PipeSize))]

# remove data for Two Heaters that do not Use 3/8 pipe
DT_relative_long_chart[value==0 | value==-1 , value:=NA]

# add an index to get the right order of data 
# since Configuration is not unique per columns on the graph
# this is one letter per column
# these are the x values in the plot
DT_relative_long_chart[, Configuration.values:= c(letters[1:15],letters[1:15])]

str(DT_relative_long_chart)

# get the order of Configuration for labels on chart, 
# this is not used for ordering the data 
# these will be the tick mark labels
Configuration.labels <- DT_relative_long_chart[variable=="Load not Met (%)"]$Configuration

# add gaps before each group of PipeSize
Configuration.labels <- 
  c("", Configuration.labels[1:5],    # Use 3/8 pipe
    "", Configuration.labels[6:10],   # Not use 1 inch pipe
    "", Configuration.labels[11:15])  # Use 3/8 pipe & Not use 1 inch pipe

# reverse it so it will show up in right order in the charts
Configuration.labels <- rev(Configuration.labels)

# make the limits
# A character vector that defines possible values of the scale and their order.
Configuration.limits <- c( " ", "a", "b", "c", "d", "e", 
                            " ", "f", "g", "h", "i", "j",
                            " ", "k", "l", "m", "n", "o")


# chart using the data 
ggplot(data = DT_relative_long_chart) +
  
  # colums of 'Energy Wasted (%)' and 'Load not Met (%)'
  geom_col(aes(x=Configuration.values, 
               y=value, fill=variable),
           position = "dodge", width = .5) +

  # specify the right order
  scale_x_discrete( limits = rev(Configuration.limits),
                    labels = Configuration.labels) +

  # turn plot on it's side
  coord_flip() +
  
  # remove the Identification label
  xlab("") +
  
  # label the percentages
  scale_y_continuous(name = 'Percent', 
                     labels = c('0%','10%','20%','30%','40%','50%','60%'), 
                     breaks=c(0,0.1,0.2,0.3,0.4,0.5,0.6),
                     limits = c(0, 0.6)) +
  
  # clean up the legend
  guides(fill = guide_legend(title = NULL, reverse = TRUE)) +
  
  # add some text to group by pipe size
  annotate("text", 
           x = c(18,12,6 ),  # from Configuration.limits 
           y = .2, hjust = 0,
           label = c("Use 3/8 pipe", "Not use 1 inch pipe",
                     "Use 3/8 pipe & Not use 1 inch pipe"),
           size = 4
  ) + #
  
  # add some text to about the missing data
  annotate("text", 
           x = c(8,2),  # tick mark location
           y = .1, hjust = 0,
           label = c("(This case didn't have any 1 inch pipe)", 
                     "(This case didn't have any 1 inch pipe)"),
           size = 2
  ) + #
  
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
