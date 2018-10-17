# summary_results_distrib_norm.xlsx.R
# script to read 'Model results - Distributed Core Normal Flow 10-12-2018.xlsx'
# and produce summary of performance tables 12-17 in final report
# # read_daily_ref_case.xlsx.R
# script to read 'Model results - Distributed Core Normal Flow 10-12-2018.xlsx'
# and produce daily performance tables 4-7 in final report
# "Tue Oct 16 12:04:49 2018"

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

# data range
# this is for day 7, 'Model results - Distributed Core Normal Flow 10-12-2018.xlsx'
data_range <- "FW3:GW44"

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
# this is for day 7, 'Model results - Distributed Core Normal Flow 10-12-2018.xlsx'
descrip_range <- "B3:C44"

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

# get indices of good Configuration
goodIdx <- !is.na(DT_summary$Configuration)

# get the non-NA values from Configuration
# Add a leading NA for later use when index into this vector
goodVals <- c(NA, DT_summary$Configuration[goodIdx])

# Fill the indices of the output vector with the indices pulled from
# these offsets of goodVals. Add 1 to avoid indexing to zero.
fillIdx <- cumsum(goodIdx)+1

# The original vector with gaps filled
goodVals[fillIdx]

# fix Configuration in DT_summary
DT_summary[, Configuration:= goodVals[fillIdx]]

# column of improved Identification
Identifications <- 
  c('WH1-G-NW-T1L-BR3M-Tee-FBS', 
    'WH1-G-NE-T1L-BR3M-Tee-FBS',
    'WH1-M-W-T1M-BR3M-Tee-FBS',
    'WH1-K-N-T1M-BR3M-Tee-FBS',	
    'WH1-G-NW-T1L-BR3L-Tee-FBS',
    'WH1-G-NW-T1L-BR3M-Mini-FBM',
    'WH1-G-NE-T1L-BR3M-Mini-FBM',
    'WH1-M-W-T1L-BR3S-Mini-FBM',
    'WH1-K-N-T1L-BR3S-Mini-FBM',
    'WH1-G-NW-T1L-BR3L-Mini-FBM',
    'WH1-G-NW-T1S-BR0-Cent-FBVL',
    'WH1-G-NE-T1S-BR0-Cent-FBVL',
    'WH1-M-W-T1S-BR0-Cent-FBVL',
    'WH1-K-N-T1S-BR0-Cent-FBL',
    'WH1-G-NW-T1L-BR0-Cent_NE-FBVL',
    'WH2-G-NW_M-W-T2S-BR3M-Tee-FBS',
    'WH2-B2-N_M-W-T2S-BR3M-Tee-FBS',
    'WH1-G-NW-T1VL-BR0-Tee-FBS',
    'WH1-M-W-T1VL-BR0-Tee-FBS',
    'WH1-G-SW-T1VL-BR0-Tee-FBS')

# add Identifications for Identification rows 2:21
DT_summary[ 2:21, Identification := Identifications]

# save as csv
write_excel_csv(DT_summary,
  path = paste0(wd_data, "summary_performance_distributed_norm.csv"),
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
                path = paste0(wd_data, "summary_relative_distributed_norm.csv"),
                na = "")

# save the summary and relative data.tables in one file
save(DT_summary, DT_relative, 
     file = paste0(wd_data, "summary_relative_distributed_norm.Rdata"))
