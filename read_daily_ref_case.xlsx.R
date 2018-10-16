# read_daily_ref_case.xlsx.R
# script to read 'Model results - Distributed Core Normal Flow 10-12-2018.xlsx'
# and produce daily performance tables 4-7 in final report
# "Mon Oct 15 20:16:57 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# set up path to model results
wd_model_results <-
  '/home/jiml/HotWaterResearch/projects/How Low/model results/2018-10-12/'

# file name
fn_model_results <-
  "Model results - Distributed Core Normal Flow 10-12-2018.xlsx"

# read range
# this is for day 7, 'Trunk&Branck - 3 branches' daily results
read_range <- "FV151:GW166"

# try straight read
tbl_results <-
  read_xlsx(path = paste0(wd_model_results,fn_model_results),
            range = read_range)

# ,
#             
#             col_types = 
#               # Day #,	Event Index,	Start Time,	Fixture ID,	Event Type,	
#               # Start Time is sometimes date, sometimes text
#               c("numeric","numeric","list","text","text",
#                 # Wait for Hot Water?,	Include Behavior Wait?,	
#                 "text", "text",
#                 # Behavior Wait Trigger (sec),	Behavior wait  (sec),	Use time (sec),
#                 "numeric", "numeric", "numeric", 
#                 #Flow rate - waiting (GPM)	Flow rate - use (GPM) [Normal flow rate]
#                 "numeric", "numeric",
#                 # skip column M, 
#                 "skip",
#                 # Flow rate - use (GPM) [Low flow rate]
#                 "numeric")
#   )

# turn the tibble into a data.table
DT_results <- data.table(tbl_results)

tables()
str(DT_results)
names(DT_results)

# first column is fixture_ID
setnames(DT_results, old = c('X__1'), new = c('fixture_ID'))

# extract necessary columns for reference results
DT_ref_results <-
  DT_results[ , list(
      `Fixture ID`  = `fixture_ID`,
      # for the energy table
      `HW Supply Energy (Btu)`,
      `To fixture - used` = `HW Energy To fixture - used`,
      `To fixture - wasted` = `HW Energy To fixture - wasted`,
      `Lost to Ambient - during use` = `HW Energy Lost to Ambient - during use`,
      `Stored in Pipe and Insulation` = `HW Energy Lost to Ambient - Cooldown`,
      `Energy Efficiency %`,
      # for the water table
      `Water Volume Supplied (Gallon)`,
      `Water Volume Used (Gallon)`,
      `Water Volume Wasted (Gallon)`,
      `Water Efficiency %`,
      # for the time table
      `Structural Waiting (Sec)`,
      `Behavior Waiting (Sec)`,
      `Total Waiting (Sec)`,
      `Use Duration (Sec)`,
      `Time Efficiency %`,
      # for the service table
      `Theoretical HW demand (Btu)`,
      `HW Energy To fixture - used`
      )
  ]

# calc loads not met
DT_ref_results[,`:=`(
      `Load not met (Btu)` = `Theoretical HW demand (Btu)` - `HW Energy To fixture - used`,
      `Load not met (%)`   = 
            (`Theoretical HW demand (Btu)` - `HW Energy To fixture - used`)/
              `Theoretical HW demand (Btu)`
      )
  ]

# multiply % by 100
DT_ref_results[,`:=`(
  `Energy Efficiency %` = `Energy Efficiency %` * 100,
  `Water Efficiency %`  = `Water Efficiency %`  * 100,
  `Time Efficiency %`   = `Time Efficiency %`   * 100,
  `Load not met (%)`    = `Load not met (%)`    * 100)
  ]
  
# remove Recirc & Cooldown
DT_ref_results <-
  DT_ref_results[ `Fixture ID` != 'Recirc' &
                  `Fixture ID` != 'Cooldown'  ]

# change `Load not met (%)` NaN to NA
DT_ref_results[ is.nan(`Load not met (%)`),
                `Load not met (%)` := NA]

