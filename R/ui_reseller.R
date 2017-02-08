ui_reseller <- tabPanel("Distributor to Resellers", fluidRow(
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
))
