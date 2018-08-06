# read_DHWDAYUSE.R
# script to read DHWDAYUSE (daily draw pattern for number of people and day type) from
# /home/jiml/.PlayOnLinux/wineprefix/CBECC_Res19/drive_c/Program Files (x86)/CBECC-Res 2019/CSE/DHWDUSF.txt
# saves DT_DHWUSEs to .Rdata and .csv files
# Jim Lutz "Wed Jul 25 16:11:31 2018"

# from CSE Users Manual
# DHWDAYUSE
# Defines an object that represents domestic hot water use for a single day. A DHWDAYUSE contains a 
# collection of DHWUSE objects that specify the time, volume, and duration of individual draws.

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

# get the DHWDAYUSE names
DHWDAYUSE_names <- str_extract_all(as.character(DHWDUSF), "DHWDAYUSE \"[1-9][DEH][1-9]")
DHWDAYUSE_names <- str_extract_all(as.character(DHWDAYUSE_names), "[1-9][DEH][1-9]")

# get the DHWDAYUSEs

# define pattern for starts of DHWDAYUSE
pattern = "DHWDAYUSE \"[1-9][DEH][1-9]\"\n"  # look for this

# look at DHWDUSF around first DHWDAYUSE
str_sub(DHWDUSF, 
        str_locate(DHWDUSF, pattern)[1,'start']-10, 
        str_locate(DHWDUSF, pattern)[1,'end']+20)

# // find the starts of the DHWDAYUSE by person day type
starts <- str_locate_all(DHWDUSF, pattern)
starts <- starts[[1]][1:48,'end']  + 1
#  [1]  13518  15658  16928  17895  18862  20400  22540  23239  24287  26561  28600
# [12]  30639  31606  32742  35552  38764  39979  43560  46170  47908  50584  53194
# [23]  55367  57474  59928  61833  63872  65610  66711  67779  70422  72395  76323
# [34]  81479  84054  86262  87565  89303  92146  94989  99890 106118 110000 113513
# [45] 114614 118094 124757 125524

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

#  extract the DHWDAYUSE by person day type
DHWDAYUSEs <- str_sub(DHWDUSF, starts, ends)
str(DHWDAYUSEs)
# chr [1:48] "  DWSH(  1.30,  1.667, 1.145,   0) DWSH(  1.87,  1.500, 1.014,   0) 
# DWSH(  2.10,  1.333, 1.179,   0) FAUC(  2.0"| __truncated__ ...

nchar(DHWDAYUSEs)
#  [1] 2110 1240  937  937 1508 2110  669 1005 2244 2009 2009  937 1106 2780 3182 1172 3551 2580 1708 2646 2580 2143
# [23] 2077 2411 1875 2009 1708 1071 1038 2613 1943 3885 5126 2545 2178 1273 1708 2813 2813 4858 6198 3852 3483 1071
# [45] 3450 6633  737 3751

# remove extraneous whitespace
DHWDAYUSEs <- str_trim(DHWDAYUSEs, side = "both" )

# look at a short DHWDAYUSE
DHWDAYUSEs[47]

# find all enduse codes
unique(unlist(str_extract_all(DHWDAYUSEs, "[A-Z]{4}" )))
# [1] "DWSH" "FAUC" "SHWR" "CWSH" "BATH"

# insert a string 'X' to split DHWDAYUSES on
DHWDAYUSEs <- str_replace_all(DHWDAYUSEs, "(\\))[:space:]+(DWSH|FAUC|SHWR|CWSH|BATH)","\\1X\\2")
DHWDAYUSEs[47]

# split the DHWDAYUSEs on X
DHWDAYUSEs <- str_split(DHWDAYUSEs, 'X')

str(DHWDAYUSEs)
# List of 48

nchar(DHWDAYUSEs)
#  [1] 2273 1335 1011 1011 1624 2273  722 1083 2417 2165 2165 1011 1191 2994 3427 1263 3824 2778 1840 2850 2778
# [22] 2309 2237 2598 2021 2165 1840 1155 1119 2814 2093 4185 5519 2742 2345 1371 1840 3031 3031 5231 6674 4149
# [43] 3752 1155 3716 7143  794 4041

length(DHWDAYUSEs)
# 48

DHWDAYUSEs[47]

str(DHWDAYUSEs[47])
# List of 1
# $ : chr [1:22] "  FAUC(  8.47,  0.333, 0.928,   0)" "FAUC(  8.68,  0.167, 0.272,   1)" "FAUC(  8.69,  1.167, 0.770,   2)" "FAUC(  9.57,  0.167, 0.317,   3)" ...

str(DHWDAYUSEs, nchar.max = 30, strict.width = "cut")

# names of DHWDAYUSEs
names(DHWDAYUSEs)
# NULL
names(DHWDAYUSEs) <- unlist(DHWDAYUSE_names)
str(DHWDAYUSEs, nchar.max = 30, strict.width = "cut")
names(DHWDAYUSEs)
#  [1] "1D1" "1D2" "1D3" "1D4" "1D5" "1E1" "1E2" "1H1" "2D1" "2D2" "2D3" "2D4" "2D5" "2E1" "2E2" "2H1" "3D1"
# [18] "3D2" "3D3" "3D4" "3D5" "3E1" "3E2" "3H1" "4D1" "4D2" "4D3" "4D4" "4D5" "4E1" "4E2" "4H1" "5D1" "5D2"
# [35] "5D3" "5D4" "5D5" "5E1" "5E2" "5H1" "6D1" "6D2" "6D3" "6D4" "6D5" "6E1" "6E2" "6H1"

DHWDAYUSEs['3D4']

# blank data.table
DT_DHWUSEs <- data.table()

# loop through all the DHWDAYUSEs
for (d in 1:length(DHWDAYUSEs)) {

  # make a 2 column data.table with DHWDAYUSE_names and DHWUSEs
  DT_temp <- data.table( DHWDAYUSE=names(DHWDAYUSEs[d]) ,DHWUSE=unlist(DHWDAYUSEs[d]) )

  # attach DT_temp to DT_DHWUSEs
  DT_DHWUSEs <- rbind(DT_DHWUSEs, DT_temp)
  
}
  
str(DT_DHWUSEs)
# Classes ‘data.table’ and 'data.frame':	3412 obs. of  2 variables:
#  $ DHWDAYUSE: chr  "1D1" "1D1" "1D1" "1D1" ...
#  $ DHWUSE   : chr  "DWSH(  1.30,  1.667, 1.145,   0)" "DWSH(  1.87,  1.500, 1.014,   0)" "DWSH(  2.10,  1.333, 1.179,   0)" "FAUC(  2.09,  0.167, 0.317,   0)" ...
#  - attr(*, ".internal.selfref")=<externalptr> 
  
# extract s,d,f,id from DHWUSE end use macros
DT_DHWUSEs[, s:= str_extract(DHWUSE, "\\( +[0-9]*\\.[0-9]*") ]
DT_DHWUSEs[, s:= str_extract(s, "[0-9]*\\.[0-9]*") ]
DT_DHWUSEs[, s:= as.numeric(s) ]  # start as fraction of day

DT_DHWUSEs[, d:= str_extract(DHWUSE, "\\, +[0-9]*\\.[0-9]{3}")]
DT_DHWUSEs[, d:= str_extract(d, "[0-9]*\\.[0-9]{3}")]
DT_DHWUSEs[, d:= as.numeric(d) ]  # duration as minutes

DT_DHWUSEs[, f:= str_extract(DHWUSE, ", *[0-9]{1}.[0-9]{3}, *[0-9]*\\)")]
DT_DHWUSEs[, f:= str_extract(f, "[0-9]*\\.[0-9]*")]
DT_DHWUSEs[, f:= as.numeric(f) ]

DT_DHWUSEs[, id:= str_extract(DHWUSE, "[0-9]*\\)")]
DT_DHWUSEs[, id:= str_extract(id, "[0-9]*")]
DT_DHWUSEs[, id:= as.numeric(id) ]  # id of event where multidraw dishwasher and clothes washer draws are counted as one id

str(DT_DHWUSEs)
# Classes ‘data.table’ and 'data.frame':	3412 obs. of  6 variables:
#   $ DHWDAYUSE: chr  "1D1" "1D1" "1D1" "1D1" ...
#   $ DHWUSE   : chr  "DWSH(  1.30,  1.667, 1.145,   0)" "DWSH(  1.87,  1.500, 1.014,   0)" "DWSH(  2.10,  1.333, 1.179,   0)" "FAUC(  2.09,  0.167, 0.317,   0)" ...
#   $ s        : num  1.3 1.87 2.1 2.09 6.75 6.76 6.77 7.02 7.22 7.23 ...
#   $ d        : num  1.667 1.5 1.333 0.167 0.167 ...
#   $ f        : num  1.145 1.014 1.179 0.317 0.226 ...
#   $ id       : num  0 0 0 0 1 2 3 4 5 6 ...
#   - attr(*, ".internal.selfref")=<externalptr> 

# from DHWDUSF.txt
ShwrFLOWF       = 1        
ShwrDRAINHREFF  = 0   
CwshHOTF        = 0.22      
CwshUSEF        = 1         
FaucHOTF        = 0.50      
BathFLOWF       = 1        
BathDRAINHREFF  = 0   
DwshFLOWF       = 1        
FaucFLOWF       = 1.0

# // define macros for each end use (with specific parameters exposed)
# #define SHWR( s, d, f, id)  \
# DHWUSE wuHWEndUse="Shower" wuStart=s wuDuration=d wuFlow=f*ShwrFLOWF wuTemp=105 wuHeatRecEF=ShwrDRAINHREFF wuEventID=id
# 
# #define CWSH( s, d, f, id) \
# DHWUSE wuHWEndUse="CWashr" wuStart=s wuDuration=d wuFlow=f*CwshUSEF wuHotF=CwshHOTF wuEventID=id
# 
# #define FAUC( s, d, f, id) \
# DHWUSE wuHWEndUse="Faucet" wuStart=s wuDuration=d wuFlow=f*FaucFLOWF wuHotF=FaucHOTF wuEventID=id
# 
# #define BATH( s, d, f, id) \
# DHWUSE wuHWEndUse="Bath" wuStart=s wuDuration=d wuFlow=f*BathFLOWF wuTemp=105 wuHeatRecEF=BathDRAINHREFF wuEventID=id
# 
# #define DWSH( s, d, f, id) \
# DHWUSE wuHWEndUse="DWashr" wuStart=s wuDuration=d wuFlow=f*DwshFLOWF wuEventID=id

# calculate the mixedFlows
# the draw flow rate at the point of use (in other words, the mixed-water flow rate).
# showers
DT_DHWUSEs[grepl('SHWR', DHWUSE), `:=` (mixedFlow = f * ShwrFLOWF,
                                        enduse    = "Shower"
                                        ) ]

# baths
DT_DHWUSEs[grepl('BATH', DHWUSE), `:=` (mixedFlow = f * BathFLOWF,
                                        enduse    = "Bath"
) ]

# calculate the hotFlows and coldFlows
# the hot draw flow rate at the point of use (in other words, the hot-water flow rate).
# and the cold draw flow rate at the point of use (in other words, the cold-water flow rate).
# faucets
DT_DHWUSEs[grepl('FAUC', DHWUSE), `:=` (mixedFlow = f * FaucFLOWF,
                                        hotFlow   = f * FaucFLOWF * FaucHOTF,
                                        coldFlow  = f * FaucFLOWF * (1-FaucHOTF),
                                        enduse    = "Faucet"
                                        ) ]

# clothes washer
DT_DHWUSEs[grepl('CWSH', DHWUSE), `:=` (mixedFlow = f * CwshUSEF,
                                        hotFlow   = f * CwshUSEF * CwshHOTF,
                                        coldFlow  = f * CwshUSEF * (1-CwshHOTF),
                                        enduse    = "ClothesWasher"
                                        ) ]

# dishwasher
DT_DHWUSEs[grepl('DWSH', DHWUSE), `:=` (mixedFlow = f * DwshFLOWF,
                                        hotFlow   = f * DwshFLOWF,
                                        coldFlow  = f * (1-DwshFLOWF),
                                        enduse    = "Dishwasher"
                                        ) ]


str(DT_DHWUSEs)
# Classes ‘data.table’ and 'data.frame':	3412 obs. of  10 variables:
#   $ DHWDAYUSE: chr  "1D1" "1D1" "1D1" "1D1" ...
#   $ DHWUSE   : chr  "DWSH(  1.30,  1.667, 1.145,   0)" "DWSH(  1.87,  1.500, 1.014,   0)" "DWSH(  2.10,  1.333, 1.179,   0)" "FAUC(  2.09,  0.167, 0.317,   0)" ...
#   $ s        : num  1.3 1.87 2.1 2.09 6.75 6.76 6.77 7.02 7.22 7.23 ...
#   $ d        : num  1.667 1.5 1.333 0.167 0.167 ...
#   $ f        : num  1.145 1.014 1.179 0.317 0.226 ...
#   $ id       : num  0 0 0 0 1 2 3 4 5 6 ...
#   $ mixedFlow: num  1.145 1.014 1.179 0.317 0.226 ...
#   $ enduse   : chr  "Dishwasher" "Dishwasher" "Dishwasher" "Faucet" ...
#   $ hotFlow  : num  1.145 1.014 1.179 0.159 0.113 ...
#   $ coldFlow : num  0 0 0 0.159 0.113 ...
#   - attr(*, ".internal.selfref")=<externalptr> 

# summary data about DT_DHWUSEs
DT_DHWUSEs_sum <-
  DT_DHWUSEs[ , list(vol    = sum(mixedFlow * d),
                     ndraws = length(DHWUSE)),
              by = DHWDAYUSE]

theme(plot.title = element_text(hjust = 0.5)) # to center the title

# scatter plot of volume vs number of draws per DHWDAYUSE
ggplot(data=DT_DHWUSEs_sum) +
  geom_point(aes(x=vol, y= ndraws) ) +
  ggtitle( "DHWDAYUSEs (daily draw pattern templates)" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title
  scale_x_continuous(name = "total mixed water drawn (gallons/day)") +
  scale_y_continuous(name = "total number of draws per day") +
  geom_text(data=DT_DHWUSEs_sum[DHWDAYUSE %in% 
                                  c('3D1', '3D2', '3D3', '3D4', '3D5')],
          aes(x=vol, y=ndraws, label=DHWDAYUSE, hjust=-0.2, size=1)
          ) + 
  guides(size=FALSE)

ggsave(filename = paste0("daily_draws_gallons.png"), path=wd_charts,
       width = 10.5, height = 8 )

# clean up DT_DHWUSEs
names(DT_DHWUSEs)
# [1] "DHWDAYUSE" "DHWUSE"    "s"         "d"         "f"         "id"        "mixedFlow" "enduse"   
# [9] "hotFlow"   "coldFlow" 

# remove DHWUSE & f
DT_DHWUSEs[ , DHWUSE:= NULL]
DT_DHWUSEs[ , f:= NULL]

# fix names
setnames(DT_DHWUSEs,
         old=c("d"),
         new=c("duration"))

# clean up the order
setcolorder(DT_DHWUSEs, 
            neworder= c('DHWDAYUSE', 'enduse', 'id', 's', 'duration', 'mixedFlow', 'hotFlow', 'coldFlow')
            )

# change start from fraction of a day to hh:mm:ss
DT_DHWUSEs[, hrs  := floor(s) ]
DT_DHWUSEs[, mins := (s - hrs) * 60 ]
DT_DHWUSEs[, secs := (mins - floor(mins)) * 60] 
DT_DHWUSEs[, mins := floor(mins)]

DT_DHWUSEs[, start := sprintf("%02d:%02d:%02.0f", hrs, mins, secs )]
DT_DHWUSEs[, c('hrs','mins','secs') := NULL]

# summary data about DT_DHWUSEs
DT_DHWUSEs_sum <-
  DT_DHWUSEs[ , list(vol    = sum(mixedFlow * duration),
                     ndraws = length(id)),
              by = DHWDAYUSE]

# scatter plot of volume vs number of draws per DHWDAYUSE
ggplot(data=DT_DHWUSEs_sum) +
  geom_point(aes(x=vol, y= ndraws) ) +
  ggtitle( "DHWDAYUSEs (daily draw pattern templates)" ) +
  theme(plot.title = element_text(hjust = 0.5)) + # to center the title
  scale_x_continuous(name = "total mixed water drawn (gallons/day)") +
  scale_y_continuous(name = "total number of draws per day") +
  geom_text(data=DT_DHWUSEs_sum[DHWDAYUSE %in% 
                                  c('3D1', '3D2', '3D3', '3D4', '3D5')],
            aes(x=vol, y=ndraws, label=DHWDAYUSE, hjust=-0.2, size=1)
  ) + 
  guides(size=FALSE)

# resort the  draws in DT_DHWUSES by time
setorder(DT_DHWUSEs, DHWDAYUSE, s)

# count of types of draws by DHWDAYUSE
tbl_DHWDAYUSE_enduse <- (with(DT_DHWUSEs, table(DHWDAYUSE,enduse)))

# Start writing to an output file
sink(paste0(wd_data,'DHWDAYUSE_enduse.txt'))

# print the table
print.table(tbl_DHWDAYUSE_enduse)

# reset sink
sink()

# save the DT_DHWUSEs data as a csv file 
write.csv(DT_DHWUSEs, file= paste0(wd_data,"DT_DHWUSEs.csv"), row.names = FALSE)

# save the DT_DHWUSEs data as an .Rdata file
save(DT_DHWUSEs, file = paste0(wd_data,"DT_DHWUSEs.Rdata"))

# save DHWDAYUSE=='3D2'
write.csv(DT_DHWUSEs[DHWDAYUSE=='3D2'], 
          file= paste0(wd_data,"DT_DHWUSEs_3D2.csv"), 
          row.names = FALSE)

DT_DHWUSEs[DHWDAYUSE=='3D1',]
DT_DHWUSEs[DHWDAYUSE=='3D2',]

