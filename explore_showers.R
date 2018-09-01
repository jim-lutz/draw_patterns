# explore_showers.R
# script to generate histogram of shower durations in the CBECC-Res 3 bedroom draw profile
# Jim Lutz "Thu Aug 30 19:28:27 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

#  load DT_total_drawpatterns.Rdata
load( file = paste0(wd_data,"DT_total_drawpatterns.Rdata"))

DT_total_drawpatterns

# DHWDAYUSE DHWDAYUSE ndays
DT_DAY <-
  DT_total_drawpatterns[, list(ndays  = length(unique(date))),
                        by=c('DHWProfile','DHWDAYUSE')]

rm(DT_DAYS)
# ndays of each DHWDAYUSE in the DHWProfiles
DT_DAYS <- dcast(data=DT_DAY, DHWDAYUSE ~ DHWProfile)

# check that there's 365 DHWDAYUSE in each DHWProfiles
DT_DAYS[ , list( ndaysDHW1BR = sum(DHW1BR, na.rm = TRUE),
                 ndaysDHW2BR = sum(DHW2BR, na.rm = TRUE),
                 ndaysDHW3BR = sum(DHW3BR, na.rm = TRUE),
                 ndaysDHW4BR = sum(DHW4BR, na.rm = TRUE),
                 ndaysDHW5BR = sum(DHW5BR, na.rm = TRUE)
              )
        ]
#    ndaysDHW1BR ndaysDHW2BR ndaysDHW3BR ndaysDHW4BR ndaysDHW5BR
# 1:         365         365         365         365         365

# get the showers, and a few other parameters 
DT_showers <-
  unique(DT_total_drawpatterns[ enduse=='Shower',
                                list(DHWDAYUSE, people, enduse, 
                                     start, duration, mixedFlow) 
                                ]
        ) # use unique to get rid of duplicates

DT_showers
# 115 showers in the 48 DHWDAYUSEs

summary(DT_showers$duration)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  120     280     400     442     555    1600 

# average number of showers per day by number of people
DT_showers[ , list(nshowers        = length(enduse), 
                   # number of showers in DHWDAYUSES by number of people
                   nDHWDAYUSEshwrs = length(unique(DHWDAYUSE))
                   # number of DHWDAYUSES with showers by number of people
                  ),
            by=people][,list(people, 
                             showers_day = nshowers/8)]
#    people showers_day
# 1:      1       0.750
# 2:      2       2.000
# 3:      3       2.125
# 4:      4       2.250
# 5:      5       3.750
# 6:      6       3.500
# somedays there's no showers, 
# somedays there's more showers than people
# somedays there's fewer showers than people
DT_showers[people==1,]

# all the showers in the 3 bedroom annual draw pattern
DT_shower <-
  DT_total_drawpatterns[DHWProfile == 'DHW3BR' &
                          enduse   == 'Shower', list(duration)]

summary(DT_shower)

# histogram of shower durations
ggplot(data=DT_shower) +
  geom_histogram(aes(x = duration), breaks = seq(0, 1620, by = 30)) +
  scale_x_continuous(breaks = seq(0, 1620, by = 120),
                     labels = seq(0, 1620, by = 120)/60, 
                     limits = c(0, 1620),
                     name = "duration (minutes)") +
  geom_vline(xintercept=300, color='red') +
  ggtitle("Shower Durations",
          subtitle = "365 days for 3 bedroom house") +
  # center and format titles
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5,
                                     size  = rel(0.75)
                                     )
        )  +
  labs(caption="from CBECC-Res19")

# save chart
ggsave(filename = paste0("CBECC_shower_distributions.png"), path=wd_charts,
       width = 5.25, height = 4 )
