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

# find max values
DT_relative[,
            list(max_Wasted_Energy = max(`Energy Wasted (%)`),
                 max_Wasted_Water  = max(`Water Wasted (%)`),
                 max_Wasted_Time   = max(`Time Wasted (%)`),
                 max_Loads_Not_Met = max(`Load not Met (%)`)
            )]
#    max_Wasted_Energy max_Wasted_Water max_Wasted_Time max_Loads_Not_Met
# 1:         0.5608854        0.5608854       0.1820058         0.2527405
# set max to 60% across all charts


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

# save as csv
write_excel_csv(DT_relative,
                path = paste0(wd_data, "data_relative_charts.csv"),
                na = "")


# convert to long data, so can group by loads not met and energy wasted
DT_relative_long <-
  melt(DT_relative[],
       id.vars = c('Configuration', 'Identification', 'PipeSize', 'table',
                   'flow', 'core', 'smallpipe'),
       measure.vars = c("Load not Met (%)", "Energy Wasted (%)")
  )

names(DT_relative_long)
str(DT_relative_long)

# start making the charts

# table 19  Distributed Wet Room Layouts, Normal Pipe, Normal Flow
tn <- '19' 
# source("chart_19_24.R") # make the chart

# table '24' # Distributed Wet Room Layouts, Normal Pipe, Low Flow
tn <- '24'
# source("chart_19_24.R") # make the chart

# table 20 Distributed Wet Room Layouts, Small Pipe, Normal Flow 
tn <- '20'
# source("chart_20_25.R") # make the chart

# table 25 Distributed Wet Room Layouts, Small Pipe, Low Flow 
tn <- '25'
# source("chart_20_25.R") # make the chart

# table 21  Compact Wet Room Layouts, Normal Pipe, Normal Flow
tn <- '21'
# source("chart_21_26.R") # make the chart

# table 26  Compact Wet Room Layouts, Normal Pipe, Low Flow 
tn <- '26'
# source("chart_21_26.R") # make the chart

# table 22  Compact Wet Room Layouts, Small Pipe, Normal Flow
tn <- '22'
source("chart_22_27.R") # make the chart


