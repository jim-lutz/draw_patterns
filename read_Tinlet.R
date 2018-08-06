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
# 9283 

DT_daily[dayOfYear==68,][order(ctz)]
# 2 temperatures on day 68 in all 16 ctz


DT_Tinlet[dayOfYear %in% 66:68 & ctz=='CTZ01',]
# March 8 has no hour 03.
# looks like Tinlet calculation doesn't follow time changes

DT_Tinlet[dayOfYear%in% 65:70 & ctz=='CTZ01', .N, by=c('dayOfYear','Tinlet')]
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
DT_Tinlet[ ctz=='CTZ01', .N, by=c('dayOfYear','Tinlet')][order(-N)][361:370]
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

# number of days by number of hours per day
# for CTZ01
DT_Tinlet[, .N, by=c('ctz','dayOfYear','Tinlet')][ctz=='CTZ01',  list(ndays = length(Tinlet)), by=N]
#     N ndays
# 1: 24   127
# 2: 23   238
# 3:  1   238

# keep the 365 days with the most Tinlets
DT_daily <-
  DT_Tinlet[, .N, by=c('ctz','dayOfYear','Tinlet')][order(-N)][1:(365*16)][order(ctz,dayOfYear)]
# 5840, = 365*16

# take a look, 
ggplot(data = DT_daily) +
  geom_point(aes(dayOfYear, Tinlet, color=ctz)) +
  ggtitle("Inlet Water Temperatures") +
  theme(plot.title = element_text(hjust = 0.5) ) +
  labs(caption="from CBECC-Res19") +
  xlab("Day of Year") +
  ylab("deg F") + 
  labs(color="climate zone")
# still not as smooth as I'd expect for Tinlet
# being overly influenced by air temps?

# save the plot
ggsave(filename = paste0(wd_charts,"Tinlet_by_ctz.png"))

