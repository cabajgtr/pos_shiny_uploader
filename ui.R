

ui_tab2 <- tabPanel("tbd",
                    fluidRow(
                      h1("Assign Reseller to Distributor Sales Doc")
                    ),
                    
                    fluidRow(
                      actionButton("do", "Click Me"),
                      p("tbd")
                      
                    )
)


shinyUI(fluidPage(navbarPage("POS Uploader",
        tabPanel("Distributor to Resellers",
                                      fluidRow(
                                        column(3, selectizeInput("wCustomer_Name", label = 'Distributor',choices = DistyResellerList[['distributor']])),
                                        column(4, dateRangeInput("wDateRange", label = "Date range")),
                                        actionButton("updateQry", "Refresh")
                                      ),
                                      
                                      fluidRow(
                                        rHandsontableOutput('contents', width = '100%'),
                                        actionButton("uploadRecode", "Update")
                                      )
                             ),
                             ui_tab2
))
)
