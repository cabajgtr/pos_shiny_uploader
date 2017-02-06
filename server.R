library(shinyjs)
library(shiny)

tbl_ship_disty <- as.data.frame(NULL) #sql_df(getSQL_invoices('2017-01-01', '2017-01-01', 'SUPERIOR COMMUNICATION')) %>% select(-distributor) %>% as.data.frame()
tbl_check_missing_sku <- as.data.frame(NULL) #data.frame(matrix(nrow = 0, ncol = 7))

shinyServer(function(input, output, session) {
  
  shinyjs::hide("upload_sku_lookup")
  
  #table_chg <- eventReactive
  observeEvent(input$updateQry, {
    #shinyjs::hide("contents") # Hide HOtable in case of zero record return
    #output$valDateRange <- renderPrint({ input$wDateRange })
    tbl_ship_disty <<- getInvoices(input$wDateRange[1], input$wDateRange[2], input$wCustomer_Name)
    
    showNotification(paste("returned ", nrow(tbl_ship_disty)," records")) #notify results summary
    
    #req(nrow(tbl_ship_disty) > 0)
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
    showNotification(paste("results:", rtn)) #notify results summary
  })

  #########################
  ##sku map
  ##Retrieve invalid skus
  observeEvent(input$refresh_sku_lookup, {
    #output$valDateRange <- renderPrint({ input$wDateRange })
    withProgress(message = 'Querying Database', {
      tbl_check_missing_sku <<- getInvalidSkus()})
    output$hot_skulookup <- renderRHandsontable({
      rhandsontable(tbl_check_missing_sku, width = '100%', readOnly = FALSE) %>% 
        hot_col(col = "sku_map_to", type = "text") #
    })  
    shinyjs::show("upload_sku_lookup")
  })

  ##sku map
  ##Upload sku map changes
  observeEvent(input$upload_sku_lookup, {
    tbl_check_missing_sku_clean <- tbl_check_missing_sku %>% 
        filter(!is.na(sku_as_imported), !is.na(sku_map_to), sku_map_to != 'NA')
    sku_changes <- hot_to_r(input$hot_skulookup) %>% #Get Current Values of Table
      anti_join(tbl_check_missing_sku_clean) %>% #Compare against last refresh, and return changed rows
      select(sku_as_imported, sku_map_to) %>%  #only need Doc number (key) and Reseller (value)
      distinct() %>% 
      filter(!is.na(sku_as_imported), !is.na(sku_map_to), sku_map_to != 'NA', sku_as_imported != '', sku_map_to != '')

    print(sku_changes)
    rtn <- sku_changes %>% upload_sku_lookup()
    showNotification(paste("results:", rtn)) #notify results summary
  })
  
  
})
