
library(tidyverse)
library(RPostgreSQL)
source('R/helper_functions.R')
source("R/import_tools.R")

db <- db_connect()
sql_code <- "SELECT * FROM transaction.pos_transactions_weekly WHERE date_id = '2017-01-28' AND customer_code = 'IND00004'"
customers <- tbl(db, sql(sql_code)) %>% collect() %>% as.data.frame()
#v_account_manager <- RPostgreSQL::dbGetQuery(db$con,"SELECT reporting_name FROM transaction.kam")[,1]

library(shiny)


shinyServer(function(input, output) {
  
  output$contents <- renderRHandsontable({
    rhandsontable(customers, width = '100%') %>% 
      hot_col(col = "date_id", type = "date") #, source = v_account_manager)
  })
  
  table_chg <- eventReactive(input$go, {
    return(hot_to_r(input$contents))
  })
  
  output$customers_o <- renderTable({
    table_chg()
  })
  
})
