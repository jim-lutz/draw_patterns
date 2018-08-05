# read_Tinlet.R
# script to read 365 day Tinlet from *.csv files in 
# /home/jiml/HotWaterResearch/projects/How Low/draw_patterns/CSE/TINLET
# saves DT_Tinlet to .Rdata and .csv files
# Jim Lutz "Sat Aug  4 17:04:59 2018"

# TINLETCTZxx.CSV files have fields
# "dayOfYear","month","dayOfMonth","hour","DOWH","Tinlet"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# directory of Tinlet files
d_Tinlet <- "/home/jiml/HotWaterResearch/projects/How Low/draw_patterns/CSE/TINLET/"

# get list of *.csv files in the directory
l_fn_Tinlet <- list.files(path = d_Tinlet, pattern = "*.CSV")

# initialize empty data.table
DT_Tinlet <- data.table( )

# loop through all the files
for( fn_Tinlet in l_fn_Tinlet) {

  # to test one file
  # fn_Tinlet = l_fn_Tinlet[1]
  
  # remove temporary data.table
  rm(DT_Tinlet.temp)
  
  # parse out the climate zone number
  ctz <- str_extract(fn_Tinlet, "CTZ[0-9]{2}")
  
  # read data for one climate zone
  DT_Tinlet.temp <- fread(file=paste0(d_Tinlet, fn_Tinlet)) 
  
  # add ctz
  DT_Tinlet.temp[, ctz:=ctz]
  
  # append DT_Tinlet.temp
  DT_Tinlet <- rbind(DT_Tinlet, DT_Tinlet.temp)
  
}

# review DT_Tinlet
DT_Tinlet

# get a daily summary, Tinlet changes daily not hourly
DT_daily <-
DT_Tinlet[ , list(ctz     = unique(ctz),
                  Tinlet  = unique(Tinlet)),
           by = dayOfYear]
# something funny there's not supposed to 603 days in a year

ggplot(data = DT_daily) +
  geom_point(aes(dayOfYear, Tinlet))
# curve not as smooth as expected

# days by number of repeats
DT_daily[ , list(n=length(dayOfYear)), by=dayOfYear]
# this has 365

str(DT_Tinlet)
# Classes ‘data.table’ and 'data.frame':	8760 obs. of  7 variables:

str(DT_daily)
# Classes ‘data.table’ and 'data.frame':	603 obs. of  3 variables:

summary(DT_daily)
#     dayOfYear         ctz                Tinlet     
# Min.   :  1.0   Length:603         Min.   :47.63  
# 1st Qu.:109.5   Class :character   1st Qu.:48.72  
# Median :185.0   Mode  :character   Median :51.85  
# Mean   :184.4                      Mean   :51.42  
# 3rd Qu.:260.0                      3rd Qu.:53.94  
# Max.   :365.0                      Max.   :54.86  

# look for duplicates
anyDuplicated(DT_daily)
# [1] 0  no duplicates

anyDuplicated(DT_daily[,list(dayOfYear)])
# [1] 69 found something

DT_daily[duplicated(DT_daily[,list(dayOfYear)])]

DT_daily[dayOfYear==68,]
#    dayOfYear   ctz  Tinlet
# 1:        68 CTZ01 47.7885
# 2:        68 CTZ01 47.8085

# did some days have more than one temp?
DT_Tinlet[ , list(n    = length(Tinlet),
                  Tmin = min(Tinlet),
                  Tmax = max(Tinlet),
                  Tmode= mode(Tinlet)), by=dayOfYear][Tmin!=Tmax,]
#    dayOfYear  n    Tmin    Tmax   Tmode
# 1:        68 24 47.7885 47.8085 numeric
# 2:        69 24 47.8085 47.8336 numeric
# 3:        70 24 47.8336 47.8909 numeric
# are the temps calculated without respect to time changes?

DT_Tinlet[dayOfYear %in% 66:68,]
#     dayOfYear month dayOfMonth hour DOWH  Tinlet   ctz
# 23:        66     3          7   23    7 47.7577 CTZ01
# 24:        66     3          7   24    7 47.7577 CTZ01
# 25:        67     3          8    1    1 47.7885 CTZ01
# 26:        67     3          8    2    1 47.7885 CTZ01
# 27:        67     3          8    4    1 47.7885 CTZ01
# 
# 45:        67     3          8   22    1 47.7885 CTZ01
# 46:        67     3          8   23    1 47.7885 CTZ01
# 47:        67     3          8   24    1 47.7885 CTZ01
# 48:        68     3          9    1    2 47.7885 CTZ01
# 49:        68     3          9    2    2 47.8085 CTZ01
# 50:        68     3          9    3    2 47.8085 CTZ01
# 51:        68     3          9    4    2 47.8085 CTZ01
# looks like Tinlet calculation doesn't follow time changes

DT_Tinlet[dayOfYear%in% 65:70 , .N, by=c('dayOfYear','Tinlet')]
#    dayOfYear  Tinlet  N
# 1:        65 47.7191 24
# 2:        66 47.7577 24
# 3:        67 47.7885 23
# 4:        68 47.7885  1
# 5:        68 47.8085 23
# 6:        69 47.8085  1
# 7:        69 47.8336 23
# 8:        70 47.8336  1
# 9:        70 47.8909 23

# this keeps the 365 dayOfYear with the most common Tinlet
DT_Tinlet[, .N, by=c('dayOfYear','Tinlet')][order(-N)][361:370]
 #     dayOfYear  Tinlet  N
 #  1:       300 52.5301 23
 #  2:       301 52.5375 23
 #  3:       302 52.5132 23
 #  4:       303 52.4586 23
 #  5:       304 52.3674 23
 #  6:        68 47.7885  1
 #  7:        69 47.8085  1
 #  8:        70 47.8336  1
 #  9:        71 47.8909  1
 # 10:        72 47.9505  1

# keep the 365 days with the most Tinlets
DT_daily <-
DT_Tinlet[, .N, by=c('dayOfYear','Tinlet')][order(-N)][1:365][order(dayOfYear)]

# take a look, 
ggplot(data = DT_daily) +
  geom_point(aes(dayOfYear, Tinlet))
# still not as smooth as I'd expect for Tinlet
# being overly influenced by air temps?

