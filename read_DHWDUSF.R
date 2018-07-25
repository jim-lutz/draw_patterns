# read_DHWDUSF.R
# script to read hot water draw pattern information 
# /home/jiml/.PlayOnLinux/wineprefix/CBECC_Res19/drive_c/Program Files (x86)/CBECC-Res 2019/CSE/DHWDUSF.txt
# saves output to .Rdata files
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

str(DHWDUSF) # "chr"
length(DHWDUSF) #1
str_length(DHWDUSF) # [1] 129357


# try grepping locations of "$dayofyear," out of DHWDUSF 

# http://rfunction.com/archives/1719
pattern = "\\$dayofyear,"

# //365 day DHW Profile by number of Bedrooms
starts <- str_locate_all(DHWDUSF, pattern)

# [[1]]
#      start  end
# [1,]   681  691
# [2,]  2930 2940
# [3,]  5179 5189
# [4,]  7428 7438
# [5,]  9677 9687

starts[[1]][2]
# [1] 2930
starts[[1]][3]
# [1] 5179
starts[[1]][3,2]
#  end 
# 5189 
str(starts[[1]][3,2])
# Named int 5189
# - attr(*, "names")= chr "end"
unlist(starts)
# [1]  681 2930 5179 7428 9677  691 2940 5189 7438 9687
starts[[1]]$end

starts[[1]][1:5]
# [1]  681 2930 5179 7428 9677
starts[[1]][1:5,1:2]
#      start  end
# [1,]   681  691
# [2,]  2930 2940
# [3,]  5179 5189
# [4,]  7428 7438
# [5,]  9677 9687
starts[[1]][1:5,'end']
# [1]  691 2940 5189 7438 9687
 

str_sub(DHWDUSF, 681,691)

# save the test info data as a csv file
write.csv(DT_test_info, file= paste0(wd_data,"DT_test_info.csv"), row.names = FALSE)

# save the test info data as an .Rdata file
save(DT_test_info, file = paste0(wd_data,"DT_test_info.Rdata"))


