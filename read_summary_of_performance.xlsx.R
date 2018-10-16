# read_summary_of_performance.xlsx.R
# script to read 'Model results - {Distributed|Compact} Core {Normal|Low} Flow 10-12-2018.xlsx'
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




