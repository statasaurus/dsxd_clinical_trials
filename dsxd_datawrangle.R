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

spon_tbl <- dbGetQuery(con, "SELECT nct_id, name
           FROM sponsors")
sutdy_tbl <- dbGetQuery(con, "SELECT nct_id, study_type, enrollment,  overall_status
           FROM studies")

ta_tbl <- dbGetQuery(con, "SELECT nct_id, name
           FROM conditions")

