# summary_results_compact_norm.xlsx.R
# script to read 'Model results - Compact Core Normal Flow 10-12-2018.xlsx'
# and produce summary of performance tables 12-17 in final report
# "Tue Oct 16 19:13:38 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# set up path to model results
wd_model_results <-
  '/home/jiml/HotWaterResearch/projects/How Low/model results/2018-10-12/'

# file name
fn_model_results <-
  "Model results - Compact Core Normal Flow 10-12-2018.xlsx"

# data range
# this is for day 7, 'Model results - Compact Core Normal Flow 10-12-2018.xlsx'
data_range <- "FW3:GW35"

# read the data
tbl_data_results <-
  read_xlsx(path = paste0(wd_model_results,fn_model_results),
            range = data_range)

# find the 'X__?' columns
blank_cols <- grep("X__", names(tbl_data_results))

# remove the 'X__' columns
tbl_data_results <-
  tbl_data_results[, -blank_cols]

names(tbl_data_results)

# case descriptions
# this is for day 7, 'Model results - Compact Core Normal Flow 10-12-2018.xlsx'
descrip_range <- "B3:C35"

# read the case descriptions
tbl_descrip_results <-
  read_xlsx(path = paste0(wd_model_results,fn_model_results),
            range = descrip_range)

# combine the 2 tibbles into a data.table
DT_results <-
  data.table(cbind(tbl_descrip_results, tbl_data_results))
str(DT_results)

names(DT_results)
# set names for first 2 columns
setnames(DT_results, old = c(1,2),
         new = c('Configuration', 'Identification'))

# get the summary results
DT_summary <-
  DT_results[, list(
    `Configuration`,
    `Identification`,
    `Energy into HWDS (BTU)` = `HW Supply Energy (Btu)`,
    `Water into HWDS (gallons)` = `Water Volume Supplied (Gallon)`,
    `Time Water is Flowing (seconds)` = `Total Waiting (Sec)` +
                                        `Use Duration (Sec)`,
    `Load not Met (BTU)` = `Theoretical HW demand (Btu)` - 
                                         `HW Energy To fixture - used`
    )]

# get the ideal results
DT_ideal <- data.table(
  `Configuration`                   = 'Reference',
  `Identification`                  = 'Ideal',
  `Energy into HWDS (BTU)`          = 
                                DT_results[1, `Theoretical HW demand (Btu)`],
  `Water into HWDS (gallons)`       = 
                                DT_results[1, `Water Volume Used (Gallon)`],
  `Time Water is Flowing (seconds)` = 
                                DT_results[1, `Use Duration (Sec)`],
  `Load not Met (BTU)`              = 0
)

# put the ideal reference at the top of the summary
DT_summary <- rbind(DT_ideal,DT_summary)

# fix Identification
DT_summary[ Identification == 'WH in garage',
            Identification := 'WH in NE garage']
DT_summary[ Identification == 'WH in wet room rectangle',
            Identification := 'WH in laundry']

# save as csv
write_excel_csv(DT_summary,
  path = paste0(wd_data, "summary_performance_compact_norm.csv"),
  na = "")

# create the relative summary
DT_relative <-
  DT_summary[, list(
    Configuration,
    Identification,
    `Energy into HWDS (BTU)` = 
        `Energy into HWDS (BTU)` / `Energy into HWDS (BTU)`[1],
  
    `Water into HWDS (gallons)` = 
        `Water into HWDS (gallons)` / `Water into HWDS (gallons)`[1],
    
    `Time Water is Flowing (seconds)` = 
        `Time Water is Flowing (seconds)` / `Time Water is Flowing (seconds)`[1],
    
    `Load not Met (BTU)` =
        `Load not Met (BTU)`/`Energy into HWDS (BTU)`[1]
  )]

# save as csv
write_excel_csv(DT_relative,
                path = paste0(wd_data, "summary_relative_compact_norm.csv"),
                na = "")

# save the summary and relative data.tables in one file
save(DT_summary, DT_relative, 
     file = paste0(wd_data, "summary_relative_compact_norm.Rdata"))
