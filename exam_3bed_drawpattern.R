# exam_3bed_drawpattern.R
# script to exam the draw patterns (DHWDAYUSE) for 3 bedroom households
# Jim Lutz "Wed Aug 29 19:23:44 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

#  load DT_daily.Rdata
load( file = paste0(wd_data,"DT_daily.Rdata"))

# only the only the DHWDAYUSEs in 3 bedroom houses
DT_3bed_daily <-
  DT_daily[bedrooms==3]

# count of records by DHWDAYUSE
DT_3bed_daily[ , list(ndays=length(yday)), by=DHWDAYUSE][order(DHWDAYUSE)]
# 48 DHWDAYUSEs, every DHWDAYUSE used at least once

# number of days by number of occupants
DT_3bed_people <-
  DT_3bed_daily[ , list(n=length(yday)), by=people][order(people)]
#    people   n
# 1:      1  51
# 2:      2 137
# 3:      3  67
# 4:      4  59
# 5:      5  29
# 6:      6  22

# bar chart of values
ggplot(data = DT_3bed_people) +
  geom_col( aes(x=people, y=n)) +
  ggtitle( "Number of Days in Year by Number of Occupants" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title
  scale_x_discrete(name = "number of occupants") +
  scale_y_continuous(name = "number of days") 

# save chart
ggsave(filename = paste0("number_of_occupants.png"), path=wd_charts,
       width = 10.5, height = 8 )



  


# scatter plot of volume vs number of draws per DHWDAYUSE
ggplot(data=DT_daily[bedrooms==3]) +
  geom_jitter(aes(x=totvol, y= ndraw, size=people), 
              width = 5, height = 5, alpha = 0.2 ) +
  ggtitle( "Daily Draw Patterns" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title
  scale_x_continuous(name = "total mixed water drawn (gallons/day)") +
  scale_y_continuous(name = "total number of draws per day") +
  labs(caption="from CBECC-Res19") #+ 

