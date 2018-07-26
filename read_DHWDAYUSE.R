# read_DHWDAYUSE.R
# script to read hot water draw pattern information from
# /home/jiml/.PlayOnLinux/wineprefix/CBECC_Res19/drive_c/Program Files (x86)/CBECC-Res 2019/CSE/DHWDUSF.txt
# saves DT_DHWDAYUSES to .Rdata and .csv files
# Jim Lutz "Wed Jul 25 16:11:31 2018"

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

# define pattern for starts of DHWDAYUSE
pattern = "DHWDAYUSE \"[1-9][DEH][1-9]\"\n"  # look for this

# look at DHWDUSF around first DHWDAYUSE
str_sub(DHWDUSF, 
        str_locate(DHWDUSF, pattern)[1,'start']-10, 
        str_locate(DHWDUSF, pattern)[1,'end']+20)

# // find the starts of the DHWDAYUSE by person day type
starts <- str_locate_all(DHWDUSF, pattern)
starts <- starts[[1]][1:48,'end']  + 1
#  [1]  13518  15658  16928  17895  18862  20400  22540  23239  24287  26561  28600  30639  31606  32742  35552
# [16]  38764  39979  43560  46170  47908  50584  53194  55367  57474  59928  61833  63872  65610  66711  67779
# [31]  70422  72395  76323  81479  84054  86262  87565  89303  92146  94989  99890 106118 110000 113513 114614
# [46] 118094 124757 125524

# define pattern for ends of DHWDAYUSE
pattern = "ENDDHWDAYUSE"  # look for this

# look at DHWDUSF around first ENDDHWDAYUSE
str_sub(DHWDUSF, 
        str_locate(DHWDUSF, pattern)[1,'start']-10, 
        str_locate(DHWDUSF, pattern)[1,'end']+20)

# // find the ends of the DHWDAYUSE by person day type
ends <- str_locate_all(DHWDUSF, pattern)
ends <- ends[[1]][1:48,'start'] - 2
#  [1]  15627  16897  17864  18831  20369  22509  23208  24243  26530  28569  30608  31575  32711  35521  38733
# [16]  39935  43529  46139  47877  50553  53163  55336  57443  59884  61802  63841  65579  66680  67748  70391
# [31]  72364  76279  81448  84023  86231  87534  89272  92115  94958  99846 106087 109969 113482 114583 118063
# [46] 124726 125493 129274


# // extract the DHWDAYUSE by person day type
DHWDAYUSEs <- str_sub(DHWDUSF, starts, ends)
str(DHWDAYUSEs)
# chr [1:48] "  DWSH(  1.30,  1.667, 1.145,   0) DWSH(  1.87,  1.500, 1.014,   0) 
# DWSH(  2.10,  1.333, 1.179,   0) FAUC(  2.0"| __truncated__ ...

nchar(DHWDAYUSEs)
#  [1] 2110 1240  937  937 1508 2110  669 1005 2244 2009 2009  937 1106 2780 3182 1172 3551 2580 1708 2646 2580 2143
# [23] 2077 2411 1875 2009 1708 1071 1038 2613 1943 3885 5126 2545 2178 1273 1708 2813 2813 4858 6198 3852 3483 1071
# [45] 3450 6633  737 3751

# look at a short DHWDAYUSE
DHWDAYUSEs[47]

# find all enduse codes
unique(unlist(str_extract_all(DHWDAYUSEs, "[A-Z]{4}" )))
# [1] "DWSH" "FAUC" "SHWR" "CWSH" "BATH"

# insert a string to split DHWDAYUSES on
DHWDAYUSEs <- str_replace_all(DHWDAYUSEs, "(\\))[:space:]+(DWSH|FAUC|SHWR|CWSH|BATH)","\\1X\\2")

str(DHWDAYUSEs)
# chr [1:48] "  DWSH(  1.30,  1.667, 1.145,   0)XDWSH(  1.87,  1.500, 1.014,   0)XDWSH(  2.10,  1.333, 1.179,   0)XFAUC(  2.0"| __truncated__ ...

# split the DHWDAYUSEs
DHWDAYUSEs <- str_split(DHWDAYUSEs, 'X')

str(DHWDAYUSEs)
# List of 48

nchar(DHWDAYUSEs)
#  [1] 2275 1337 1013 1013 1626 2275  724 1085 2419 2167 2167 1013 1193 2996 3429 1265 3826 2780 1842 2852 2780
# [22] 2311 2239 2600 2023 2167 1842 1157 1121 2816 2095 4187 5521 2744 2347 1373 1842 3033 3033 5233 6676 4151
# [43] 3754 1157 3718 7145  796 4043

length(DHWDAYUSEs)
# 48

DHWDAYUSEs[47]

str(DHWDAYUSEs[47])
# List of 1
# $ : chr [1:22] "  FAUC(  8.47,  0.333, 0.928,   0)" "FAUC(  8.68,  0.167, 0.272,   1)" "FAUC(  8.69,  1.167, 0.770,   2)" "FAUC(  9.57,  0.167, 0.317,   3)" ...


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


