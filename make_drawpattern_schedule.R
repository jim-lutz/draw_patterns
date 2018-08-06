# make_drawpattern_schedule.R
# script to build an input file for one day draw pattern for spreadsheet model.
# Jim Lutz "Mon Aug  6 11:57:02 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

#  load DT_total_drawpatterns.Rdata
load( file = paste0(wd_data,"DT_total_drawpatterns.Rdata"))

DT_total_drawpatterns
names(DT_total_drawpatterns)

# start with DHWDAYUSE 3D1 & 3 bedrooms
DT_total_drawpatterns[DHWDAYUSE=='3D1' & bedrooms==3,]

# how many days?
DT_total_drawpatterns[DHWDAYUSE=='3D1' & bedrooms==3, 
                      list(date=unique(date)), by=yday][
  order(date)]
# 11

# get the first one
DT_total_drawpatterns[DHWDAYUSE=='3D1' & date=='2009-01-29',]

# count number of enduses 
DT_total_drawpatterns[DHWDAYUSE=='3D1' & date=='2009-01-29',
                      list(ndraws = length(start),
                           totvol = sum(mixedFlow*duration/60)), 
                      by=c('date', 'enduse')
                      ][order(-totvol)]
#          date        enduse ndraws    totvol
# 1: 2009-01-29        Faucet     87 42.459839
# 2: 2009-01-29        Shower      4 21.967499
# 3: 2009-01-29 ClothesWasher     10 12.647866
# 4: 2009-01-29          Bath      1  9.793681
# 5: 2009-01-29    Dishwasher      4  4.999045






