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

# the 48 DHWDAYUSE number of people, number of days
DT_3bed_DHWDAYUSE <-
  DT_3bed_daily[ , list(ndays   = length(yday),
                        npeople = unique(people),
                        totvol  = unique(totvol),
                        ndraw   = unique(ndraw)),
                 by=c('DHWDAYUSE')][order(DHWDAYUSE)]

# find the 25th and 75th percentiles
# of ndraw
q.ndraw <- quantile(DT_3bed_daily$ndraw, probs = c(0.125, 0.875))
# 25% 75% 
#  38  79 
# [1] 38 79
str(q.ndraw)
q.ndraw[['25%']]
q.ndraw[[1]]

# of totvol
q.totvol <- quantile(DT_3bed_daily$totvol, probs = c(0.125, 0.875))
#      25%      75% 
# 35.98394 90.09349 

# line segments
line.segments <- data.frame(
  x = unname(c(q.totvol, rev(q.totvol), q.totvol[[1]])),
  y = unname(c(q.ndraw[[1]], q.ndraw[[1]], q.ndraw[[2]], q.ndraw[[2]], q.ndraw[[1]]))
  )

# scatter plot of volume vs number of draws per DHWDAYUSE
ggplot(data=DT_3bed_DHWDAYUSE) +
  geom_point(aes(x=totvol, y= ndraw, size=ndays, color=npeople), shape=1) +
  geom_path(data=line.segments, aes(x=x, y=y)) +
  ggtitle("Daily Draw Patterns", subtitle = "DHWDAYUSE") +
  # center and format titles
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5,
                                     size  = rel(0.75)))
# save chart
ggsave(filename = paste0("daily_draws_gallons.png"), path=wd_charts,
       width = 10.5, height = 8 )

DT_daily[]


# new draws 
# ~ 2 person, ~26 gallons, ~ 30 draws
# ~ 4 person ~ 80 gallons, ~25 draws
# ~ 2 person ~ 50 gallons, ~90 draws
# previous 
# 3 person 91 gall, 106 draws
# 3 person  57 gal, 78 draws


# 
# 
# 
#   
#   geom_jitter(aes(x=totvol, y= ndraw, size=people), 
#               width = 5, height = 5, alpha = 0.2 )  +
#   theme(plot.title = element_text(hjust = 0.5)) + # to center the title
#   scale_x_continuous(name = "total mixed water drawn (gallons/day)") +
#   scale_y_continuous(name = "total number of draws per day") +
#   labs(caption="from CBECC-Res19") #+ 
================================
  


# scatter plot of volume vs number of draws per DHWDAYUSE
ggplot(data=DT_daily[bedrooms==3]) +
  geom_jitter(aes(x=totvol, y= ndraw, size=people), 
              width = 5, height = 5, alpha = 0.2 ) +
  ggtitle( "Daily Draw Patterns" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title
  scale_x_continuous(name = "total mixed water drawn (gallons/day)") +
  scale_y_continuous(name = "total number of draws per day") +
  labs(caption="from CBECC-Res19") #+ 

