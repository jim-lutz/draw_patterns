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

# get list of results files in the directory
l_results <- list.files(path = d_results, pattern = "M*09-14-2018.xlsx")


