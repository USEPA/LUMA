##################################################################################
##### Original code to create Peaklist_Pos for LUMA from lcmsfishdata table ######
##################################################################################

library(RSQLite)
library(LUMA)
library(dplyr)

if(!file.exists("data-raw/Peaklist_Pos.SQLite")) {
  download.file(
    "https://raw.githubusercontent.com/jmosl01/luma/master/data-raw/Peaklist_Pos.SQLite",
    "data-raw/Peaklist_Pos.SQLite"
  )
}


#Fresh start
rm(list = ls())

#code to execute
#Make database connection
old.peak.db <- connect_peakdb(file.base = "Peaklist_Pos_old", db.dir = "data-raw")
peak.db <- connect_peakdb(file.base = "Peaklist_Pos", db.dir = "data-raw")

tables <- c("Annotated","Combined Isotopes and Adducts","From CAMERA",
            "From CAMERA_with MinFrac","input_parsed","output_parsed",
            "Trimmed by CV","Trimmed by MinFrac","Trimmed by RT")

precombined_tables <- tables[c(1,3:6,9)]
combined_tables <- tables[c(2,7:8)]

#Code to QA for loop
i = 2
test <- read_tbl(mytable = precombined_tables[i], peak.db = old.peak.db)
assign(paste0(gsub(" ", "_",precombined_tables[i])), test, envir = as.environment(-1))

#List of EICs that can be trimmed by void volume
EIC_ID_rt <- test %>%
                filter(rt < 0.5) %>%
                  select(EIC_ID) %>%
                    slice(1:10)


EIC_list <- c(482,502,518,531,3070,3093,3110,3127,3333,3345,3435,5321,5325)
EIC_list <- unique(sort(c(EIC_list, as.numeric(EIC_ID_rt$EIC_ID))))

new_test <- LUMA:::.trim_table_by_eic(test, eic = EIC_list)
assign(paste0(gsub(" ","_",precombined_tables[i]),"_test"), new_test, envir = as.environment(-1))

write_tbl(mydf = new_test, peak.db = peak.db, myname = precombined_tables[i])

test_from_db <- read_tbl(mytable = precombined_tables[2], peak.db = peak.db)
identical(new_test,test_from_db)

#For loop
for (i in seq_along(precombined_tables)) {
  x <- read_tbl(mytable = precombined_tables[i], peak.db = old.peak.db)
  assign(paste0(gsub(" ", "_",precombined_tables[i])), x, envir = as.environment(-1))
  new_x <- LUMA:::.trim_table_by_eic(x,
                              eic = EIC_list)
  assign(paste0(gsub(" " , "_", precombined_tables[i])), new_x, envir = as.environment(-1))

  #write to database
  write_tbl(mydf = new_x, peak.db = peak.db, myname = precombined_tables[i])
}



#Code to QA second for loop
i = 1
test <- read_tbl(mytable = combined_tables[i], peak.db = old.peak.db)
assign(paste0(gsub(" ", "_",combined_tables[i])), test, envir = as.environment(-1))


#List of metgroups that can be trimmed by MinFrac
metgroup_mf <- test %>%
  filter(MinFrac < 0.8) %>%
  select(metabolite_group) %>%
  slice(1:10)


met_list <- c(230,898)
met_list <- unique(sort(c(met_list, as.numeric(metgroup_mf$metabolite_group))))

new_test <- LUMA:::.trim_table_by_metgroup(test, met = met_list)
assign(paste0(gsub( " ", "_" , combined_tables[i]),"_test"), new_test, envir = as.environment(-1))

write_tbl(mydf = new_test, peak.db = peak.db, myname = combined_tables[i])

test_from_db <- read_tbl(mytable = combined_tables[1], peak.db = peak.db)
identical(new_test,test_from_db)

#Second For loop
for (i in seq_along(combined_tables)) {
  x <- read_tbl(mytable = combined_tables[i], peak.db = old.peak.db)
  assign(paste0(gsub(" ", "_",combined_tables[i])), x, envir = as.environment(-1))
  new_x <- LUMA:::.trim_table_by_metgroup(x, met = met_list)
  assign(paste0(gsub( " " , "_" , combined_tables[i])), new_x, envir = as.environment(-1))

  #write to database
  write_tbl(mydf = new_x, peak.db = peak.db, myname = combined_tables[i])
}

#Close database connection
DBI::dbDisconnect(old.peak.db)
DBI::dbDisconnect(peak.db)

#Clean up example objects
list <- ls()
test_list <- list[grep("test",list)]
x_list <- list[grep("x",list)]
rm(list = c(test_list,x_list))

#remove old database
if (file.exists("./data-raw/Peaklist_Pos_old.SQLite")) file.remove("./data-raw/Peaklist_Pos_old.SQLite")

#Copy database to inst directory
file.copy(from = "./data-raw/Peaklist_Pos.SQLite", to = "./inst/extdata/Peaklist_Pos.SQLite", overwrite = T)

## END


########################################################
######## Code to generate Rdata for Peaklist Pos #######
########################################################

peak_db <- connect_peakdb(file.base = "Peaklist_Pos",
                          db.dir = "data-raw")

mynames <- RSQLite::dbListTables(peak_db)
mynames <- mynames[-grep("sqlite",mynames)]


Peaklist_Pos <- lapply(mynames, function(x) read_tbl(x, peak.db = peak_db))
temp <- gsub(" ", "_", mynames)
names(Peaklist_Pos) <- temp
test <- sapply(Peaklist_Pos, dim)
class(test)
test2 <- matrix(data = as.integer(c(13,131,12,141,23,120,23,121,3,142,2,142,13,121,13,138,13,139)), nrow = 2, ncol = 9,
                dimnames = list(NULL,c("Annotated","Combined_Isotopes_and_Adducts","From_CAMERA","From_CAMERA_with_MinFrac",
                                       "Trimmed_by_CV","Trimmed_by_MinFrac","Trimmed_by_RT","input_parsed",
                                       "output_parsed")))
if(identical(test,test2)) { #Ensures no changes to saved data if not matching documented data

  usethis::use_data(Peaklist_Pos, compress = "xz", overwrite = T)

}

dbDisconnect(peak_db)
### END
