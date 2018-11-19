# load.summary_relative_data.R
# loads the data and returns one DT_relative data.table

# first distributed_norm
load(file = paste0(wd_data,"summary_relative_distributed_norm.Rdata"))

tables()
#           NAME NROW NCOL MB
# 1: DT_relative   42    6  0
# 2:  DT_summary   42    6  0

# remove the summary table
rm(DT_summary)

# rename the relative table 
# this actually just relinks to the same data, since nothing is modified
DT_relative_dist_norm <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# add flow normal
DT_relative_dist_norm[, flow:='norm']

# add core dist
DT_relative_dist_norm[, core:='dist']


# then distributed_low
load(file = paste0(wd_data,"summary_relative_distributed_low.Rdata"))

tables()

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


# then compact_norm
load(file = paste0(wd_data,"summary_relative_compact_norm.Rdata"))

tables()

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_compact_norm <- DT_relative
# remove the DT_relative name
rm(DT_relative)

# add flow normal
DT_relative_compact_norm[, flow:='norm']

# add core compact
DT_relative_compact_norm[, core:='compact']


# then compact_low
load(file = paste0(wd_data,"summary_relative_compact_low.Rdata"))

tables()

# remove the summary table
rm(DT_summary)

# rename the relative table
# this actually just relinks to the same data, since nothing is modified
DT_relative_compact_low <- DT_relative
# remove the DT_relative name
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