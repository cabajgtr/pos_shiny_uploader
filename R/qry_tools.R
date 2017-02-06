

sql_df <- function(sql_code) {
  return(tbl(db, sql(sql_code)))
}

getInvoices <- function(datefrom, dateto, customer) {
  sql_code <- paste0("SELECT * FROM public.shipment_disributor_reseller WHERE date_id BETWEEN '",datefrom,"' AND '",dateto, "' AND distributor = '", customer,"'")
  print(sql_code)
  out <- sql_df(sql_code) %>% select(-distributor) %>% as.data.frame()
  if(nrow(out) == 0){
    out <- data.frame(reseller = NA, date_id = NA, 
                      document_number = NA, nature = NA, 
                      sku = NA, description = NA,
                      ship_units = NA, ship_sales = NA)
  }
  return(out)
}

getDistyResellerList <- function() {
  df <- sql_df("SELECT * from public.distributor_reseller_list") %>% collect
  reseller <- df %>% .[["reseller"]] %>% unique() %>% sort()
  distributor <- df %>% .[["distributor"]] %>% unique() %>% sort()
  list(df = df, reseller = reseller, distributor = distributor)
  }

getValidResellerList <- function(disty){
  rl <- DistyResellerList$df %>% filter(distributor == disty) %>% .[["reseller"]] %>% sort()
  return(c(disty,rl))
}

upload_shipment_reassign <- function(tbl_docnums) {
  x <- DBI::dbGetQuery(db$con, "TRUNCATE TABLE transaction.shipment_reseller_assign_stage")
  x <- dbWriteTable(db$con, c("transaction","shipment_reseller_assign_stage"), tbl_docnums, row.names=FALSE, append=TRUE)
  return(DBI::dbGetQuery(db$con, "SELECT transaction.upsert_shipment_reseller_assign();"))
}

upload_sku_lookup <- function(tbl_sku) {
  x <- DBI::dbGetQuery(db$con, "TRUNCATE TABLE etl.vendor_item_lookup_stage")
  x <- dbWriteTable(db$con, c("etl","vendor_item_lookup_stage"), tbl_sku, row.names=FALSE, append=TRUE)
  return(DBI::dbGetQuery(db$con, "SELECT etl.upsert_vendor_item();"))
}

getInvalidSkus <- function() {
  tbl_check_missing_sku <- sql_df("SELECT * FROM etl.check_missing_sku")
  out <- tbl_check_missing_sku %>% 
    select(sku_as_imported, sku_map_to, customer_name) %>% 
    group_by(sku_as_imported, sku_map_to) %>% 
    summarise(customers = paste(customer_name, collapse=", ")) %>% 
    collect() %>% #Filter doesn't work with NULL values in POSTGRES
    filter(!(sku_map_to %in% 'IGNORE')) %>% #Perform on offline tbl_df
    as.data.frame # rhandsontable doesn't like tbl_df
  if(nrow(out) == 0){
    out <- data.frame(sku_as_imported = NA, sku_map_to = NA, customers = NA)
  }
  return(out)
}
