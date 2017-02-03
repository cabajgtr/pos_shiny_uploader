
library(shiny)


shinyServer(function(input, output, session) {
  
  observeEvent(input$do, {
    session$sendCustomMessage(type = 'testmessage',
                              message = 'Thank you for clicking')
  })
  
  #table_chg <- eventReactive
  observeEvent(input$updateQry, {
    output$valDateRange <- renderPrint({ input$wDateRange })
    print("update triggered")
    customers <- sql_df(getSQL_invoices(input$wDateRange[1], input$wDateRange[2], input$wCustomer_Name)) %>% select(-distributor) %>% as.data.frame()
    #print(customers)
    output$contents <- renderRHandsontable({
      rhandsontable(customers, width = '100%') %>% 
        hot_col(col = "date_id", type = "date") %>%  #, source = v_account_manager) %>% 
        hot_col(col = "reseller", type = "dropdown", source = getValidResellerList(input$wCustomer_Name))
    })  
  })
  
    
  #output$contents <- renderRHandsontable({
  #  rhandsontable(customers, width = '100%') %>% 
  #    hot_col(col = "date_id", type = "date") %>%  #, source = v_account_manager) %>% 
  #    hot_col(col = "reseller", type = "dropdown", source = getValidResellerList(input$wCustomer_Name))
  #})
  
  #table_chg <- eventReactive(input$go, {
  #  return(hot_to_r(input$contents))
  #})
  
  ##output$customers_o <- renderTable({
  #  table_chg()
  #})
  
})
