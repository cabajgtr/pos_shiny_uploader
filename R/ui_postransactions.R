
ui_POStransactions <- tabPanel("POS Transactions", 
            fluidRow(
               div(style="display:inline-block; vertical-align: middle ",selectizeInput("wposCustomer_Name", label = 'Customer',choices = CustomerList[['customer_name']])),
               div(style="display:inline-block; vertical-align: middle",
               dateRangeInput("wposDateRange", 
                  label = "Date range", #, 
                  start = ymd(last_week_ending()) - 6, 
                  end = ymd(last_week_ending()))),
               div(style="display:inline-block; vertical-align: middle",actionButton("pos_updateQry", "Refresh"))
            ),
            fluidRow(
               rHandsontableOutput('pos_contents', width = '100%'),
               actionButton("updatePOS", "Update POS")
            ))