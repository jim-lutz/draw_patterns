# fix.Configuration.R
# make Configuration consistent 
# with tables in draft final repor v10

# Trunk & 3 Branches
# Hybrid Mini-Manifold
# Central Manifold
# Two Heaters
# One-zone w/o Recirc

# here's what start with
DT_relative[,list(Configuration=unique(Configuration))]

# "Trunk & 3 Branches"
DT_relative[ str_detect(Configuration,"Branch"),
             list(Configuration, Identification, table)][order(table)]
# also shows up in all tables

# fix it
DT_relative[str_detect(Configuration,"Branch"),
            Configuration := "Trunk & 3 Branches"]


# "Hybrid Mini-Manifold"
DT_relative[ str_detect(Configuration,"manifold"),
             list(Configuration, Identification, table)]
# also shows up in all tables

# fix it
DT_relative[ str_detect(Configuration,"manifold"),
             Configuration := "Hybrid Mini-Manifold"]


# "Central Manifold"
DT_relative[ str_detect(Configuration,"Home Run"),
             list(Configuration, Identification, table)]
# also shows up in all tables

# fix it
DT_relative[ str_detect(Configuration,"Home Run"),
             Configuration := "Central Manifold"]


# "One-zone w/o Recirc"
DT_relative[ str_detect(Configuration,"zone"),
             list(Configuration, Identification, table)]
# also shows up in all tables

# fix it
DT_relative[ str_detect(Configuration,"zone"),
             Configuration := "One-zone w/o Recirc"]


# here's what it looks like after fixing
DT_relative[,list(Configuration=unique(Configuration))]

