
library(shiny)
tbl_ship_disty <- sql_df(getSQL_invoices('2017-01-01', '2017-01-01', 'SUPERIOR COMMUNICATION')) %>% select(-distributor) %>% as.data.frame()

shinyServer(function(input, output, session) {
  
  observeEvent(input$do, {
    session$sendCustomMessage(type = 'testmessage',
                              message = 'Thank you for clicking')
  })
  
  #table_chg <- eventReactive
  observeEvent(input$updateQry, {
    output$valDateRange <- renderPrint({ input$wDateRange })
    print("update triggered")
    tbl_ship_disty <<- sql_df(getSQL_invoices(input$wDateRange[1], input$wDateRange[2], input$wCustomer_Name)) %>% select(-distributor) %>% as.data.frame()
    #print(customers)
    output$contents <- renderRHandsontable({
      rhandsontable(tbl_ship_disty, width = '100%', readOnly = TRUE) %>% 
        hot_col(col = "date_id", type = "date") %>%  #, source = v_account_manager) %>% 
        hot_col(col = "reseller", type = "dropdown", source = getValidResellerList(input$wCustomer_Name), readOnly = FALSE)
    })  
  })
  
  
  observeEvent(input$uploadRecode, {
    recode_changes <- hot_to_r(input$contents) %>%  #Get Current Values of Table
        anti_join(tbl_ship_disty) %>% #Compare against last refresh, and return changed rows
        select(document_number, reseller) %>%  #only need Doc number (key) and Reseller (value)
        distinct()
    
    rtn <- recode_changes %>% upload_shipment_reassign()
    print(paste("results:", rtn))
  })

  
})
