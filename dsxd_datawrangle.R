library(RPostgreSQL)
library(tidyverse)
library(lubridate)
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



graph_df <- overall %>%
   mutate(year = year(start_date),
          f_pct = Female/enrollment,
          m_pct = Male/enrollment) %>%
   ungroup() %>%
   distinct(nct_id, .keep_all = TRUE) %>%
   group_by(year) %>%
   summarise(n_studies = n_distinct(nct_id),
             f_mean = mean(f_pct, na.rm = TRUE),
             f_med = median(f_pct, na.rm = TRUE),
             m_mean = mean(m_pct, na.rm = TRUE),
             m_med = median(m_pct, na.rm = TRUE))
graph_df %>%
   pivot_longer(cols = f_mean:m_med,
                names_to = c("gender", "measure"),
                names_pattern = "(.)_(.*)",
                values_to = "count") %>%
   filter(year > 2000, measure == "med") %>%
   ggplot(aes(x = year, y = n_studies*count, fill = gender)) +
   geom_bar(stat = "identity") +
   ylab("Number of studie\nMedian percentage of Females") +
   theme_bw()


graph_df %>%
   pivot_longer(cols = f_mean:m_med,
                names_to = c("gender", "measure"),
                names_pattern = "(.)_(.*)",
                values_to = "count") %>%
   filter(year > 2000, measure == "mean") %>%
   ggplot(aes(x = year, y = n_studies*count, fill = gender)) +
   geom_bar(stat = "identity") +
   ylab("Number of studie\nMean percentage of Females") +
   theme_bw()





graph_df <- overall %>%
   filter(study_type == "Interventional") %>%
   mutate(year = year(start_date),
          f_pct = Female/enrollment,
          m_pct = Male/enrollment) %>%
   ungroup() %>%
   distinct(nct_id, .keep_all = TRUE) %>%
   group_by(year) %>%
   summarise(n_studies = n_distinct(nct_id),
             f_mean = mean(f_pct, na.rm = TRUE),
             f_med = median(f_pct, na.rm = TRUE),
             m_mean = mean(m_pct, na.rm = TRUE),
             m_med = median(m_pct, na.rm = TRUE))
graph_df %>%
   pivot_longer(cols = f_mean:m_med,
                names_to = c("gender", "measure"),
                names_pattern = "(.)_(.*)",
                values_to = "count") %>%
   filter(year > 2000, measure == "med") %>%
   ggplot(aes(x = year, y = n_studies*count, fill = gender)) +
   geom_bar(stat = "identity", position = "dodge") +
   ylab("Number of studie\nMedian percentage of Females") +
   theme_bw()


graph_df %>%
   pivot_longer(cols = f_mean:m_med,
                names_to = c("gender", "measure"),
                names_pattern = "(.)_(.*)",
                values_to = "count") %>%
   filter(year > 2000, measure == "mean") %>%
   ggplot(aes(x = year, y = n_studies*count, fill = gender)) +
   geom_bar(stat = "identity", position = "dodge") +
   ylab("Number of studie\nMean percentage of Females") +
   theme_bw()
