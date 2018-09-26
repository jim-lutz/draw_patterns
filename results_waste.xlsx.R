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
  list.files(path = d_results, pattern = "^Model results.*09-14-2018.xlsx")

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
DT_results <- data.table(tbl_results) 

names(DT_results)
str(DT_results)

# fix the names 
setnames(DT_results,
         old = c("case","layout","WH_location","HW Supply Energy (Btu)",
                 "HW Energy To fixture - used","HW Energy To fixture - wasted",
                 "HW Energy Lost to Ambient - during use","HW Energy Lost to Ambient - Cooldown",
                 "Recirc Loop Pipe Heat Loss (Btu)","Energy Efficiency %",
                 "Theoretical HW demand (Btu)","% Btu demand not met",
                 "X__1",
                 "Water Volume Supplied (Gallon)","Water Volume Used (Gallon)",
                 "Water Volume Wasted (Gallon)","Water Efficiency %",
                 "X__2",
                 "Structural Waiting (Sec)","Behavior Waiting (Sec)","Total Waiting (Sec)",
                 "Use Duration (Sec)","Time Efficiency %",
                 "X__3",
                 "# of draws","# of draws with waiting",
                 "# of draws with behavioral waiting","# of draws with waiting >15 second",
                 "# of draws trigger behavioral waiting",
                 "# of draws with final temperature exceed threshold temperature",
                 "config"),
         new = c('case', 'layout', 'WH_location', 
                 'HW_energy_in', 'HW_energy_used', 'HW_energy_wasted', 
                 'HW_energy_loss_use', 'HW_energy_loss_cooldown', 
                 'HW_energy_loss_recirc', 'HW_energy_effy', 
                 'HW_energy_ideal_use', 'HW_energy_not_met_effy', 
                 'X__1', 
                 'HW_volume_in', 'HW_volume_used', 'HW_volume_wasted', 
                 'HW_volume_effy', 
                 'X__2', 
                 'HW_time_wait_structural', 'HW_time_wait_behavioral', 
                 'HW_time_wait_total', 'HW_time_used', 'HW_time_effy', 
                 'X__3', 
                 'HW_draws', 'HW_draws_wait', 'HW_draws_wait_behavioral', 
                 'HW_draws_wait_15', 'HW_draws_wait_behavioral_trigger', 
                 'HW_draws_temp_met',  
                 'config')
         )

# get rid of X__
DT_results[, c('X__1','X__2','X__3') := NULL]

# confirm extracted correct values from spreadsheets
DT_results[config == 'distributed, std',
           list(case, layout, WH_location,HW_energy_in)]
# looks right

DT_results[config == 'distributed, low',
           list(case, layout, WH_location,HW_energy_ideal_use)]
# OK

DT_results[config == 'compact, low',
           list(case, layout, WH_location,HW_volume_in)]
# OK

DT_results[config == 'compact, low',
           list(case, layout, WH_location,HW_volume_used)]
# OK

DT_results[config == 'compact, std',
           list(case, layout, WH_location,HW_energy_used)]
# OK


# calculate wasted energy
DT_results[, HW_energy_excess := HW_energy_in - HW_energy_ideal_use]

# calculate wasted water
DT_results[, HW_volume_excess := HW_volume_in - HW_volume_used]

# calculate loads not met 
DT_results[, HW_energy_not_met := HW_energy_ideal_use - HW_energy_used]


# save the results for later use
save(DT_results, file = paste0(wd_data,"DT_results.Rdata"))

