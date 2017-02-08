print("ui.R")

library(shinythemes)
library(shinyjs)
library(lubridate)

##Actual Pages are in their own files to make editing cleaner
source('R/ui_reseller.R')
source('R/ui_skulookup.R')
source('R/ui_postransactions.R')


shinyUI(fluidPage(theme = shinytheme("yeti"), useShinyjs(), navbarPage("POS Uploader",
                             ui_reseller,
                             ui_SKULookup,
                             ui_POStransactions
))
) #close shinyUI
