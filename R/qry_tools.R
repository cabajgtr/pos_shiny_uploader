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