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

# find the first date for each DHWDAYUSE in selected.DHWDAYUSE
DT_day1_DHWDAYUSE <-
  DT_selected[, list(date=date[1]), by=DHWDAYUSE]
#    DHWDAYUSE       date
# 1:       2D4 2009-01-07
# 2:       2E2 2009-01-03
# 3:       3D1 2009-01-29
# 4:       3D2 2009-04-09
# 5:       4D5 2009-06-08

# only those DHWDAYUSEs & dates
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

# sanity check on draws
qplot(x=DT_day1_selected$duration, y=DT_day1_selected$mixedFlow,
      xlab = "duration (secs)", ylab = "total flow rate (GPM)")
# some pretty small flow ..

qplot(x=DT_day1_selected$duration, y=DT_day1_selected$mixedFlow,
      xlab = "duration (secs)", ylab = "total flow rate (GPM)",
      ylim=c(0,1)) 

qplot(x=DT_day1_selected$duration, y=DT_day1_selected$mixedFlow,
      xlab = "duration (secs)", ylab = "total flow rate (GPM)",
      ylim=c(0,0.1)) 

# check on the outliers
DT_day1_selected[ mixedFlow<0.1, list(DHWDAYUSE, date, start,
                                      enduse, duration, mixedFlow)]
#    DHWDAYUSE       date    start        enduse duration mixedFlow
# 1:       2E2 2009-01-03 05:08:24        Faucet   100.02     0.047
# 2:       2E2 2009-01-03 10:46:12        Faucet    79.98     0.064
# 3:       2E2 2009-01-03 14:01:48        Faucet   109.98     0.031
# 4:       2E2 2009-01-03 14:52:48        Faucet    79.98     0.038
# 5:       2E2 2009-01-03 18:00:36        Faucet   150.00     0.034
# 6:       4D5 2009-06-08 08:32:24 ClothesWasher   370.02     0.022
# 7:       4D5 2009-06-08 08:38:24 ClothesWasher   360.00     0.025




# build data.table first then worry about formatting and putting into Excel
# https://cran.r-project.org/web/packages/xlsx/xlsx.pdf

# --- --- --- --- --- --- --- --- --- --- 
# build data columns to match model spreadsheet
# --- --- --- --- --- --- --- --- --- --- 
# /home/jiml/HotWaterResearch/projects/How Low/pipe sizing/Model output example.xlsx


# --- --- --- --- --- --- --- --- --- --- 
# START TIME
# --- --- --- --- --- --- --- --- --- --- 
# add Start Time, date & start in a d/m/yyyy h:m:s format
DT_day1_selected[ , Start_Time := paste(strftime(ymd(date),"%m/%d/%Y"),start)]


# --- --- --- --- --- --- --- --- --- --- 
# END USE
# --- --- --- --- --- --- --- --- --- --- 
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


# --- --- --- --- --- --- --- --- --- --- 
# WAIT FOR HOT WATER
# --- --- --- --- --- --- --- --- --- --- 
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

# --- --- --- --- --- --- --- --- --- --- 
# BEHAVIOR WAIT
# --- --- --- --- --- --- --- --- --- --- 
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


# --- --- --- --- --- --- --- --- --- --- 
# DURATION
# --- --- --- --- --- --- --- --- --- --- 
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
DT_day1_selected[enduse=='Bath', 
                      list(npeople   = unique(people),
                           duration  = unique(duration),
                           mixedFlow = unique(mixedFlow)),
                      by=DHWDAYUSE][ , totvol := mixedFlow * duration / 60][
                        order(DHWDAYUSE)]
# huh, totvol per bath seems low.
#    DHWDAYUSE npeople duration mixedFlow   totvol
# 1:       2E2       2    79.98     2.820 3.759060
# 2:       2E2       2   120.00     2.969 5.938000
# 3:       3D1       3   169.98     3.457 9.793681
# see http://www.allianceforwaterefficiency.org/Residential_Shower_Introduction.aspx
# Showers vs Baths
# for almost all of these the tub is less than 1/2 full
# most ~ 1/4 full


# --- --- --- --- --- --- --- --- --- --- 
# --- FLOW RATES ---
# --- --- --- --- --- --- --- --- --- --- 
# add, Flow rate - waiting (GPM)
#   lavatory faucet is 1.2, 
#   kitchen faucet is 1.8 / 2.2
#   shower is 1.8
#   bath is 4.5, 
# blank (0)  if 'Include Behavior Wait?' is No  (sec)
DT_day1_selected[, Flow_rate_waiting := 0]

# list to flag rows by 'Wait for Hot Water' == Yes 
# Wait_for_Hot_Water <- grepl("Yes", DT_day1_selected$'Wait for Hot Water')

DT_day1_selected[ Wait_for_Hot_Water=='Yes' & enduse == 'Faucet',  
                      Flow_rate_waiting := 1.2]
DT_day1_selected[ Wait_for_Hot_Water=='Yes' & enduse == 'Shower',  
                      Flow_rate_waiting := 1.8]
DT_day1_selected[ Wait_for_Hot_Water=='Yes' & enduse == 'Bath',  
                      Flow_rate_waiting := 4.5]

# check that it worked
DT_day1_selected[ Wait_for_Hot_Water=='Yes', 
                      list(enduse, Wait_for_Hot_Water, Flow_rate_waiting) ]

# add Flow rate - use (GPM)
DT_day1_selected[, Flow_rate_use := mixedFlow]

# check if Flow rate - use (GPM) is above standard after location assigned
#   bathroom faucet max is 1.2, 
#   kitchen faucet max is 1.8

# --- --- --- --- --- --- --- --- --- --- 
# TEMPERATURE
# --- --- --- --- --- --- --- --- --- --- 
# add temperatures
# Hot Water Temp, 125 (F)
# Threshold Temp, 105 (F)	
# Ambient Temp, 70 (F)
DT_day1_selected[, c('Hot_Water_Temp', 'Threshold_Temp', 
                     'Ambient_Temp', 'Cold_Water_Temp') :=
                       list(125, 105, 70, 70)]

names(DT_day1_selected)
#  [1] "enduse"                "DHWDAYUSE"             "date"                 
#  [4] "DHWProfile"            "bedrooms"              "people"               
#  [7] "yday"                  "wday"                  "start"                
# [10] "duration"              "mixedFlow"             "hotFlow"              
# [13] "coldFlow"              "Start_Time"            "Fixture_ID"           
# [16] "Event_Type"            "Wait_for_Hot_Water"    "Include_Behavior_Wait"
# [19] "Behavior_Wait_Trigger" "Behavior_wait"         "Use_time"             
# [22] "Flow_rate_waiting"     "Flow_rate_use"         "Hot_Water_Temp"       
# [25] "Threshold_Temp"        "Ambient_Temp"          "Cold_Water_Temp"         

# sort by DHWDAYUSE and Start_Time
setkeyv(DT_day1_selected, cols = c('DHWDAYUSE','Start_Time'))

# make a data.table for the Excel schedule
DT_draw_schedule <- 
DT_day1_selected[ , list(enduse,
                         Day_num      = .GRP,
                         Event_Index  = 0, # place holder only
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
                         Ambient_Temp,
                         Cold_Water_Temp), 
                  by=c('DHWDAYUSE')][
                    order(DHWDAYUSE, Start_Time) ]

# fix Event_Index
DT_draw_schedule[ , Event_Index := 1:nrow(DT_draw_schedule)]

# check the Event_Index spans DHWDAYUSE Day_num 
DT_draw_schedule[ , list(DHWDAYUSE      = unique(DHWDAYUSE),
                         lo.Event_Index = min(Event_Index),
                         hi.Event_Index = max(Event_Index)),
                  by=Day_num]

str(DT_draw_schedule)

# save to csv file
fwrite(DT_draw_schedule, file=paste0(wd_data,"day_schedule.csv"),
       quote = TRUE)
