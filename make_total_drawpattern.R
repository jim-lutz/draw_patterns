# make_total_drawpattern.R
# script to build the complete draw pattern for CBECC_Res 
# contains all the draws for all days of the year for all number of bedrooms
# fields are:
#   DHWProfile    "DHW1BR"
#   DHWDAYUSE     "3H1"
#   bedrooms      1-5
#   people        1-6
#   datetime      ymd_hms as POSIXct in tz "America/Los_Angeles"
#   yday          1-365
#   month         "Jan" "Feb", etc.
#   mday          1-31
#   start         "hh:mm:ss" as character
#   enduse        Bath	ClothesWasher	Dishwasher	Faucet	Shower
#   duration	    seconds
#   mxedFlow	    GPM
#   hotFlow       GPM
#   coldFlow      GPM 
# saves DT_total_drawpattern to .Rdata and .csv files
# Jim Lutz  "Fri Aug  3 08:59:12 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

#  load DT_DHWProfiles.Rdata
load( file = paste0(wd_data,"DT_DHWProfiles.Rdata"))

DT_DHWProfiles
str(DT_DHWProfiles)
# Classes ‘data.table’ and 'data.frame':	365 obs. of  6 variables:
# $ day   : int  1 2 3 4 5 6 7 8 9 10 ...
# $ DHW1BR: chr  "1H1" "1D3" "3E2" "1E1" ...
# $ DHW2BR: chr  "1H1" "3D3" "1E2" "4E1" ...
# $ DHW3BR: chr  "3H1" "1D3" "2E2" "4E1" ...
# $ DHW4BR: chr  "3H1" "6D3" "1E2" "2E1" ...
# $ DHW5BR: chr  "4H1" "2D3" "5E2" "3E1" ...
# - attr(*, ".internal.selfref")=<externalptr> 
#   - attr(*, "index")= atomic  
# ..- attr(*, "__day")= int 

# change into a long dataset
DT_DHWProfiles.long <-
melt.data.table( data = DT_DHWProfiles, 
                 id.vars = "day", 
                 variable.name = "DHWProfile",
                 value.name = "DHWDAYUSE")

# extract number of bedrooms 
DT_DHWProfiles.long[ , bedrooms := str_extract(DHWProfile, "[1-5]" ) ]

# extract number of people 
DT_DHWProfiles.long[ , people := str_extract_all(DHWDAYUSE, "[1-6]", simplify = TRUE)[1:length(DHWDAYUSE),2] ]

# change day to yday
setnames(DT_DHWProfiles.long, old = c("day"), new = c("yday"))

#  load DT_DHWUSEs.Rdata
load( file = paste0(wd_data,"DT_DHWUSEs.Rdata"))

DT_DHWUSEs

# merge DT_DHWProfiles.long and DT_DHWUSEs into one long draw pattern
DT_total_drawpatterns <-
merge(DT_DHWProfiles.long, DT_DHWUSEs, by="DHWDAYUSE", allow.cartesian = TRUE)

# remove id & s
DT_total_drawpatterns[ , c("id", "s"):= NULL]

# duration in seconds
DT_total_drawpatterns[ , duration := duration * 60]

# make datetime in POSIXct format
datetime <- ymd_hms(paste("2009-01-01", DT_total_drawpatterns$start), tz= "America/Los_Angeles" ) + 
            days(DT_total_drawpatterns$yday)

# add the datetime
DT_total_drawpatterns[, datetime := datetime]

# add month and day of month
DT_total_drawpatterns[ , month:= month(datetime, label = TRUE, abbr = TRUE)]
DT_total_drawpatterns[ , mday:= mday(datetime)]

# set order of columns
names(DT_total_drawpatterns)

#   DHWProfile    "DHW1BR"
#   DHWDAYUSE     "3H1"
#   bedrooms      1-5
#   people        1-6
#   datetime      ymd_hms as POSIXct in tz "America/Los_Angeles"
#   yday          1-365
#   month         "Jan" "Feb", etc.
#   mday          1-31
#   start         "hh:mm:ss" as character
#   enduse        Bath	ClothesWasher	Dishwasher	Faucet	Shower
#   duration	    seconds
#   mxedFlow	    GPM
#   hotFlow       GPM
#   coldFlow      GPM 


setcolorder(DT_total_drawpatterns,
            c("DHWProfile", "DHWDAYUSE", "bedrooms", "people", 
              "datetime", "yday", "month", "mday", "start",
              "enduse", "duration", "mixedFlow", "hotFlow", "coldFlow")
            )

DT_total_drawpatterns

# save the DT_total_drawpatterns data as an .Rdata file
save(DT_total_drawpatterns, file = paste0(wd_data,"DT_total_drawpatterns.Rdata"))

# save the DT_total_drawpatterns data as a csv file
write.csv(DT_total_drawpatterns, 
          file= paste0(wd_data,"DT_total_drawpatterns.csv"), 
          row.names = FALSE)

# some brief data checks
setorder(DT_total_drawpatterns, DHWProfile, DHWDAYUSE, datetime)

DT_total_drawpatterns[ , list(first = min(datetime),
                              last  = max(datetime)),
                       by=DHWProfile]
#    DHWProfile               first                last
# 1:     DHW1BR                <NA>                <NA>
# 2:     DHW2BR 2009-01-02 05:55:48 2010-01-01 23:54:00
# 3:     DHW3BR 2009-01-02 07:38:24 2010-01-01 23:23:24
# 4:     DHW5BR                <NA>                <NA>
# 5:     DHW4BR                <NA>                <NA>
# oops!  

DT_total_drawpatterns[ !is.na(datetime), 
                       list(min(datetime),
                            max(datetime))]
#                     V1                  V2
# 1: 2009-01-02 04:00:36 2010-01-01 23:54:00
nrow(DT_total_drawpatterns[ is.na(datetime),] )
# [1] 3
DT_total_drawpatterns[ is.na(datetime),]
