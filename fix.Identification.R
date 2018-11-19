# fix.Identification.R
# set PipeSize and blank Identification in tables 20 & 25

# Now look at Identification
DT_relative[,list(Identification=unique(Identification),
                  n = length(Configuration)), 
            by = table] [order(table)]

# what's with table 20 & 25
DT_relative[ table == '20' | table == '25',
             list(Configuration, Identification, PipeSize, table)]


# "use 3/8 pipe & Not use 1 inch pipe" -> ""
DT_relative[str_detect(Identification, "use 3/8 pipe & Not use 1 inch pipe"),
            list(Configuration, Identification, PipeSize, table)]

# set PipeSize
DT_relative[str_detect(Identification, "use 3/8 pipe & Not use 1 inch pipe"),
            PipeSize := "Use 3/8 pipe & Not use 1 inch pipe"]

# blank out Identification
DT_relative[str_detect(Identification, "use 3/8 pipe & Not use 1 inch pipe"),
            Identification := ""]


# "Not use 1 inch pipe" -> ""
DT_relative[str_detect(Identification, "Not use 1 inch pipe"),
            list(Configuration, Identification, PipeSize, table)]

# set PipeSize
DT_relative[str_detect(Identification, "Not use 1 inch pipe"),
            PipeSize := "Not use 1 inch pipe"]

# blank out Identification
DT_relative[str_detect(Identification, "Not use 1 inch pipe"),
            Identification := ""]


# "use 3/8 pipe" -> "Use 3/8 pipe"
DT_relative[str_detect(Identification, "use 3/8 pipe"),
            list(Configuration, Identification, PipeSize, table)]

# set PipeSize
DT_relative[str_detect(Identification, "use 3/8 pipe"),
            PipeSize := "Use 3/8 pipe"]

# blank out Identification
DT_relative[str_detect(Identification, "use 3/8 pipe"),
            Identification := ""]

# check it again
DT_relative[ table == '20' | table == '25',
             list(Configuration, Identification, PipeSize, table)]

