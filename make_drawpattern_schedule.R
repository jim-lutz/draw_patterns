# make_drawpattern_schedule.R
# script to build an input file for a one day draw pattern as input for spreadsheet model.
# Jim Lutz "Mon Aug  6 11:57:02 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

#  load DT_total_drawpatterns.Rdata
load( file = paste0(wd_data,"DT_total_drawpatterns.Rdata"))

DT_total_drawpatterns
names(DT_total_drawpatterns)

# start with selected DHWDAYUSEs, '2D4', '4D5', '2E2', '3D1', '3D2' 
selected.DHWDAYUSE <- c('2D4', '4D5', '2E2', '3D1', '3D2') 

# in DHW3BR
DT_selected <-
  DT_total_drawpatterns[DHWDAYUSE %in% selected.DHWDAYUSE
                        & DHWProfile=='DHW3BR',]

# how many days?
DT_selected[,list(ndate=length(unique(date))), by=c('DHWDAYUSE')][
  order(DHWDAYUSE)]
#    DHWDAYUSE ndate
# 1:       2D4    24
# 2:       2E2    20
# 3:       3D1    11
# 4:       3D2    11
# 5:       4D5     4

# fine the first date for each DHWDAYUSE in selected.DHWDAYUSE
DT_day1_DHWDAYUSE <-
  DT_selected[, list(date=date[1]), by=DHWDAYUSE]
#    DHWDAYUSE       date
# 1:       2D4 2009-01-07
# 2:       2E2 2009-01-03
# 3:       3D1 2009-01-29
# 4:       3D2 2009-04-09
# 5:       4D5 2009-06-08

# only those DHWDAYUSE & date
DT_day1_selected <-
  merge(DT_selected, DT_day1_DHWDAYUSE,by=c('DHWDAYUSE','date'))

# look at number of enduses for each DHWDAYUSE
DT_day1_selected[,list(ndraws = length(start),
                       totvol = sum(mixedFlow*duration/60)), 
                 by=c('DHWDAYUSE','date', 'enduse')][
                   order(DHWDAYUSE,-totvol)]
# seems plausible

# confirm ndraw and totvol for DHWDAYUSE still match daily_draws_gallons.png
DT_day1_selected[,list(ndraws = length(start),
                       totvol = sum(mixedFlow*duration/60)), 
                 by=c('DHWDAYUSE')]
#    DHWDAYUSE ndraws   totvol
# 1:       2D4     28 25.72585
# 2:       2E2     95 50.41109
# 3:       3D1    106 91.86793
# 4:       3D2     77 57.08480
# 5:       4D5     31 82.98847
# yup, it's OK

# build data.table first then worry about formatting and putting into Excel
# https://cran.r-project.org/web/packages/xlsx/xlsx.pdf

# build data columns to match
# /home/jiml/HotWaterResearch/projects/How Low/pipe sizing/Model output example.xlsx
# only 'Event_Type' == 'Use'

# add Start Time, date & start in a d/m/yyyy h:m:s format
DT_day1_selected[ , Start_Time := paste(strftime(ymd(date),"%m/%d/%Y"),start)]

# add Fixture ID, B2_SK1,B3_SK, K_SK, LN_WA, MB_SH, MB_SK1, MB_SK2, etc
# for now just enter 2 letter enduse code as place holder
DT_enduses <- 
  data.table(enduse=c("Faucet","Shower","ClothesWasher","Bath","Dishwasher"),
             Fixture_ID=c("SK","SH","CW","BA","DW"))

DT_day1_selected <-
  merge(DT_day1_selected, DT_enduses, by='enduse', all.x = TRUE)

# add Event Type, 
# for now enter 'Use'
DT_day1_selected[ , Event_Type := 'Use']

# add Wait for Hot Water? 
# Yes, (for shower, bath, & long (>= 1 min) faucet), No (everything else)
DT_day1_selected[ , Wait_for_Hot_Water := 'No']
DT_day1_selected[ enduse %in% c("Shower", "Bath"), 
                      Wait_for_Hot_Water := 'Yes']
DT_day1_selected[ enduse=="Faucet" & duration>60, 
                      Wait_for_Hot_Water := 'Yes']

# check that it worked
DT_day1_selected[,list(n = length(start)), 
                 by=c('enduse','Wait_for_Hot_Water') ]
#           enduse Wait_for_Hot_Water   n
# 1:          Bath                Yes   3
# 2: ClothesWasher                 No  37
# 3:    Dishwasher                 No  10
# 4:        Faucet                 No 243
# 5:        Faucet                Yes  35
# 6:        Shower                Yes   9
# looks OK

# add Include Behavior Wait? Yes for shower, No for everything else.
DT_day1_selected[ , Include_Behavior_Wait := 'No']
DT_day1_selected[ enduse %in% c("Shower"), 
                      Include_Behavior_Wait := 'Yes']

# check that it worked
DT_day1_selected[,list(n = length(start)),
                     by=c('enduse','Include_Behavior_Wait')]
#           enduse Include_Behavior_Wait   n
# 1:          Bath                    No   3
# 2: ClothesWasher                    No  37
# 3:    Dishwasher                    No  10
# 4:        Faucet                    No 278
# 5:        Shower                   Yes   9
# looks OK

# add Behavior Wait Trigger (sec)
# 15 for showers only 
# blank (0) if 'Include Behavior Wait?' is No 	
DT_day1_selected[ , Behavior_Wait_Trigger := 0]
DT_day1_selected[  enduse %in% c("Shower"),  
                       Behavior_Wait_Trigger := 15]

# check that it worked
DT_day1_selected[,list(n = length(start)), 
                 by=c('enduse','Behavior_Wait_Trigger')]
#           enduse Behavior_Wait_Trigger   n
# 1:          Bath                     0   3
# 2: ClothesWasher                     0  37
# 3:    Dishwasher                     0  10
# 4:        Faucet                     0 278
# 5:        Shower                    15   9
# looks OK
# set 0 to blank when exporting to Excel

# add Behavior wait (sec)	
# 45 for showers,
# 0 if 'Include Behavior Wait?' is No, 
# change 0 to blank when exporting to Excel
DT_day1_selected[, Behavior_wait := 0]
DT_day1_selected[  enduse %in% c("Shower"),  
                       Behavior_wait := 45]

# check that it worked
DT_day1_selected[,list(n = length(start)), 
                 by=c('enduse','Behavior_wait')]
#           enduse Behavior_wait   n
# 1:          Bath             0   3
# 2: ClothesWasher             0  37
# 3:    Dishwasher             0  10
# 4:        Faucet             0 278
# 5:        Shower            45   9
# looks OK
# set 0 to blank when exporting to Excel

# add Use time, duration (sec)
# this is the total time of the draw, 
# faucets > 60, subtract 60 for assumed clearing draw in CBECC-Res
# showers > 300, subtract 60 for assumed clearing draw in CBECC-Res
DT_day1_selected[, Use_time := duration]
DT_day1_selected[enduse=="Faucet" & duration>60, Use_time := duration-60]
DT_day1_selected[enduse=="Shower" & duration>300, Use_time := duration-60]

# look at range of Use_time
DT_day1_selected[, list( n=length(start),
                         max.duration = max(duration),
                         min.duration = min(duration),
                         max.Use_time = max(Use_time),
                         min.Use_time = min(Use_time)),
                 by=c('enduse')]
#           enduse   n max.duration min.duration max.Use_time min.Use_time
# 1:          Bath   3       169.98        79.98       169.98        79.98
# 2: ClothesWasher  37       559.98        19.98       559.98        19.98
# 3:    Dishwasher  10       100.02        30.00       100.02        30.00
# 4:        Faucet 278       460.02        10.02       400.02        10.02
# 5:        Shower   9       450.00       250.02       390.00       250.02
# wait Bath looks short, less than 3 minutes?
DT_day1_selected[enduse=="Bath",]

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
#   faucet is 1.8, 
#   bath is 4.5, 
#   master bath tubspout is 6
# blank (0)  if 'Include Behavior Wait?' is No  (sec)(sec)	
DT_day1_selected[, Flow_rate_waiting := 0]

# list to flag rows by 'Wait for Hot Water' == Yes 
# Wait_for_Hot_Water <- grepl("Yes", DT_day1_selected$'Wait for Hot Water')

DT_day1_selected[ Wait_for_Hot_Water=='Yes' & enduse == 'Faucet',  
                      Flow_rate_waiting := 1.8]
DT_day1_selected[ Wait_for_Hot_Water=='Yes' & enduse == 'Shower',  
                      Flow_rate_waiting := 4.0]
DT_day1_selected[ Wait_for_Hot_Water=='Yes' & enduse == 'Bath',  
                      Flow_rate_waiting := 6.0]

# check that it worked
DT_day1_selected[ Wait_for_Hot_Water=='Yes', 
                      list(enduse, Wait_for_Hot_Water, Flow_rate_waiting) ]

 add Flow rate - use (GPM)
DT_day1_selected[, Flow_rate_use := mixedFlow]

# check if Flow rate - use (GPM)
#   bathroom faucet max is 1.2, 
#   kitchen faucet max is 1.8
DT_day1_selected[enduse=='Faucet' & Flow_rate_use > 1.2]

# add temperatures
# Hot Water Temp, 125 (F)
# Threshold Temp, 105 (F)	
# Ambient Temp, 70 (F)
DT_day1_selected[, c('Hot_Water_Temp', 'Threshold_Temp', 'Ambient_Temp') :=
                       list(125, 105, 70)]

names(DT_day1_selected)
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
DT_day1_selected[ , list(enduse,
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
