# histograms_day7.R
# script generate histograms of flowrates 
# by volume and by events for reference day
# "Mon Sep 24 12:44:52 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# read the csv schedule file as data.table
DT_schedule <-
  as.data.table(
    read.csv(file = paste0(wd_data,
                           "Draw schedule for performance analysis.standard_2018-09-23.csv"))
)

DT_schedule
names(DT_schedule)

# clean up the names
setnames(DT_schedule,
         old = c("Day..", "Event.Index", "Start.Time", "Fixture.ID", "Event.Type",
                 "Wait.for.Hot.Water.",  "Include.Behavior.Wait.", 
                 "Behavior.Wait.Trigger..sec.", "Behavior.wait...sec.", "Use.time..sec.",
                 "Flow.rate...waiting..GPM.", "Flow.rate...use..std...GPM.",
                 "Flow.rate...use..low...GPM."),
         new = c("Day", "Event.Index", "Start.Time", "Fixture.ID", "Event.Type",
                 "Wait.for.Hot.Water",  "Include.Behavior.Wait", 
                 "Behavior.Wait.Trigger.sec", "Behavior.wait.sec", "Use.time.sec",
                 "Flow.rate.waiting.GPM", "Flow.rate.use.std.GPM",
                 "Flow.rate.use.low.GPM")
         )

# make histogram of flowrates by number of events
# bare plot with data
ggplot(data = DT_schedule[Day==7]) +
  # initial histogram
  geom_histogram(aes(x=Flow.rate.use.std.GPM),
                 breaks =seq(0,2,0.1),
                 binwidth = 0.1) +
  # titles
  ggtitle( "Histogram of Flow Rates" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title +
  labs(caption="from reference day, 78 draws") +
  # scales
  scale_x_continuous(name = "flow rate (GPM)",
                     breaks = seq(0,2,0.5 ),
                     minor_breaks = seq(0,2,0.1)) +
  scale_y_continuous(name = "number of events") 

# list the flow rates
DT_schedule[Day==7, list(Flow.rate.use.std.GPM)][order(Flow.rate.use.std.GPM)]

# save the plot
ggsave(filename = paste0(wd_charts,"hist_flow_rates_events.png"), 
       width = 5.25, height = 4 )

# calculate volume per event
DT_schedule[ , Event.Volume := (Flow.rate.use.std.GPM / 60) * Use.time.sec ]

# histogram by total volume
# bare plot with data
ggplot(data = DT_schedule[Day==7]) +
  # initial histogram
  geom_histogram(aes(x=Flow.rate.use.std.GPM,
                     weight = Event.Volume),
                 breaks =seq(0,2,0.1),
                 binwidth = 0.1) +
  # titles
  ggtitle( "Histogram of Flow Rates" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title +
  labs(caption="from reference day, 78 draws") +
  # scales
  scale_x_continuous(name = "flow rate (GPM)",
                     breaks = seq(0,2,0.5 ),
                     minor_breaks = seq(0,2,0.1)) +
  scale_y_continuous(name = "volume delivered (gal)") 

# save the plot
ggsave(filename = paste0(wd_charts,"hist_flow_rates_volumes.png"), 
       width = 5.25, height = 4 )

# save the data
# get date to include in file name
d <- format(Sys.time(), "%F")

# now to a csv file
write_csv(DT_schedule,
          path = paste0(wd_data,"draw_schedules_",d,".csv"),
          na = "")
