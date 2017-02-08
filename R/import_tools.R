#Import Helpers
require(readr)
#require(htmltab)
require(readxl)
require(stringr)
require(data.table)
require(dplyr)
require(lubridate)

##Import File
# Select the right tool for the job
read_any <- function(path, fname, arg_list) {
  #First assign appropriate function to read_fun
  #read_fun <- arg_list[['read_fun']]
  #Then call function with arguments from arg_list
  #Look into a way of calling once and getting underlying read function to ignore extra parameters
  
  if(fname == 'read_excel') {
    dtbl <- readxl::read_excel(path,
                               sheet = max(arg_list[['tab']],1),
                               col_names = ifelse(is.null(arg_list[['header']]), TRUE, arg_list[['header']]),
                               col_types = NULL,
                               skip = arg_list[['skip']]) }
  
  if(fname == 'read_csv') {
    dtbl <- readr::read_csv(file = path,
                            skip = arg_list[['skip']],
                            col_names = ifelse(is.null(arg_list[['header']]), TRUE, arg_list[['header']]),
                            col_types = NULL)} 
  
  if(fname == 'read_tsv') {
    dtbl <- readr::read_tsv(file = path,
                            skip = arg_list[['skip']],
                            col_names = ifelse(is.null(arg_list[['header']]), TRUE, arg_list[['header']]),
                            col_types = NULL)} 
  
  if(fname == 'HTML') {
    dtbl <- XML::readHTMLTable(file = path,
                               which = max(arg_list[['tab']],1),
                               skip.rows = arg_list[['skip']])
    #col_names = ifelse(is.null(arg_list[['header']]), TRUE, arg_list[['header']]),
    #col_types = NULL)
  } 
  
  if(fname == 'htmltab') {
    dtbl <- htmltab::htmltab(doc = path, 
                             which = arg_list[['tab']])}
  return(dtbl)
}

#TESTING
#file_specs <- list(read_fun = 'read_excel',
#                   tab = NULL,
#                   skip = 0
#)
#raw_data <- read_any('data/tblCAL.xlsx', "read_excel", file_specs)
#raw_data <- read_any('data/customer_list.csv', "read_csv", file_specs)
#raw_data <- read_any('data/superior.xls', "htmltab", file_specs)

##SKU lookup with database Caching
get_validation_tables <- function(){
  #Create df to load
  dfsku <- data.frame(NULL)
  dfreseller <- data.frame(NULL)
  
  #pull function actually runs the query
  pull.vsku <- function() {
    db <- db_connect() #ifelse(is.null(dbCon), db_connect(), dbCon)
    lookup <- RPostgreSQL::dbGetQuery(db$con, 'SELECT * FROM vendor_item_lookup')
    RPostgreSQL::dbDisconnect(db$con)
    return(lookup)
  }
  
  pull.vreseller <- function() {
    db <- db_connect() #ifelse(is.null(dbCon), db_connect(), dbCon)
    lookup <- RPostgreSQL::dbGetQuery(db$con, 'SELECT * FROM reseller_lookup')
    RPostgreSQL::dbDisconnect(db$con)
    return(lookup)
  }
  
  #Return the dataframe, pulling from database only if not already in local df
  vsku <- function() {
    if(length(dfsku) == 0) {
      dfsku <<- pull.vsku()
      print("pulling...")
    }
    return(dfsku)
  }
  vreseller <- function() {
    if(length(dfreseller) == 0) {
      dfreseller <<- pull.vreseller()
      print("pulling...")
    }
    return(dfreseller)
  }  
  forget <- function() {
    dfsku <<- NULL
    dfreseller <<- NULL
  }
  
  list(pull.vsku = pull.vsku,
       pull.vreseller = pull.vreseller,
       forget = forget,
       vsku = vsku,
       vreseller = vreseller)
}
vlookup <- get_validation_tables()

validate_sku <- function(sku_vector, valid_method) {
  new_sku <- as.tbl(data.frame(vsku = sku_vector)) %>% 
    mutate(PF = str_extract(vsku, "PF[0-9]{6}")) %>%
    left_join(vlookup$vsku(), by = c("vsku"="vendor_item")) %>% 
    #mutate(cleansku = ifelse(is.na(PF), sku, PF)) 
    mutate(cleansku = coalesce(PF, sku, vsku)) 
  return(new_sku$cleansku)
}

validate_customer_code <- function(reseller_vector, valid_method) {
  new_sku <- as.tbl(data.frame(vreseller = reseller_vector)) %>% 
    left_join(vlookup$vreseller(), by = c("vreseller"="reseller_name")) %>% 
    #mutate(cleansku = ifelse(is.na(PF), sku, PF)) 
    mutate(cleancustomer = coalesce(customer_code, vreseller)) 
  return(new_sku$cleancustomer)
}

CustomerList$df


upload_pos <- function(df, dest_table = NULL, dbCon = NULL, stage_only = F) {
  validated_data <- df %>% inner_join(CustomerList$df, by = c("customer_name" = "customer_name")) %>% 
    select(date_id, customer_code, store_number, sku, pos_units, pos_sales_retail, rtl_inventory, 
           pos_unit_returns, pos_sales_retail_returns, distributor_code, sellthru_flag, sellout_flag)
  
  db <- db_connect() #ifelse(is.null(dbCon), db_connect(), dbCon)
  #db <- db()
  dest_table = ifelse(is.null(dest_table), 'pos_detail_stage', dbCon)
  RPostgreSQL::dbGetQuery(db$con, paste0('TRUNCATE TABLE ', dest_table))
  copy_to(db, validated_data, paste0(dest_table,"_temp"), temporary = T)
  RPostgreSQL::dbGetQuery(db$con, 'INSERT INTO pos_detail_stage SELECT * FROM pos_detail_stage_temp;')
  
  #RPostgreSQL::dbWriteTable(db, dest_table, validated_data, overwrite = T, row.names = F)
  if(stage_only == F) RPostgreSQL::dbGetQuery(db$con, 'SELECT upsert_pos_detail();')
  RPostgreSQL::dbDisconnect(db$con)
}

store_num_char <- function(store_numeric){
  if(is.character(store_numeric)) {
    return(store_numeric) 
  }else{
    l <- min(4, nchar(store_numeric))
    return(paste0(c(rep("0",4-l), as.character(store_numeric)), collapse = ""))
  }
}
