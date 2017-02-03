

ui_tab2 <- tabPanel("Distributor to Reseller",
                    fluidRow(
                      h1("Assign Reseller to Distributor Sales Doc")
                    ),
                    
                    fluidRow(
                      actionButton("do", "Click Me"),
                      p("tbd")
                      
                    )
)


shinyUI(fluidPage(navbarPage("POS Uploader",
        tabPanel("POS Transactions",
                                      fluidRow(
                                        column(2, selectizeInput("wCustomer_Name", label = 'Distributor',choices = DistyResellerList[['distributor']])),
                                        column(4, dateRangeInput("wDateRange", label = "Date range")),
                                        textOutput('valDateRange')
                                      ),
                                      
                                      fluidRow(
                                        
                                        rHandsontableOutput('contents', width = '100%'),
                                        actionButton("updateQry", "ReRun")
                                      )
                             ),
                             ui_tab2
))
)
