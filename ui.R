library(rhandsontable)
shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      #actionButton("go", "Update")
    ),
    
    mainPanel(
      rHandsontableOutput('contents', width = '100%'),
      actionButton("go", "Update"),
      p("For Reference Only"),
      tableOutput("customers_o")
    )
  )
  ))
