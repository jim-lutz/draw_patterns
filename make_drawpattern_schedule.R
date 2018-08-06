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
DT_1day_drawpatterns <-
  DT_total_drawpatterns[DHWDAYUSE=='3D1' & date=='2009-01-29',]

# count number of enduses 
DT_1day_drawpatterns[,list(ndraws = length(start),
                           totvol = sum(mixedFlow*duration/60)), 
                      by=c('date', 'enduse')
                      ][order(-totvol)]
#          date        enduse ndraws    totvol
# 1: 2009-01-29        Faucet     87 42.459839
# 2: 2009-01-29        Shower      4 21.967499
# 3: 2009-01-29 ClothesWasher     10 12.647866
# 4: 2009-01-29          Bath      1  9.793681
# 5: 2009-01-29    Dishwasher      4  4.999045

names(DT_1day_drawpatterns)
#  [1] "DHWProfile" "DHWDAYUSE"  "bedrooms"   "people"     "yday"       "wday"      
#  [7] "date"       "start"      "enduse"     "duration"   "mixedFlow"  "hotFlow"   
# [13] "coldFlow"  


# add Start Time, date & start in a d/m/yyyy h:m:s format
# build data.table first then worry about formatting and putting into Excel
# https://cran.r-project.org/web/packages/xlsx/xlsx.pdf
DT_1day_drawpatterns[ , Start.Time := paste(date,start)]

# add Fixture ID, B2_SK1,B3_SK, K_SK, LN_WA, MB_SH, MB_SK1, MB_SK2, etc
# for now use 'enduse'
setnames(DT_1day_drawpatterns,'enduse', 'Fixture.ID')

# add Wait for Hot Water? 
# Yes, (for shower, bath, & long 'first' kitchen sink), No (everything else)
DT_1day_drawpatterns[ ,Wait.for.Hot.Water := 'No']
DT_1day_drawpatterns[ Fixture.ID %in% c("Shower", "Bath"), 
                      Wait.for.Hot.Water := 'Yes']

# check that it worked
DT_1day_drawpatterns[,list(nWait.for.Hot.Water = length(Wait.for.Hot.Water),
                           Wait.for.Hot.Water  = unique(Wait.for.Hot.Water)), 
                     by=c('Fixture.ID')
                     ]
#       Fixture.ID nWait.for.Hot.Water Wait.for.Hot.Water
# 1:        Shower                   4                Yes
# 2:        Faucet                  87                 No
# 3:          Bath                   1                Yes
# 4:    Dishwasher                   4                 No
# 5: ClothesWasher                  10                 No
# looks OK

# add Include Behavior Wait? Yes for shower & bath, No for everything else.
DT_1day_drawpatterns[ ,Include.Behavior.Wait := 'No']
DT_1day_drawpatterns[ Fixture.ID %in% c("Shower", "Bath"), 
                      Include.Behavior.Wait := 'Yes']

# check that it worked
DT_1day_drawpatterns[,list(nInclude.Behavior.Wait = length(Include.Behavior.Wait),
                           Include.Behavior.Wait  = unique(Include.Behavior.Wait)), 
                     by=c('Fixture.ID')
                     ]
#       Fixture.ID nInclude.Behavior.Wait Include.Behavior.Wait
# 1:        Shower                      4                   Yes
# 2:        Faucet                     87                    No
# 3:          Bath                      1                   Yes
# 4:    Dishwasher                      4                    No
# 5: ClothesWasher                     10                    No
# looks OK

# add Behavior Wait Trigger, 5 for showers & baths, 
# blank if 'Include Behavior Wait?' is No  (sec)	
DT_1day_drawpatterns[ ,Behavior.Wait.Trigger := 0]
DT_1day_drawpatterns[  Fixture.ID %in% c("Shower", "Bath"),  
                       Behavior.Wait.Trigger := 5]

# check that it worked
DT_1day_drawpatterns[,list(nBehavior.Wait.Trigger = length(Behavior.Wait.Trigger),
                           Behavior.Wait.Trigger  = unique(Behavior.Wait.Trigger)), 
                     by=c('Fixture.ID')
                     ]
#       Fixture.ID nBehavior.Wait.Trigger Behavior.Wait.Trigger
# 1:        Shower                      4                     5
# 2:        Faucet                     87                     0
# 3:          Bath                      1                     5
# 4:    Dishwasher                      4                     0
# 5: ClothesWasher                     10                     0
# looks OK
# set 0 to blank when exporting to Excel









