
ui_SKULookup <- tabPanel("SKU Lookups", 
                    fluidRow(
                      h1("Missing Product Mapping"),
                      actionButton("refresh_sku_lookup", "Find Missing")
                    ),
                    
                    fluidRow(
                      rHandsontableOutput('hot_skulookup', width = '100%'),
                      actionButton("upload_sku_lookup", "Upload Mapping")
                    )
)