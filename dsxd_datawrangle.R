library(RPostgreSQL)
library(tidyverse)
#Loading required package: DBI
drv <- dbDriver('PostgreSQL')

con <- dbConnect(drv, dbname="aact",host="aact-db.ctti-clinicaltrials.org",
                 port=5432, user=Sys.getenv("aact_user"),
                 password=Sys.getenv("aact_pswrd"))

tbls <- dbListTables(con)

gender_tbl <- dbGetQuery(con, "SELECT *
           FROM baseline_measurements
           WHERE category IN ('Male', 'Female')")

# spon_tbl <- dbGetQuery(con, "SELECT nct_id, name as sponsors
#            FROM sponsors")
# study_tbl <- dbGetQuery(con, "SELECT nct_id, study_type, enrollment,  overall_status
#            FROM studies
#                         WHERE study_type = 'Interventional'")
#
# ta_tbl <- dbGetQuery(con, "SELECT nct_id, name as conditions
#            FROM conditions")

study_tbl <- dbGetQuery(con, "SELECT std.nct_id, std.study_type, std.enrollment,
               std.overall_status, conds.name as condition, spons.name as sponsor
           FROM ((studies std
           LEFT JOIN conditions conds
            ON std.nct_id = conds.nct_id)
           LEFT JOIN sponsors spons
            ON std.nct_id = spons.nct_id)
                        WHERE study_type = 'Interventional'")


