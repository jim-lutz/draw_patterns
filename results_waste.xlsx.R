# results_waste.xlsx.R
# script to read Model Results from 09-14-2018 spreadsheets
# to get energy wasted, water wasted, and loads not met
# for compact and distributed core
# and for normal and low flow
# Mon Sep 24 14:40:25 2018

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get the spreadsheet names
d_results <- "/home/jiml/HotWaterResearch/projects/How Low/model results/"

# get list of results file names in that directory
l_fn_results <- 
  list.files(path = d_results, pattern = "^Model.*09-14-2018.xlsx")

l_descripts <- c('compact, low','compact, std','distributed, low','distributed, std')

# list of spreadsheet results ranges
l_results_range <- c('FW3:GW35',  # compact, low
                   'FW3:GW35',  # compact, std
                   'FW3:GW44',  # distributed, low
                   'FW3:GW44') # distributed, std

# list of spreadsheet cases ranges
l_cases_range <- c('A4:C35',  # compact, low
                   'A4:C35',  # compact, std
                   'A4:C44',  # distributed, low
                   'A4:C44')  # distributed, std


DT_results_compact <- NULL
# for first spreadsheet
s=1

# read cases from spreadsheet
tbl_cases <-
  read_xlsx(path = paste0(d_results,l_fn_results[s]),
            range = l_cases_range[s],
            col_names = c('case','layout','WH_location')
            )

# read results from spreadsheet
tbl_results <-
  read_xlsx(path = paste0(d_results,l_fn_results[s]),
            range = l_results_range[s])

# combine the tibbles horizontally
tbl_spreadsheet <- bind_cols(tbl_cases,tbl_results)

# add the config
tbl_spreadsheet <- add_column(tbl_spreadsheet, config=l_descripts[s])





# turn into a data table and add config description
DT_results_compact <- 
  rbind(DT_results_compact, data.table(tbl_spreadsheet) )



            



