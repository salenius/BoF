#' Tämän funktion tarkoitus on ladata metadata.xlsx-tiedostosta tarvittavat parametrit ja rakentaa
#' niiden pohjalta kuva.
#'
#' Vaadittava paketti on xlsx
#' 

lue.metadata <- function(sheet) {

df1 <- xlsx::read.xlsx("metadata.xlsx",sheetName=sheet) 

return(df1)

}



muuttujat <- new.env(parent=globalenv())
muuttujat$a <- 3

