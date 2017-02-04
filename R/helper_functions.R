#############################################################
### Helper Functions for ETL
#############################################################


######
######  Database Connection and Query

#Open Connection to AWS Server
require(RPostgres)

db_connect <- function() {
  src_postgres(dbname = 'parrotdb', host = 'parrot-pg.c36tfcszakuq.us-west-2.rds.amazonaws.com', port = '5432',  
               user = "ben", password = "sm00chm3", 
               options="-c search_path=etl")
}

dbods_connect <- function() {
  src_postgres(dbname = 'parrotdb', host = 'parrot-pg.c36tfcszakuq.us-west-2.rds.amazonaws.com', port = '5432',  
               user = "ben", password = "sm00chm3", 
               options="-c search_path=etl")
}


db_drop_table <- function(tbl_name) {
  RPostgreSQL::dbGetQuery(db$con, paste0('DROP TABLE IF EXISTS ', tbl_name))
}



#copy_to(db, dt,'target_pos_weekly_stage', temporary = F)
#RPostgreSQL::dbGetQuery(db$con, 'SELECT upsert_tgt_pos_stage_weekly()')


#########
######### File and Path Manipulation
#########

data_root <- 'data/'

last_week_ending <- function(week_adjustment = 0L) {
  format(lubridate::today() - (7 * week_adjustment) - lubridate::wday(lubridate::today()), "%Y%m%d")
}

cur_filepath <- function(filename, week_adjustment = 0L) {
  paste0(data_root,last_week_ending(week_adjustment),"/",filename)
} 

##Helper Functions for Data Formatting

##Strips non-alphanumberic characters and replaced SPACE with underscore
names_clean <- function(df) {
  return(tolower(gsub(" ","_",gsub("[^[:alnum:]///' ]", "", names(df)))))
}

clean_text <- function(df) {
  return(tolower(gsub(" ","_",gsub("[^[:alnum:]///' ]", "", df))))
}


strip_acctg <- function(x) {
  as.numeric(gsub(",","",gsub("[)$]", "", gsub("[(]", "-", x)),fixed=TRUE))
  
}

strip_int <- function(x) {
  as.integer(gsub(",","",gsub(")", "", gsub("(", "-", x, fixed=TRUE), fixed=TRUE),fixed=TRUE))
  
}

date_to_week_end <- function(date_day) {
  this_date <- ymd(date_day)
  ymd(format(this_date + (7 - wday(this_date)), "%Y-%m-%d"))
}

cpb = function(x,sep="\t",col.names=T,...) { 
  write.table(x
              ,file = pipe("pbcopy")
              ,sep=sep
              ,col.names = col.names
              ,row.names = F
              ,quote = F,...)
}