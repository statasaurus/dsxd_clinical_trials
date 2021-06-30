library(RPostgreSQL)
library(tidyverse)
#Loading required package: DBI
drv <- dbDriver('PostgreSQL')

# Connect to the government database
con <- dbConnect(drv, dbname="aact",host="aact-db.ctti-clinicaltrials.org",
                 port=5432, user=Sys.getenv("aact_user"),
                 password=Sys.getenv("aact_pswrd"))

# We potentially need a wider search criteria but I think this is fine for now
gender_tbl <- dbGetQuery(con, "SELECT *
           FROM baseline_measurements
           WHERE category IN ('Male', 'Female')
                         and classification IN ('', 'Main')") %>%
   select(-id) %>%
   distinct()

wide_g_tbl <- gender_tbl %>%
   group_by(nct_id, category) %>%
   arrange(desc(param_value_num)) %>%
   #this is to just take the max which will usually be the total although some
   #times might be only part of the study but I think that is fine for what we
   #are doing
   slice(1) %>%
   select(nct_id, category, param_value_num) %>%
    pivot_wider(names_from = category, values_from = param_value_num)

study_tbl <- dbGetQuery(con, "SELECT std.nct_id, std.study_type, std.enrollment,
               std.overall_status, std.start_date, conds.name as condition, spons.name as sponsor
           FROM ((studies std
           LEFT JOIN conditions conds
            ON std.nct_id = conds.nct_id)
           LEFT JOIN sponsors spons
            ON std.nct_id = spons.nct_id)
                        WHERE study_type = 'Interventional'")


overall <- wide_g_tbl %>%
   inner_join(study_tbl, by = "nct_id")
