# read_DHWDUSF.R
# script to read hot water draw pattern information 
# /home/jiml/.PlayOnLinux/wineprefix/CBECC_Res19/drive_c/Program Files (x86)/CBECC-Res 2019/CSE/DHWDUSF.txt
# saves DT_DHWProfiles to .Rdata and .csv files
# Jim Lutz "Thu Jul 12 09:00:24 2018"

# set packages & etc
source("setup.R")

# set up paths to working directories
source("setup_wd.R")

# get some useful functions
# source("functions.R")
# nothing here yet

# filename for DHWDUSF
fn_DHWDUSF <- "/home/jiml/.PlayOnLinux/wineprefix/CBECC_Res19/drive_c/Program Files (x86)/CBECC-Res 2019/CSE/DHWDUSF.txt"

# read DHWDUSF
DHWDUSF <- read_file(fn_DHWDUSF)

# // find the starts of the 365 day DHW Profile by number of Bedrooms
pattern = "\\$dayofyear,"  # look for this
starts <- str_locate_all(DHWDUSF, pattern)
starts <- starts[[1]][1:5,'end']  + 1
# [1]  692 2941 5190 7439 9688

# // find the ends of the 365 day DHW Profile by number of Bedrooms
# "2D2")
pattern = "\\\"{1}[1-9][DEH][1-9]\\\"\\)"  # look for this
ends <- str_locate_all(DHWDUSF, pattern)
ends <- ends[[1]][1:5,'end'] - 1
# 1]  2902  5151  7400  9649 11898

# // extract the 365 day DHW Profile by number of Bedrooms
DHWProfiles <- str_sub(DHWDUSF, starts, ends)
str(DHWProfiles)
# chr [1:5] "\"1H1\",\"1D3\",\"3E2\",\"1E1\",\"1D5\",\"1D2\",\"4D4\",\"2D1\",\"4D5\",\"2E2\",\"1E1\",
# \"4D2\",\"1D1\",\"1D3\""| __truncated__ ...

nchar(DHWProfiles)
# [1] 2211 2211 2211 2211 2211

# remove the \\\n
DHWProfiles <- str_remove_all(DHWProfiles, '\\\n')

nchar(DHWProfiles)
# [1] 2200 2200 2200 2200 2200

# remove the \"
DHWProfiles <- str_remove_all(DHWProfiles, '\"')

nchar(DHWProfiles)
# [1] 1470 1470 1470 1470 1470

# split the DHWProfiles
DHWProfiles <- str_split(DHWProfiles, ',')
str(DHWProfiles)

# List of 5
#  $ : chr [1:365] "1H1" "1D3" "3E2" "1E1" ...
#  $ : chr [1:365] "1H1" "3D3" "1E2" "4E1" ...
#  $ : chr [1:365] "3H1" "1D3" "2E2" "4E1" ...
#  $ : chr [1:365] "3H1" "6D3" "1E2" "2E1" ...
#  $ : chr [1:365] "4H1" "2D3" "5E2" "3E1" ...

# // find the names of the 365 day DHW Profile by number of Bedrooms
# DHW5BR
pattern = "DHW[1-9]BR"  # look for this
DHWProfileNames <- str_match_all(DHWDUSF, pattern)
DHWProfileNames <- DHWProfileNames[[1]][1:5,1] 

# turn the DHWProfiles into a data.table
DT_DHWProfiles <- data.table( day=1:365) # a null data.table
DT_DHWProfiles[,(DHWProfileNames) := (DHWProfiles) ]


# save the DT_DHWProfiles data as a csv file
write.csv(DT_DHWProfiles, file= paste0(wd_data,"DT_DHWProfiles.csv"), row.names = FALSE)

# save the test info data as an .Rdata file
save(DT_DHWProfiles, file = paste0(wd_data,"DT_DHWProfiles7.Rdata"))


