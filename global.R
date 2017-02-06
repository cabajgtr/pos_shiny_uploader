library(tidyverse)
library(rhandsontable)
source('R/helper_functions.R')
source("R/import_tools.R")
source("R/qry_tools.R")

db <- db_connect()

#load initial data
#customers <- sql_df(getSQL_invoices('2017-01-01','2017-02-01','SUPERIOR COMMUNICATION')) %>% as.data.table() #readRDS('sampledata.rds') %>% as.data
DistyResellerList <- getDistyResellerList()