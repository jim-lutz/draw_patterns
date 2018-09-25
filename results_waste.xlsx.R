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

# for spreadsheets for compact core
tbl_results <- NULL

# loop through spreadsheets
# s=1 # debugging only
for(s in 1:4) {
  
  # read cases from spreadsheet
  tbl_cases <-
    read_xlsx(path = paste0(d_results,l_fn_results[s]),
              range = l_cases_range[s],
              col_names = c('case','layout','WH_location')
              )
  
  # read results from spreadsheet
  tbl_result_values <-
    read_xlsx(path = paste0(d_results,l_fn_results[s]),
              range = l_results_range[s])
  
  # combine the tibbles horizontally
  tbl_results1 <- bind_cols(tbl_cases,tbl_result_values)
  
  # add the config
  tbl_results2 <- add_column(tbl_results1, config=l_descripts[s])
  
  # add to overall tbl_results
  tbl_results <- bind_rows(tbl_results,tbl_results2)

}

# turn the results tibble into a data table
DT_results_compact <- data.table(tbl_results) 

names(DT_results_compact)
str(DT_results_compact)




            



