# results_charts.R
# script to plot energy wasted, water wasted, and loads not met
# for compact and distributed core
# and for normal and low flow
# Mon Sep 24 14:40:25 2018

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# load the results data
load(file = paste0(wd_data,"DT_results.Rdata"))

names(DT_results)
