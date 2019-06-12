# scatter_day7.R
# script generate scatter plot of flowrates 
# by duration of draw for reference day
# "Wed Jun 12 15:33:36 2019"

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

# make scatter plot of draws of flowrates by duration
# bare plot with data
ggplot(data = DT_schedule[Day==7]) +
  # initial histogram
  geom_jitter(aes(x=Flow.rate.use.std.GPM,
                 y=Use.time.sec),
             width=NULL, height=5) +
  # scales
  scale_x_continuous(name = "flow rate (GPM)",
                     breaks = seq(0,2,0.5 ),
                     minor_breaks = seq(0,2,0.1)) +
  scale_y_continuous(name = "duration of draws",
                     breaks = seq(0, 420,60)) +
  
# titles
  ggtitle( "Histogram of Flow Rates" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title +
  labs(caption="from reference day, 78 draws") +

# list the flow rates
DT_schedule[Day==7, list(Flow.rate.use.std.GPM)][order(Flow.rate.use.std.GPM)]

