# summary_charts.R
# script to plot relative energy wasted and loads not met
# for all 8 combinations {flow, core, pipe size}
# table numbers are from Draft Final Report v10
# "Tue Oct 16 20:51:41 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load all four relative data.tables then recombine

# load the summary relative results data
source("load.summary_relative_data.R")

# work with DT_relative
str(DT_relative)
names(DT_relative)

# change names
setnames(DT_relative,
         old = c("Energy into HWDS (BTU)", "Water into HWDS (gallons)",
                 "Time Water is Flowing (seconds)", "Load not Met (BTU)"),
         new = c('Energy (%)','Water (%)', 'Time (%)', 'Load not Met (%)')
         )

# add wasted energy, water & time, 
# not 'Load not Met (%)', it's already relative to reference
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
DT_relative[ , list(n=length(Identification)), by=Configuration]

# what's with the " 3 branches"?
DT_relative[ str_detect(Configuration, "3 branches") , 
             list(Configuration, Identification)]
# some are distributed core, others are small pipes

# make the " 3 branches" consistent
DT_relative[ str_detect(Configuration, "3 branches") , 
             Configuration := "Trunk&Branch - 3 branches"]

# list of all the Identification
DT_relative[ , list(n=length(Configuration)), by=Identification]
# looks OK?

# add a pipe size variable
DT_relative[ , smallpipe:=FALSE]
DT_relative[ str_detect(Configuration, "pipe"), smallpipe:=TRUE]
DT_relative[ str_detect(Identification, "pipe"), smallpipe:=TRUE]

# look at the small pipes
DT_relative[ str_detect(Configuration, "pipe"), 
             list(n=length(Identification)), by=Configuration]
DT_relative[ str_detect(Identification, "pipe"), 
             list(n=length(Configuration)), by=Identification]

# change 'WH in NE garage' to 'WH in garage'
DT_relative[ Identification  == 'WH in NE garage',
             Identification := 'WH in garage']
# need to check this

# look at the Reference cases
DT_relative[ Configuration == 'Reference']
# it's value is only 0, so actually don't need it.

# assign the data to tables as numbered in draft final report v10
source("assign.tables.R")

# assign PipeSize and remove PipeSize from Configuration
source("PipeSize.R")

# fix Configuration
source("fix.Configuration.R")

# fix Identification and set PipeSize for tables 20 & 25
source("fix.Identification.R")

# check that everything is ready to go
DT_relative[,list(n=length(Configuration)), by = PipeSize]
# PipeSize is blank for standard pipe sizing

DT_relative[,list(n=length(unique(Identification))), by = PipeSize]

DT_relative[,list(n=length(unique(Configuration))), by = PipeSize]

DT_relative[,list(n=length(unique(Identification))), by = table][order(table)]

DT_relative[,list(n=length(unique(Configuration))), by = table][order(table)]

DT_relative[table %in% c("20",'21','22',"25",'26','27'),
            list(Identification=unique(Identification)), by = table][order(table)]




# convert to long data, so can group by load not met or energy wasted
DT_relative_long <-
  melt(DT_relative[],
       id.vars = c('Configuration', 'Identification', 'PipeSize', 'table',
                   'flow', 'core', 'smallpipe'),
       measure.vars = c("Load not Met (%)", "Energy Wasted (%)")
  )

names(DT_relative_long)
str(DT_relative_long)


# set the color choices, using grey and black for photocopying
colorchoices <- c("Energy Wasted (%)" = "gray74", 
                  "Load not Met (%)" = "black")


# chart for table 19
# Distributed Wet Room Layouts, Normal Pipe, Normal Flow

# make a file name
fn <- "Distributed_Wet_Room_Layouts_Normal_Pipe_Normal_Flow"

# find the data
DT_relative_long_19 <-
DT_relative_long[ table == '19', ]

DT_relative_long_19[, list(Identification, Configuration, table)]
# don't forget both energy wasted and loads not met are in here

str(DT_relative_long_19)

# get the order for Identification
Identification.order <- DT_relative_long_19[variable=="Load not Met (%)"]$Identification

# add gaps before each group of Configuration
Identification.order <- 
  c("", Identification.order[1:5],    # Trunk & 3 Branches
    "", Identification.order[6:10],   # Hybrid Mini-Manifold
    "", Identification.order[11:15],  # Central Manifold
    "", Identification.order[16:17],  # Two Heaters
    "", Identification.order[18:20])  # One-zone w/o Recirc

# reverse it so it show up in right order in chart
Identification.order <- rev(Identification.order)
  
# save as csv
write_excel_csv(DT_relative_long_19,
                path = paste0(wd_data, fn, ".csv"),
                na = "")

# chart using this data 
ggplot(data = DT_relative_long_19) +
  
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
                     labels = c('0%','10%','20%','30%','40%','50%'), limits = NULL,
                     expand = waiver(), na.value = NA_real_,
                     trans = "identity", position = "left", sec.axis = waiver()) +

  # clean up the legend
  guides(fill = guide_legend(title = NULL, reverse = TRUE)) +
  
  # add some text
  annotate("text", 
           x = c(25, 19, 13,  7, 4),  # find from Identification.order 
           y = .1, hjust = 0,
           label = unique(DT_relative_long_19$Configuration),
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
  
  #   # adjust text size for png plot
  # theme(legend.text = element_text(size = 5)) 

# get date to include in file name
d <- format(Sys.time(), "%F")

# save chart
ggsave(filename = paste0("relative_",fn,"_",d,".png"), 
       path=wd_charts) # , width = 5.25, height = 4 
# Saving 6.21 x 4.42 in image
