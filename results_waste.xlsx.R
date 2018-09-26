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

# descriptions of core configuration
l_cores <- c('compact','compact','distributed','distributed')

# descriptions of flow regimes
l_flows <- c('low','std','low','std')

# list of spreadsheet results ranges
l_results_range <- c('FW3:GW35', # compact, low
                   'FW3:GW35',   # compact, std
                   'FW3:GW44',   # distributed, low
                   'FW3:GW44')   # distributed, std

# list of spreadsheet cases ranges
l_cases_range <- c('A4:C35',  # compact, low
                   'A4:C35',  # compact, std
                   'A4:C44',  # distributed, low
                   'A4:C44')  # distributed, std

# blank tibble
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
  
  # add the cores
  tbl_results2 <- add_column(tbl_results1, core=l_cores[s], .before = 'WH_location')
  
  # add the flows
  tbl_results3 <- add_column(tbl_results2, flow=l_flows[s], .before = 'WH_location')
  
  # add to overall tbl_results
  tbl_results <- bind_rows(tbl_results,tbl_results3)
  
  # remove temporary tibbles
  rm(tbl_cases, tbl_result_values, tbl_results1, tbl_results2, tbl_results3 )
  
}

# turn the results tibble into a data table
DT_results <- data.table(tbl_results) 

# names(DT_results)
# str(DT_results)

# fix the names 
setnames(DT_results,
         old = c("case","layout", "core", "flow",
                 "WH_location","HW Supply Energy (Btu)",
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
                 "# of draws with final temperature exceed threshold temperature"
                 ),
         new = c('case', 'layout', "core", "flow",
                 'WH_location', 
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
                 'HW_draws_temp_met'  
                 )
         )

# get rid of X__ variables
DT_results[, c('X__1','X__2','X__3') := NULL]

# add index of original order
DT_results[ , index := .I ]


# names(DT_results)

# look at layout
DT_results[, list(n = .N) , by=layout]
which(is.na(DT_results$layout))

# fill in missing layouts
DT_results <- fill(DT_results, layout )

# check that it worked 
DT_results[60:80, list(case, layout, core, flow)]
which(is.na(DT_results$layout))
# integer(0)

# identifiers
# from /How Low/model results/Summary results energy wasted and loads not met - Distributed Core Normal Flow 09-14-2018.xlsx
l_identifiers <- c("WH1-G-NW-T1L-BR3M-Tee-FBS",
                "WH1-G-NE-T1L-BR3M-Tee-FBS",
                "WH1-M-W-T1M-BR3M-Tee-FBS",
                "WH1-K-N-T1M-BR3M-Tee-FBS",
                "WH1-G-NW-T1L-BR3L-Tee-FBS",
                "WH1-G-NW-T1L-BR3M-Mini-FBM",
                "WH1-G-NE-T1L-BR3M-Mini-FBM",
                "WH1-M-W-T1L-BR3S-Mini-FBM",
                "WH1-K-N-T1L-BR3S-Mini-FBM",
                "WH1-G-NW-T1L-BR3L-Mini-FBM",
                "WH1-G-NW-T1S-BR0-Cent-FBVL",
                "WH1-G-NE-T1S-BR0-Cent-FBVL",
                "WH1-M-W-T1S-BR0-Cent-FBVL",
                "WH1-K-N-T1S-BR0-Cent-FBL",
                "WH1-G-NW-T1L-BR0-Cent_NE-FBVL",
                "WH2-G-NW_M-W-T2S-BR3M-Tee-FBS",
                "WH2-B2-N_M-W-T2S-BR3M-Tee-FBS",
                "WH1-G-NW-T1VL-BR0-Tee-FBS",
                "WH1-M-W-T1VL-BR0-Tee-FBS",
                "WH1-G-SW-T1VL-BR0-Tee-FBS")
length(l_identifiers)
# [1] 20

# add  identifier
DT_results[, identifier:= '']

# for distributed core, low flow 
DT_results[core == 'distributed' & 
             flow == 'low' &
             ! str_detect(WH_location,"pipe") & # exclude small pipes
             ! str_detect(layout, 'manual') & # exclude manual recirc
             ! str_detect(layout, 'timer') ,  # exclude timer recirc
           identifier := l_identifiers ]

# add  identifiers for distributed core, std flow 
DT_results[core == 'distributed' & 
             flow == 'std' &
             !str_detect(WH_location,"pipe") & # exclude small pipes
             ! str_detect(layout, 'manual') & # exclude manual recirc
             ! str_detect(layout, 'timer') ,  # exclude timer recirc
           # list(layout, core, flow, WH_location)]
           identifier := l_identifiers ]

# confirm extracted correct values
# by manually comparing the following to the values in the spreadsheets
DT_results[core == 'distributed' & flow == 'low',
           list(case, layout, core, flow, HW_energy_in)]
# looks right

DT_results[core == 'distributed' & flow == 'low',
           list(case, layout, core, flow, HW_energy_ideal_use)]
# OK

DT_results[core == 'compact' & flow == 'low',
           list(case, layout, core, flow, HW_volume_in)]
# OK

DT_results[core == 'compact' & flow == 'low',
           list(case, layout, core, flow, HW_volume_used)]
# OK

DT_results[core == 'compact' & flow == 'std',
           list(case, layout, core, flow, HW_energy_used)]
# OK


# calculate wasted energy
DT_results[, HW_energy_excess := HW_energy_in - HW_energy_ideal_use]

# calculate wasted water
DT_results[, HW_volume_excess := HW_volume_in - HW_volume_used]

# calculate loads not met 
DT_results[, HW_energy_not_met := HW_energy_ideal_use - HW_energy_used]


# save the results for later use
save(DT_results, file = paste0(wd_data,"DT_results.Rdata"))

