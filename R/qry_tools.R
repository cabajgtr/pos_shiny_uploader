getSQL_invoices <- function(datefrom, dateto, customer) {
  sql_code <- paste0("SELECT * FROM public.shipment_disributor_reseller WHERE date_id BETWEEN '",datefrom,"' AND '",dateto, "' AND distributor = '", customer,"'")
  return(sql_code)
}

sql_df <- function(sql_code) {
  return(tbl(db, sql(sql_code)))
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


