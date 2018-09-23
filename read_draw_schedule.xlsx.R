# read_draw_schedule.xlsx.R
# script to read 'Draw schedule for performance analysis.xlsx'
# "Tue Sep 11 18:51:25 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# try straight read
tbl_schedule <-
  read_xlsx(path = paste0(wd_data,"Draw schedule for performance analysis.standard 2018-09-21.xlsx"),
          range = "A3:N538",

          col_types = 
            # Day #,	Event Index,	Start Time,	Fixture ID,	Event Type,	
            # Start Time is sometimes date, sometimes text
            c("numeric","numeric","list","text","text",
              # Wait for Hot Water?,	Include Behavior Wait?,	
              "text", "text",
              # Behavior Wait Trigger (sec),	Behavior wait  (sec),	Use time (sec),
              "numeric", "numeric", "numeric", 
              #Flow rate - waiting (GPM)	Flow rate - use (GPM) [Normal flow rate]
              "numeric", "numeric",
              # skip column M, 
              "skip",
              # Flow rate - use (GPM) [Low flow rate]
              "numeric")
          )

# turn the tibble into a data.table
DT_schedule <- data.table(tbl_schedule)

tables()
str(DT_schedule)
names(DT_schedule)

# trouble w/ `Start Time`, in Excel sometimes it's a date, sometimes it's text
# reread that column twice & fix
# read as text
tbl_Start_Time.text <-
read_xlsx(path = paste0(wd_data,"Draw schedule for performance analysis.xlsx"),
          range = "C3:C538", col_types = "text")

# turn the tibble into a data.table
DT__Start_Time.text <- data.table(tbl_Start_Time.text)

# set an index number
DT__Start_Time.text[ , index:=.I]

# read as date
tbl_Start_Time.date <-
  read_xlsx(path = paste0(wd_data,"Draw schedule for performance analysis.xlsx"),
            range = "C3:C538", col_types = "date")

# turn the tibble into a data.table
DT__Start_Time.date <- data.table(tbl_Start_Time.date)

# set an index number
DT__Start_Time.date[ , index:=.I]

# merge the 2
DT_Start_time <-
merge(DT__Start_Time.text, DT__Start_Time.date, by = 'index', all = TRUE)

str(DT_Start_time)

# set Start_Time to POSIXct of Start Time.x when `Start Time.y` is NA
DT_Start_time[is.na(`Start Time.y`) , Start_Time := mdy_hms(`Start Time.x`)]

# set Start_Time to Start Time.y when Start_Time is NA
DT_Start_time[is.na(Start_Time) , Start_Time := `Start Time.y`]

str(DT_Start_time)
# looks like it worked

# add the corrected Start_Time
DT_schedule[, Start_Time := DT_Start_time[ , list(Start_Time) ]]

DT_schedule[c(1:5,533:535), list(`Start Time`, Start_Time)]
# looks like that worked

# set 'Start Time' to 'Start_Time'
DT_schedule[, `Start Time` := Start_Time]
DT_schedule[,  Start_Time := NULL]
str(DT_schedule)

# look at 'Fixture_ID'
DT_schedule[ , list(n=.N), by=c('Fixture ID')][order(-n)]
#     Fixture ID   n
#  1:       K_SK 147
#  2:     B2_SK1  92
#  3:     MB_SK1  74
#  4:      LN_WA  47
#  5:     MB_SK2  42
#  6:     B2_SK2  41
#  7:     Recirc  34
#  8:      B3_SK  22
#  9:     ReCirc  11
# 10:       K_DW  10
# 11:      B2_SH   9
# 12:      MB_SH   6

# look for showers > 1.8, notice left single quotes
DT_shower.fix <-
DT_schedule[str_detect(`Fixture ID`, '_SH') & `Flow rate - use (GPM)` > 1.8, 
            list( `Day #`, Start_Time, `Fixture ID`, `Flow rate - use (GPM)`)]
#     Day #          Start_Time Fixture ID Flow rate - use (GPM)
# 1:     2 2009-01-03 04:41:24      B2_SH                 2.902
# 2:     3 2009-01-29 14:48:36      B2_SH                 3.457

# look kitchen sink draws > 1.8
DT_schedule[str_detect(`Fixture ID`, 'K_SK') , #& `Flow rate - use (GPM)` > 1.8, 
            list( `Day #`, Start_Time, `Fixture ID`, `Flow rate - use (GPM)`)][
              order(-`Flow rate - use (GPM)`)]
# those are all good, < 1.8

# look bath sink draws > 1.2
DT_bath_sink.fix <-
DT_schedule[!str_detect(`Fixture ID`, 'K_SK') &
              str_detect(`Fixture ID`, '_SK') &
              `Flow rate - use (GPM)` > 1.2 ,
            list( `Day #`, Start_Time, `Fixture ID`, `Flow rate - use (GPM)`)][
              order(-`Flow rate - use (GPM)`)]

DT_bath_sink.fix[]
# there's 28 of them.

names(DT_schedule)
# add norm & low to "Flow rate - use (GPM)" names to distinguish them
setnames(DT_schedule, 
         old = c('Flow rate - use (GPM)','Flow rate - use (GPM)__1'),
         new = c('Flow rate - use [norm] (GPM)','Flow rate - use [low] (GPM)'))

str(DT_schedule)


