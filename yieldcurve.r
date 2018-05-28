#!usr/bin/env Rscript
####################
### Author: Tommi Salenius
### Email: tommi.salenius@bof.fi 
### Created: Ke 23 05 18
### License: General Public License (2018)
###################

# Tätä tiedostoa käytetään tuottokäyrän (yield curve) piirtämiseen
# Tämä skripti toimii sillä ehdolla, että yield-parametri esiintyy Chart-sarakkeessa
# metadata.xlsx-tiedostossa.

maturitycheck <- function(i,df){
  
  # Luo sovellus grepl-funktiosta, joka hakee oletuksena metad-dataframen Ticker-sarakkeesta
  # ilmaisuja
  mgrep = function(x){
    grepl(x,df$Ticker[i])
  }

  arvo = 0
  
  y1 <- mgrep("1Y")
  y2 <- mgrep("2Y")
  y3 <- mgrep("3Y")
  y4 <- mgrep("4Y")
  y5 <- mgrep("5Y")
  y6 <- mgrep("6Y")
  y7 <- mgrep("7Y")
  y10 <- mgrep("10Y")
  y15 <- mgrep("15Y")
  y30 <- mgrep("30Y")
  
  # Tarkista, mitkä kaikki näistä ovat tosia, ja määrää sen perusteella mikä maturiteetti asetetaan
  
  if(y1) {arvo = 1}
  if(y2) {arvo = 2}
  if(y3) {arvo = 3}
  if(y4) {arvo = 4}
  if(y5 & !y15) {arvo = 5}
  if(y6) {arvo = 6}
  if(y7) {arvo = 7}
  if(y10) {arvo = 10}
  if(y15) {arvo = 15}
  if(y30) {arvo = 30}
  
  return(arvo)
  
}

source("Funktiot/kkaggregointi.r")
source("Funktiot/bof_theme.R")

yieldplot <- function(file,meta,title,time){
  
  aika <- muutos(time) # Valitse katsotaanko tuottokäyrää nyt vai 1kk, 3kk, 12kk tai 24kk
  meta <- subset(meta, (Chart == "yield") & (Title == title)) # Filtteröi kaikki tuottokäyräksi piirrettävät muuttujat metadatasta
  data <- aggregoi(file,save=FALSE)
  data <- data$mean
  data <- subset(data, (data$ticker %in% meta$Ticker) & (data$field %in% meta$Field))
  colnames(meta) <- tolower(colnames(meta)) # Muuta sarakkeiden nimet kokonaan pieniksi kirjaimiksi
  
  df <- plyr::join(data, meta, by=c("ticker","field"),type="left")
  df <- subset(df, date >= aika & date <= aika)
  df <- df[order(df$maturity),]
  print(head(df,n=7))
  ggplot2::ggplot(df,ggplot2::aes(y=value, x=maturity)) + ggplot2::geom_smooth(method="loess",se=FALSE) + bof_theme() + ggplot2::ggtitle(df$title[1])
  
}

yieldplot("Testaus/finbonds.csv",metad,"Suomen valtionlainat",1)

for(i in c(0,1,3)){
yieldplot("Testaus/finbonds.csv",metad,"Suomen valtionlainat",i)
}
