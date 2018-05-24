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

yieldplot <- function(file,meta){
  
  meta <- subset(meta, Chart == "yield") # Filtteröi kaikki tuottokäyräksi piirrettävät muuttujat metadatasta
  data <- aggregoi(file,save=FALSE)
  data <- data$mean
  data <- subset(data, (data$ticker %in% meta$Ticker) & (data$field %in% meta$Field))
  print(head(data))
  meta$Title <- factor(meta$Title) # Tällä pudotetaan pois levelsit, jotka jäävät filtteröinnin jälkeen
  
  for(i in levels(meta$Title)){
    
    df_meta <- subset(meta, meta$Title == i)
    df_data <- subset(data, (data$ticker %in% df_meta$Ticker) & (data$field %in% df_meta$Field))
    
    # Seuraava tehtävä on saada maturiteetti df_metasta df_data-taulukkoon oikeisiin kohtiin.
    # Kokeillaan yksinkertaisesti liittää ne yhteen
    # Ei toimi rivien perusteella, koska rivien tunnisteiden täytyy olla uniikkeja (siis ei rownames...)
    
    
    
  }
  
}

yieldplot("Testaus/finbonds.csv",metad)
