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

# build data.table first then worry about formatting and putting into Excel
# https://cran.r-project.org/web/packages/xlsx/xlsx.pdf

# add Start Time, date & start in a d/m/yyyy h:m:s format
DT_1day_drawpatterns[ , Start_Time := paste(date,start)]

# add Fixture ID, B2_SK1,B3_SK, K_SK, LN_WA, MB_SH, MB_SK1, MB_SK2, etc
# for now use enter a blank
DT_1day_drawpatterns[ , Fixture_ID := ' ']

# add Event Type, 
# for now enter 'Use'
DT_1day_drawpatterns[ , Event_Type := 'Use']

# add Wait for Hot Water? 
# Yes, (for shower, bath, & long (>= 1 min) faucet), No (everything else)
DT_1day_drawpatterns[ , Wait_for_Hot_Water := 'No']
DT_1day_drawpatterns[ enduse %in% c("Shower", "Bath"), 
                      Wait_for_Hot_Water := 'Yes']
DT_1day_drawpatterns[ enduse=="Faucet" & duration>=60, 
                      Wait_for_Hot_Water := 'Yes']

# check that it worked
DT_1day_drawpatterns[,list(n                     = length(start),
                           Wait_for_Hot_Water    = unique(Wait_for_Hot_Water)), 
                     by=c('enduse') ]
#           enduse  n Wait_for_Hot_Water
# 1:        Shower  4                Yes
# 2:        Faucet 87                 No
# 3:        Faucet 87                Yes
# 4:          Bath  1                Yes
# 5:    Dishwasher  4                 No
# 6: ClothesWasher 10                 No
# looks OK

# add Include Behavior Wait? Yes for shower & bath, No for everything else.
DT_1day_drawpatterns[ , Include_Behavior_Wait := 'No']
DT_1day_drawpatterns[ enduse %in% c("Shower", "Bath"), 
                      Include_Behavior_Wait := 'Yes']

# check that it worked
DT_1day_drawpatterns[,list(n                      = length(start),
                           Include_Behavior_Wait  = unique(Include_Behavior_Wait)), 
                     by=c('enduse')]
#           enduse  n Include_Behavior_Wait
# 1:        Shower  4                   Yes
# 2:        Faucet 87                    No
# 3:          Bath  1                   Yes
# 4:    Dishwasher  4                    No
# 5: ClothesWasher 10                    No
# looks OK

# add Behavior Wait Trigger  (sec)
# 5 for showers & baths, 
# blank (0) if 'Include Behavior Wait?' is No 	
DT_1day_drawpatterns[ , Behavior_Wait_Trigger := 0]
DT_1day_drawpatterns[  enduse %in% c("Shower", "Bath"),  
                       Behavior_Wait_Trigger := 5]

# check that it worked
DT_1day_drawpatterns[,list(n                      = length(start),
                           Behavior_Wait_Trigger  = unique(Behavior_Wait_Trigger)), 
                     by=c('enduse')]
#           enduse  n Behavior_Wait_Trigger
# 1:        Shower  4                     5
# 2:        Faucet 87                     0
# 3:          Bath  1                     5
# 4:    Dishwasher  4                     0
# 5: ClothesWasher 10                     0
# looks OK
# set 0 to blank when exporting to Excel

# add Behavior wait (sec)	
# 45 for showers & baths,
# 0 if 'Include Behavior Wait?' is No, change to blank when exporting 
DT_1day_drawpatterns[, Behavior_wait := 0]
DT_1day_drawpatterns[  enduse %in% c("Shower", "Bath"),  
                       Behavior_wait := 45]

# check that it worked
DT_1day_drawpatterns[,list(n             = length(start),
                           Behavior_wait = unique(Behavior_wait)), 
                     by=c('enduse')]
#           enduse  n Behavior_wait
# 1:        Shower  4            45
# 2:        Faucet 87             0
# 3:          Bath  1            45
# 4:    Dishwasher  4             0
# 5: ClothesWasher 10             0
# looks OK
# set 0 to blank when exporting to Excel

# add Use time, duration (sec)
# this is the total time of the draw, including any clearing draws
DT_1day_drawpatterns[, Use_time := duration]

# look at range of Use_time
DT_1day_drawpatterns[, list(enduse, n=length(start)), 
                     by=c('enduse','Use_time')][ order(enduse, -Use_time)]
# looks reasonable for one day
# wait Bath looks short, less than 3 minutes?
DT_1day_drawpatterns[enduse=="Bath",]

# look at all the baths
DT_total_drawpatterns[enduse=='Bath', list(npeople   = unique(people),
                                           duration  = unique(duration),
                                           mixedFlow = unique(mixedFlow)),
                      by=DHWDAYUSE][ , totvol := mixedFlow * duration / 60][
                        order(DHWDAYUSE)]
# huh, totvol per bath seems low.
#     DHWDAYUSE npeople duration mixedFlow    totvol
#  1:       2D1       2   150.00     3.584  8.960000
#  2:       2E2       2    79.98     2.820  3.759060
#  3:       2E2       2   120.00     2.969  5.938000
#  4:       3D1       3   169.98     3.457  9.793681
#  5:       3D5       3   160.02     4.174 11.132058
#  6:       3E2       3   160.02     4.787 12.766929
#  7:       4D1       4   109.98     7.342 13.457886
#  8:       4D3       4   139.98     3.790  8.842070
#  9:       4E2       4   130.02     3.534  7.658178
# 10:       4E2       4    49.98     3.886  3.237038
# 11:       5D2       5   319.98     2.308 12.308564
# 12:       5E1       5   180.00     4.596 13.788000
# 13:       6D5       6   270.00     5.260 23.670000
# see http://www.allianceforwaterefficiency.org/Residential_Shower_Introduction.aspx
# Showers vs Baths
# for almost all of these the tub is less than 1/2 full
# most ~ 1/4 full

# add, Flow rate - waiting (GPM)
#   kitchen faucet is 1.8, 
#   tub/shower combo is 4, 
#   master bath tubspout is 6
# blank (0)  if 'Include Behavior Wait?' is No  (sec)(sec)	
DT_1day_drawpatterns[, Flow_rate_waiting := 0]

# list to flag rows by 'Wait for Hot Water' == Yes 
# Wait_for_Hot_Water <- grepl("Yes", DT_1day_drawpatterns$'Wait for Hot Water')

DT_1day_drawpatterns[ Wait_for_Hot_Water=='Yes' & enduse == 'Faucet',  
                      Flow_rate_waiting := 1.8]
DT_1day_drawpatterns[ Wait_for_Hot_Water=='Yes' & enduse == 'Shower',  
                      Flow_rate_waiting := 4.0]
DT_1day_drawpatterns[ Wait_for_Hot_Water=='Yes' & enduse == 'Bath',  
                      Flow_rate_waiting := 6.0]

# check that it worked
DT_1day_drawpatterns[ Wait_for_Hot_Water=='Yes', 
                      list(enduse, Wait_for_Hot_Water, Flow_rate_waiting) ]

 add Flow rate - use (GPM)
DT_1day_drawpatterns[, Flow_rate_use := mixedFlow]

# check if Flow rate - use (GPM)
#   bathroom faucet max is 1.2, 
#   kitchen faucet max is 1.8
DT_1day_drawpatterns[enduse=='Faucet' & Flow_rate_use > 1.2]

# add temperatures
# Hot Water Temp, 125 (F)
# Threshold Temp, 105 (F)	
# Ambient Temp, 70 (F)
DT_1day_drawpatterns[, c('Hot_Water_Temp', 'Threshold_Temp', 'Ambient_Temp') :=
                       list(125, 105, 70)]

names(DT_1day_drawpatterns)
#  [1] "DHWProfile"            "DHWDAYUSE"             "bedrooms"             
#  [4] "people"                "yday"                  "wday"                 
#  [7] "date"                  "start"                 "enduse"               
# [10] "duration"              "mixedFlow"             "hotFlow"              
# [13] "coldFlow"              "Start_Time"            "Fixture_ID"           
# [16] "Event_Type"            "Wait_for_Hot_Water"    "Include_Behavior_Wait"
# [19] "Behavior_Wait_Trigger" "Behavior_wait"         "Use_time"             
# [22] "Flow_rate_waiting"     "Flow_rate_use"         "Hot_Water_Temp"       
# [25] "Threshold_Temp"        "Ambient_Temp"         

# make a data.table for the Excel schedule
DT_1day_schedule <- 
DT_1day_drawpatterns[ , list(enduse,
                             Event_Index = 2*.I-1,
                             Start_Time,
                             Fixture_ID,
                             Event_Type,
                             Wait_for_Hot_Water,
                             Include_Behavior_Wait,
                             Behavior_Wait_Trigger,
                             Behavior_wait,
                             Use_time,
                             Flow_rate_waiting,
                             Flow_rate_use,
                             Hot_Water_Temp,
                             Threshold_Temp,
                             Ambient_Temp)]

# make the cool down rows
DT_cool_down_rows <- data.table( Event_Index = seq(2,2*nrow(DT_1day_schedule),by=2))

# merge in the cool down rows
DT_1day_schedule <- 
merge(DT_1day_schedule, DT_cool_down_rows, by="Event_Index", all = TRUE)

# set Event_Type for cool down rows
DT_1day_schedule[is.na(Event_Type), Event_Type := 'No use, cool down']

# save to csv file
fwrite(DT_1day_schedule, file=paste0(wd_data,"1day_schedule.csv"))
