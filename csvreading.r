#################################
### CSV-lukija Markkinaseurantadatalle
### Author: Tommi Salenius
### License: GPL (2018)
#################################



luecsv <- function(file) {
  
  #' Tämän funktion tarkoituksena on ladata haluttu csv-tiedosto käyttäjän määrittelemältä
  #' polulta ja muutttaa date-muuttuja automaattisesti pvm-muotoon. Tämä funktio on siitä ankara,
  #' että se vaatii tarkan taulukkomuodon.
  
  df <- tryCatch(
    expr = read.table(file,header=TRUE,sep=","),
    error = function(e) {
      
      stop("I couldn't find the requested file. Check with 'getwd()' that you have the right
           working directory at the moment, or if you have written the filename correctly.")
      
    }
  )
  df$date <- tryCatch(
    expr = as.Date(df$date),
    error = function(e) {
      
      stop("The csv-file should be a table with column names 'date', 'field', 'value' 
           and 'ticker', and it seems the file you are trying to upload doesn't have the variable
           'date' in it. Please make sure you have a proper file format, and if you do then check
           if it's corrupted. If you only need to change a column name, DO NOT USE EXCEL, but Text
           editor instead.")
      
    }
      )
  return(df)
  
}

filtering <- function(df,metadf) {
  
  #' Filtteröi dataframesta pois kaikki ne muuttujat, joita ei ole metadata-tiedostosta
  #' ladatussa taulukossa mukana.
  #' 
  
  df$field <- as.factor(df$field)
  df$ticker <- as.factor(df$ticker)
  
  df <- subset(df, (field %in% metadf$field) & (ticker %in% metadf$ticker))
  
  return(df)
  
}
