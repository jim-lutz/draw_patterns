# PipeSize.R
# create a PipeSize missing variable
# for Tables 22 & 27, others don't matter
# Compact Wet Room Layouts, Small Pipe, Normal Flow &
# Compact Wet Room Layouts, Small Pipe, Low Flow
DT_relative[, PipeSize := ""] # blank character

# Tables 22 & 27
DT_relative[table=='22' | table=='27',
            list(Configuration=unique(Configuration))]


# " & 3/8 pipe & no 1 inch pipe" -> "Use 3/8 pipe & Not use 1 inch pipe"
DT_relative[str_detect(Configuration," & 3/8 pipe & no 1 inch pipe"),
            list(Configuration, PipeSize, table)]

# set PipeSize
DT_relative[str_detect(Configuration," & 3/8 pipe & no 1 inch pipe"),
            PipeSize := "Use 3/8 pipe & Not use 1 inch pipe"]

# clean up Configuration
DT_relative[str_detect(Configuration," & 3/8 pipe & no 1 inch pipe"),
            Configuration := str_remove(Configuration," & 3/8 pipe & no 1 inch pipe")]

# check that it worked
DT_relative[ PipeSize == "Use 3/8 pipe & Not use 1 inch pipe",
             list(Configuration, PipeSize, table)]


# " & no 1 inch pipe" -> "Not use 1 inch pipe"
DT_relative[str_detect(Configuration," & no 1 inch pipe"),
            list(Configuration, PipeSize, table)]

# set PipeSize
DT_relative[str_detect(Configuration," & no 1 inch pipe"),
            PipeSize := "Not use 1 inch pipe"]

# clean up Configuration
DT_relative[str_detect(Configuration," & no 1 inch pipe"),
            Configuration := str_remove(Configuration," & no 1 inch pipe")]


# " & 3/8 pipe" -> "Use 3/8 pipe"
DT_relative[str_detect(Configuration," & 3/8 pipe"),
            list(Configuration, PipeSize, table)]

# set PipeSize
DT_relative[str_detect(Configuration," & 3/8 pipe"),
            PipeSize := "Use 3/8 pipe"]

# clean up Configuration
DT_relative[str_detect(Configuration," & 3/8 pipe"),
            Configuration := str_remove(Configuration," & 3/8 pipe")]

# check that it worked
DT_relative[table=='22' | table=='27',
            list(Configuration=unique(Configuration))]
