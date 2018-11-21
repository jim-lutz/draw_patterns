# load.summary_relative_data.R
# loads summary_relative_{distributed|compact}_{norm|low}.Rdata
# returns one big DT_relative data.table
# creates revised relative and performance tables for low flow

#-#-#-# distributed_norm ##################
load(file = paste0(wd_data,"summary_relative_distributed_norm.Rdata"))

tables()
#           NAME NROW NCOL MB
# 1: DT_relative   42    6  0
# 2:  DT_summary   42    6  0

# what's in the tables
names(DT_relative)
names(DT_summary)

# get Ideal for normal flow case for use in the low flow cases
DT_ideal_norm <-
  DT_summary[Identification=="Ideal", ]

# remove the summary table
rm(DT_summary)

# rename the relative table 
# this actually just relinks to the same data, since nothing is modified
DT_relative_dist_norm <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# add flow norm
DT_relative_dist_norm[, flow:='norm']

# add core dist
DT_relative_dist_norm[, core:='dist']


#-#-#-# distributed_low ##################
# now get distributed_low summary and relative data
load(file = paste0(wd_data,"summary_relative_distributed_low.Rdata"))

tables()

# rebuild DT_relative using the DT_summary and DT_ideal_norm
# replace first row of DT_summary with DT_ideal_norm
DT_summary[1, names(DT_summary) := DT_ideal_norm[1]]

# save the distributed_low summary performance as csv
write_excel_csv(DT_summary,
                path = paste0(wd_data, 
                              "summary_performance_distributed_low_",
                              format(Sys.time(), "%F"),
                              ".csv"),
                na = "")

# create the relative distributed_low
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

# save the distributed_low summary relative as csv
write_excel_csv(DT_relative,
                path = paste0(wd_data, 
                              "summary_relative_distributed_low_",
                              format(Sys.time(), "%F"),
                              ".csv"),
                na = "")

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_dist_low <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# add flow low
DT_relative_dist_low[, flow:='low']

# add core dist
DT_relative_dist_low[, core:='dist']


#-#-#-# compact_norm ##################
# now get the compact_norm
load(file = paste0(wd_data,"summary_relative_compact_norm.Rdata"))

tables()

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_compact_norm <- DT_relative

# remove DT_relative
rm(DT_relative)

# add flow normal
DT_relative_compact_norm[, flow:='norm']

# add core compact
DT_relative_compact_norm[, core:='compact']


#-#-#-# compact_low ##################
# then compact_low
load(file = paste0(wd_data,"summary_relative_compact_low.Rdata"))

tables()

# rebuild DT_relative using the DT_summary and DT_ideal_norm
# replace first row of DT_summary with DT_ideal_norm
DT_summary[1, names(DT_summary) := DT_ideal_norm[1]]

# save the compact_low summary performance as csv
write_excel_csv(DT_summary,
                path = paste0(wd_data, 
                              "summary_performance_compact_low_",
                              format(Sys.time(), "%F"),
                              ".csv"),
                na = "")

# create the relative compact_low
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

# save the compact_low summary relative as csv
write_excel_csv(DT_relative,
                path = paste0(wd_data, 
                              "summary_relative_compact_low_",
                              format(Sys.time(), "%F"),
                              ".csv"),
                na = "")

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_compact_low <- DT_relative

# remove DT_relative
rm(DT_relative)

# add flow low
DT_relative_compact_low[, flow:='low']

# add core compact
DT_relative_compact_low[, core:='compact']


# combine all four tables
DT_relative <-
  rbindlist(list(DT_relative_dist_norm, DT_relative_dist_low,
                 DT_relative_compact_norm, DT_relative_compact_low))

# remove the DT_relative_x data.tables
rm(DT_relative_dist_norm, DT_relative_dist_low,
  DT_relative_compact_norm, DT_relative_compact_low)
