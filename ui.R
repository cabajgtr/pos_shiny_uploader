library(shinythemes)
library(shinyjs)
library(lubridate)

ui_tab2 <- tabPanel("SKU Lookups", 
                    fluidRow(
                      h1("Missing Product Mapping"),
                      actionButton("refresh_sku_lookup", "Find Missing")
                    ),
                    
                    fluidRow(
                      rHandsontableOutput('hot_skulookup', width = '100%'),
                      actionButton("upload_sku_lookup", "Upload Mapping")
                    )
)


shinyUI(fluidPage(theme = shinytheme("yeti"), useShinyjs(), navbarPage("POS Uploader",
        tabPanel("Distributor to Resellers", 
                                      fluidRow(
                                        div(style="display:inline-block; vertical-align: middle ",selectizeInput("wCustomer_Name", label = 'Distributor',choices = DistyResellerList[['distributor']])),
                                        div(style="display:inline-block; vertical-align: middle",
                                            dateRangeInput("wDateRange", 
                                              label = "Date range", #, 
                                              start = ymd(last_week_ending()) - 6, 
                                              end = ymd(last_week_ending()))),
                                        div(style="display:inline-block; vertical-align: middle",actionButton("updateQry", "Refresh"))
                                      ),
                                      
                                      fluidRow(
                                        rHandsontableOutput('contents', width = '100%'),
                                        actionButton("uploadRecode", "Update")
                                      )
                             ),
                             ui_tab2
))
)
