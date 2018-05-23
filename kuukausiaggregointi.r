#!usr/bin/env Rscript
####################
### Author: Tommi Salenius
### Email: tommi.salenius@bof.fi
### Created: Ke 23 05 18
### License: General Public License (2018)
###################

# Tämän skriptin tarkoituksena on tehdä helpoksi päivädatan saattaminen kuukausidatamuotoon.
# Skripti laskee aikasarjalle kuukausittaisen keskiarvon, varianssin ja mahdollisesti myös vinouden.
# Ajamalla funktion läpi se tallentaa päivädatasta uuden version Aggregaatit-kansioon, missä
# tiedostojen nimet ovat mean_alkuperäinen_nimi.csv ja stdev_alkuperäinen_nimi.csv. Voit
# halutessasi käyttää näitä tiedostoja dashboardin piirtämiseen siinä missä muitakin csv-tiedostoja.

#### Lue csv-tiedosto ####

aggregoi <- function(file){
  
  df1 <- read.csv(file,sep=",")
  
  df1$month <- strftime(df1$date, format="%m")
  df1$year <- strftime(df1$date, format="%Y")
  
  keskiarvo <- aggregate(x=list(value=df1$value), by=list(year=df1$year, month=df1$month, ticker=df1$ticker, field=df1$field), FUN=mean,na.rm=TRUE)
  
  stdpoikkeama <- aggregate(x=list(value=df1$value), by=list(year=df1$year, month=df1$month, ticker=df1$ticker, field=df1$field), FUN=sd,na.rm=TRUE)
  
  # Yhdistä month ja year yhdeksi
  keskiarvo <- tidyr::unite(keskiarvo, date, c(year, month), remove=TRUE, sep="-")
  stdpoikkeama <- tidyr::unite(stdpoikkeama, date, c(year, month), remove=TRUE, sep="-")
  
  # Muuta uudet date-sarakkeet varsinaisiksi pvm-objekteiksi
  keskiarvo$date <- as.Date(paste0(keskiarvo$date, "-", "01"))
  stdpoikkeama$date <- as.Date(paste0(stdpoikkeama$date, "-", "01"))
  
  filename <- strsplit(file,"/")
  filename <- filename[[1]][length(filename[[1]])]
  
  # Tiedoston nimet joihin aggregaattiluvut tallennetaan
  mean_file <- paste(paste("Aggregaatit", "mean", sep="/"), filename, sep="_")
  stdev_file <- paste(paste("Aggregaatit", "stdev", sep="/"), filename, sep="_")
  
  write.csv(keskiarvo, mean_file)
  write.csv(stdpoikkeama, stdev_file)
  
}
