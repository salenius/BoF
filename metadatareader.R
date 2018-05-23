#!usr/bin/env Rscript
####################
### Author: Tommi Salenius
### Email: tommi.salenius@bof.fi
### Created: Pe 18 05 18
### License: General Public License (2018)
###################

#' Tämän funktion tarkoitus on ladata metadata.xlsx-tiedostosta tarvittavat parametrit ja rakentaa
#' niiden pohjalta kuva.
#'
#' Vaadittava paketti on xlsx
#' 

lue.metadata <- function(sheet) {

		df1 <- xlsx::read.xlsx("metadata.xlsx",sheetName=sheet) 

		return(df1)

}



