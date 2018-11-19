# assign.tables.R
# code to assign tables according to version 10 of draft final report


# TABLE 19 Distributed Wet Room Layouts, Normal Pipe, Normal Flow
DT_relative[core == 'dist' & smallpipe==FALSE & flow == 'norm' & 
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table
DT_relative[core == 'dist' & smallpipe==FALSE & flow == 'norm' & 
              Configuration != 'Reference',
            table := '19']


# TABLE 20 Distributed Wet Room Layouts, Small Pipe, Normal Flow
# find data
DT_relative[core == 'dist' & smallpipe==TRUE & flow == 'norm' & 
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'dist' & smallpipe==TRUE & flow == 'norm' & 
              Configuration != 'Reference',
            table := '20']

DT_relative[core == 'dist' & smallpipe==TRUE & flow == 'norm' & 
              Configuration != 'Reference']
# caution, Two Heaters, use 3/8 pipe & Not use 1 inch pipe and
# Two Heaters, Not use 1 inch pipe don't exist, 
# data is meaningless


# TABLE 21 Compact Wet Room Layouts, Normal Pipe, Normal Flow
# find data
DT_relative[core == 'compact' & smallpipe==FALSE & flow == 'norm' &
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'compact' & smallpipe==FALSE & flow == 'norm' &
              Configuration != 'Reference',
            table := '21']


# TABLE 22 Compact Wet Room Layouts, Small Pipe, Normal Flow
# find data
DT_relative[core == 'compact' & smallpipe==TRUE & flow == 'norm' &
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'compact' & smallpipe==TRUE & flow == 'norm' &
              Configuration != 'Reference',
            table := '22']
# Configuration doesn't match that in report
# Should add a 3rd variable for pipe size


# TABLE 24 Distributed Wet Room Layouts, Normal Pipe, Low Flow
# find data
DT_relative[core == 'dist' & smallpipe==FALSE & flow == 'low' &
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'dist' & smallpipe==FALSE & flow == 'low' &
              Configuration != 'Reference',
            table := '24']


# TABLE 25 Distributed Wet Room Layouts, Small Pipe, Low Flow
# find data
DT_relative[core == 'dist' & smallpipe==TRUE & flow == 'low' & 
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'dist' & smallpipe==TRUE & flow == 'low' & 
              Configuration != 'Reference',
            table := '25']
# caution, Two Heaters, use 3/8 pipe & Not use 1 inch pipe and
# Two Heaters, Not use 1 inch pipe don't exist, 
# data is zero


# TABLE 26  Compact Wet Room Layouts, Normal Pipe, Low Flow
# find data
DT_relative[core == 'compact' & smallpipe==FALSE & flow == 'low' &
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'compact' & smallpipe==FALSE & flow == 'low' &
              Configuration != 'Reference',
            table := '26']
# Configuration doesn't match that in report


# TABLE 27   Compact Wet Room Layouts, Small Pipe, Low Flow
# find data
DT_relative[core == 'compact' & smallpipe==TRUE & flow == 'low' &
              Configuration != 'Reference',
            list(Configuration, Identification, `Load not Met (%)`),]

# assign table 
DT_relative[core == 'compact' & smallpipe==TRUE & flow == 'low' &
              Configuration != 'Reference',
            table := '27']
# Configuration doesn't match that in report
# Should add a 3rd variable for pipe size

# check got 8 tables
DT_relative[,list(n=length(Configuration)),by=table][order(table)]

