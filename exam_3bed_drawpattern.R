# exam_3bed_drawpattern.R
# script to exam the draw patterns (DHWDAYUSE) for 3 bedroom households
# Jim Lutz "Wed Aug 29 19:23:44 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

#  load DT_daily.Rdata
load( file = paste0(wd_data,"DT_daily.Rdata"))

# only the DHWDAYUSEs in 3 bedroom houses
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
  ggtitle( "Number of Days in Year by Number of Occupants",
           subtitle = "for 3 bedroom house") +
  labs(y="number of days") +
  # center and format titles
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5,
                                     size  = rel(0.75))) +
  scale_x_discrete(name = "number of occupants") +
  scale_y_continuous(name = "number of days") 

# save chart
ggsave(filename = paste0("number_of_occupants.png"), path=wd_charts,
       width = 10.5, height = 8 )

DT_daily[]

# the 48 DHWDAYUSE number of people, number of days, total volume & number of draws
DT_3bed_DHWDAYUSE <-
  DT_3bed_daily[ , list(ndays   = length(yday),
                        npeople = unique(people),
                        totvol  = unique(totvol),
                        ndraw   = unique(ndraw)),
                 by=c('DHWDAYUSE')][order(DHWDAYUSE)]

# find the DHWDAYUSEs to export to model       
# 2 person ~26 gallons, ~30 draws
DT_3bed_DHWDAYUSE[ npeople ==2 &
                     26 - 5 <= totvol & totvol <= 26 + 5 &
                     30 - 5 <= ndraw  & ndraw  <= 30 + 5 ]
#    DHWDAYUSE ndays npeople   totvol ndraw
# 1:       2D4    24       2 25.72585    28

# 4 person ~80 gallons, ~25 draws
DT_3bed_DHWDAYUSE[ npeople ==4 &
                     80 - 5 <= totvol & totvol <= 80 + 5 &
                     25 - 10 <= ndraw  & ndraw  <= 25 + 10 ]
#    DHWDAYUSE ndays npeople   totvol ndraw
# 1:       4D5     4       4 82.98847    31

# 2 person ~50 gallons, ~90 draws
DT_3bed_DHWDAYUSE[ npeople ==2 &
                     50 - 5 <= totvol & totvol <= 50 + 5 &
                     90 - 5 <= ndraw  & ndraw  <= 90 + 5 ]
#    DHWDAYUSE ndays npeople   totvol ndraw
# 1:       2E2    20       2 50.41109    95

# 3 person  91 gal, 106 draws
DT_3bed_DHWDAYUSE[ npeople == 3 &
                     91 - 5 <= totvol & totvol <= 91 + 5 &
                     106 - 5 <= ndraw  & ndraw  <= 106 + 5 ]
#    DHWDAYUSE ndays npeople   totvol ndraw
# 1:       3D1    11       3 91.86793   106

# 3 person  57 gal, 78 draws
DT_3bed_DHWDAYUSE[ npeople == 3 &
                   57 - 5 <= totvol & totvol <= 57 + 5 &
                   78 - 5 <= ndraw  & ndraw  <= 78 + 5 ]
#    DHWDAYUSE ndays npeople  totvol ndraw
# 1:       3D2    11       3 57.0848    77

# some DHWDAYUSEs to use
DT_selecteds <- DT_3bed_DHWDAYUSE[
  DHWDAYUSE %in% c('2D4', '4D5', '2E2', '3D1', '3D2'),]

# save the DT_selecteds data as an .Rdata file
save(DT_selecteds, file = paste0(wd_data,"DT_selecteds.Rdata"))

# find bounds of a box of the 12.5 and 87.5 percentiles
ubound = 0.875
lbound = 0.125

# of ndraw
q.ndraw <- quantile(DT_3bed_daily$ndraw, probs = c(ubound, lbound))

# of totvol
q.totvol <- quantile(DT_3bed_daily$totvol, probs = c(ubound, lbound))

# line segments
line.segments <- data.frame(
  x = unname(c(q.totvol, rev(q.totvol), q.totvol[[1]])),
  y = unname(c(q.ndraw[[1]], q.ndraw, rev(q.ndraw)))
)
line.segments
#           x  y
# 1 100.77549 95
# 2  27.01593 95
# 3  27.01593 29
# 4 100.77549 29
# 5 100.77549 95

# scatter plot of volume vs number of draws per DHWDAYUSE
ggplot(data=DT_3bed_DHWDAYUSE) +
  geom_point(aes(x=totvol, y= ndraw, size=ndays, color=npeople), shape=1) +
  
  # bounding box
  geom_path(data=line.segments, aes(x=x, y=y), linetype=2, size=0.25) + 
  
  # highlight the DHWDAYUSEs that were used
  geom_point(data = DT_selecteds,
             aes(x=totvol, y= ndraw, size=ndays, color=npeople), shape=16) +
  
  ggtitle("Daily Draw Patterns",
          subtitle = "365 days for 3 bedroom house") +
    # center and format titles
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5,
                                     size  = rel(0.75))) +
  scale_x_continuous(name = "total mixed water drawn (gallons/day)") +
  scale_y_continuous(name = "total number of draws per day") +
  labs(caption="from CBECC-Res19") #+ 

# save chart
ggsave(filename = paste0("daily_draws_gallons.png"), path=wd_charts,
       width = 10.5, height = 8 )




