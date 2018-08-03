#################################
## Indeksin rakentamisty√∂kalu ##
## Author: Tommi Salenius     ##
## Date: Ma, 30.7.2018        ##
## License: MIT (2018)        ##
#################################

library(plyr)
library(dplyr)
library(lubridate)

# Haettavat pankit Blommasta:
# Nordea, SEB, Swedbank, Handelsbanken, DNB Bank, Danske, Jyske Bank, SYD Bank, OP, Aktia, √Ölands Banken,
# Landsbankinn

# Tickerit:
# PX_LAST, CUR_MKT_CAP, 

#################
#' T√§m√§n tiedoston tarkoituksena on luoda joukko funktioita, joiden avulla voidaan
#' seurata pohjoismaista pankkitoimintaa. Tarkoituksena on kasata pohjoismaisista
#' pankeista indeksi, jota painotetaan market capin mukaan. Indeksin painojen tulee
#' muuttua dynaamisesti ajassa sen mukaan, miten market capit itse muuttuvat.
#################


#################
#' Automaattinen market cap -painotus:
#' Strategia: lataa ensin koko csv-tiedosto sis√§√§n konsoliin, filtter√∂i pelk√§t Equityt.
#' 

source("Funktiot/kkaggregointi.r")


dataset <- read.csv("Data/pankkiseuranta.csv", stringsAsFactors = FALSE) %>% as.data.frame(.)

dataset$date <- as.Date(dataset$date)

# ----------- Apufunktiot -------------- #

grepfilter <- function(taulukko, pattern, sarake, case = TRUE){
  
  # Etsi taulukosta halutusta sarakkeesta tietty regex-pattern ja filtter√∂i
  # rivit sen perusteella.
  tulos <- eval(substitute(filter(taulukko, grepl(pattern, sarake, ignore.case = case))))
  tulos
  
}

hae_pvm <- function(kk, vv){
  # Hae kuun 1. p‰iv‰m‰‰r‰
  paste(as.character(vv), as.character(kk), "01", sep="-") %>% as.Date()
}

equity_index <- function(taulukko, ticker=NULL){
  
  # Filtterˆi dataframesta osakkeiden p‰iv‰hinnat,
  # ja aggregoi ne p‰iv‰tasolla yhteen indeksin
  # kasaamiseksi. K‰yt‰ t‰t‰ arvonnousu-funktion kanssa
  # kun olet saanut liitetty‰ painot sen l‰pi filtterˆityyn
  # datasettiin. Ticker-argumentti kertoo tallennetaanko
  # uusi taulukko samaan date, field, value, ticker -tyyliseen
  # csv-tiedostoon; tallennetaan jos se on ei-NULL, jolloin
  # argumentin nimest‰ tulee tickerin nimi ja fieldiksi tulee
  # vastaav. PX_LAST

  
  df.equity.pxlast <- grepfilter(grepfilter(taulukko, "Equity", ticker, TRUE), "PX_LAST", field, TRUE)
  print(head(df.equity.pxlast))
  
  df1 <- aggregate(df.equity.pxlast$value, by=list(date = df.equity.pxlast$date), 
                   FUN=function(x) sum(x, na.rm=TRUE))
  
  colnames(df1) <- c("date","value")
  
  # Lis‰‰ tickerit ja fieldit mukaan, jotta voidaan tallentaa helposti mihin tahansa
  # csv-tiedostoon
  if(!is.null(ticker)){
  df1$ticker = rep(ticker, nrow(df1))
  df1$field = rep("PX_LAST", nrow(df1))
  df1 <- df1[,c(1,4,2,3)]
  }
  
  lapply(df1, function(x) replace(x, x == 0.0, NA)) %>% as.data.frame() -> df1
  
  df1
  
}


mkcap_aggregointi <- function(taulukko){
  
  # Ota pankkisektorin sis‰lt‰v‰ dataframe argumentiksi,
  # filtterˆi siit‰ ensin osakkeet ja market capit, ja
  # sitten aggregoi ne kuukausitasolle
  
  # df.equity <- grepfilter(taulukko, "Equity", ticker, TRUE) # Pudota indeksit, bondit yms
  
  # df.equity.mcap <- grepfilter(df.equity, "CUR_MKT_CAP", field, TRUE) # Hae vain Market Capia koskevat luvut
  
  df.equity.mcap <- grepfilter(grepfilter(taulukko, "Equity", ticker, TRUE), "CUR_MKT_CAP", field, TRUE)
  
  df1 <- aggregoi(df.equity.mcap, FALSE)$mean
  
  df1
  
}

arvonnousu <- function(taulukko, skaala=100){
  
  # Muunna hinnat tuotoiksi.
  # Skaala-parametrilla s‰‰det‰‰n yksikˆt, joissa tuotot ilmoitetaan
  # Esim. skaala = 100 => prosentit; skaala = 1000 => basispointsit
  # Ensin poistetaan kaikki muut paitsi PX_LAST-fieldit ja Equityt
  
  taulukko <- filter(taulukko, field == "PX_LAST")
  taulukko <- grepfilter(taulukko, "Equity", ticker, TRUE)
  
  taulukko$ticker %>% as.factor() %>% levels() -> tickerit
  
  lista <- list()
  
  for(i in 1:length(tickerit)){
    taulukko2 <- filter(taulukko, ticker == tickerit[i])
    # Poista NA-arvot, jotta maanantain tuotto = (maanantain hinta - perjantain hinta)/(perjantain hinta)
    taulukko3 <- filter(taulukko2, !is.na(value)) 
    val <- taulukko3$value
    diffval <- diff(val) # V‰henn‰ edellisen periodin arvo nykyisest‰
    diffval <- (diffval/val[1:(length(val)-1)])*skaala # Jaa muutos edell. periodin luvulla ja skaalaa
    taulukko3 <- taulukko3[2:nrow(taulukko3),]
    taulukko3$value_diff <- diffval # Luo v‰liaikainen sarake, jossa tuotot on lueteltu
    new_taulukko <- join(taulukko2, taulukko3, type="left") # Yhdist‰ taulukkoon, jossa on mukan ei-kauppap‰iv‰t
    new_taulukko$value <- new_taulukko$value_diff # Korvaa alkuper‰inen hintoja kuvaava sarake v‰liaikaisella
    new_taulukko <- new_taulukko[,1:4] # Poista v‰liaikainen sarake value_diff
    lista[[i]] <- new_taulukko
  }
 
  lista %>% Reduce(rbind, .) -> result
  
  result
}



hae_painotus <- function(target_frame, ref_frame, func = function(x, y) x == y){
  
  # Target frame: dataframe, johon halutaan tickereit‰ vastaavat kuukausikohtaiset market cap -painotukset
  # ---
  # Ref frame: dataframe, josta market cap -painot haetaan. Dataframen tulee sis‰lt‰‰ weight-niminen sarake
  # ---
  # Func: Kahden muuttujan funktio, joka ottaa argumenteikseen ref framen date-sarakkeen ja p‰iv‰m‰‰r‰-
  #  objektin, palauttaen niit‰ vastaan joko TRUE tai FALSE. T‰m‰n argumentin avulla k‰ytt‰j‰ voi muokata
  #  market cap -painotuksia haluamalleen tavalle omatekoisten funktioiden avulla
  
  check_pvm_ticker <- function(var_pvm, var_ticker){
    
    # Muunna dataframessa oleva pvm s.e. p‰iv‰n numero on 1
    var_pvm %>% as.character() %>% strsplit(., "-") -> var_pvm_transformed
    var_pvm_transformed[[1]][3] <- "01"
    paste(var_pvm_transformed[[1]][1],
          var_pvm_transformed[[1]][2],
          var_pvm_transformed[[1]][3],
          sep="-") %>% as.Date(.,format="%Y-%m-%d") -> var_pvm_transformed
    
    # Hae dataframesta haluttu p‰iv‰ tickerin ja p‰iv‰m‰‰r‰n, tai jonkun sen muunnoksen avulla
    subframe <- ref_frame[ref_frame$ticker == var_ticker & func(ref_frame$date, var_pvm_transformed),]
    
    val <- subframe[, 5] # Etsi painotus tickerin perusteella
    
    if(length(val) == 0){paino <- 0} # Jos tickeri‰ ei lˆydy, ‰l‰ anna sille indeksiss‰ painoa
    else if(length(val) > 1){paino <- val[1]}
    else{paino <- val}
    
    paino
  }

  target_frame %>% nrow() %>% numeric() -> lista

  # K‰yt‰ yll‰oleva funktio jokaisen dataframen rivin l‰pi, ja lopuksi liit‰ lista
  # uudeksi sarakkeeksi kyseiseen taulukkoon
  
   for(i in 1:nrow(target_frame)){
  
    lista[i] <- check_pvm_ticker(target_frame$date[i], target_frame$ticker[i])
   }
  
   target_frame$weight <- as.numeric(lista)
   
   target_frame
  
}

indeksipainot <- function(taulukko, kk, vv){
  
  # Ota argumentiksi taulukko, josta on valmiiksi filtterˆity
  # muut kuin market capit osakkeista, ja luvut aggregoitu
  # kuukausitasolle

  pvm1 <- hae_pvm(kk, vv)
  
  df.recent <- filter(taulukko, date == pvm1)
  
  df.recent$weight <- lapply(df.recent[,4], function(x) x/sum(df.recent[,4], na.rm=TRUE))
  
  df.recent
}

lista = list()

for(i in 1:7){

dataset %>% mkcap_aggregointi() %>% indeksipainot(., i, 2018) -> a

lista[[i]] <- a
  
}

# Kumulatiivista summaa varten => muunna tuotot absoluuttiseksi indeksiksi, jossa
# asetet. 100 = 1. p‰iv‰ dataframessa

kumulsum <- function(lista){
  
  lista %>% lapply(., function(x) {
    if(is.na(x)){0}
    else{x}
  }) %>% cumsum()
  
}

######################
# Ohjelma
#####################
aika = Sys.time()
# Ensin muunnetaan hinnat tuotoiksi
tuotot <- arvonnousu(dataset, 100)

# Luo referenssitaulukko, josta painot haetaan
# Korjaa s.e. saadaan 2016 alkaen luvut mukaan

lista <- list()

var_mkcap <- mkcap_aggregointi(dataset)

for(j in 1:3){
  
  var_mkcap %>% indeksipainot(., 1, 2015 + j) -> df1
  
  for(i in 2:12){
  
    var_mkcap %>% indeksipainot(., i, 2015 + j) -> df2
  
    df1 <- rbind(df1, df2)
  }
  
  lista[[j]] <- df1
}

# Muunna lista dataframeksi
painomatriisi <- do.call("rbind", lista)


# Hae painot perustuen listaan
values <- hae_painotus(tuotot, painomatriisi)

mult_if_possible <- function(x,y){
  if(is.na(x) == TRUE | is.na(y) == TRUE){
    x
  } else{x*y}
}

# Aggregoidaan values-matriisia
values$value <- apply(values[,c(3,5)], 1, function(x) mult_if_possible(x[1], x[2]))

tulokset <- equity_index(values, "RMVA Nordic Bank Index")

# Muunna tuotot indeksituotoksi
val_cumsum <- kumulsum(tulokset$value) + 100

# for(i in 1:nrow(tulokset)){
#   if(!is.na(tulokset$value[i])){tulokset$value[i] <- val_cumsum[i]}
#   else{tulokset$value[i]}
# }

tulokset$value <- val_cumsum

loppu = Sys.time() - aika
print(loppu)


###########

#####
# Tilanne 3.8.2018
# N‰ytt‰‰ toimivan hyvin t‰h‰n asti, ainoa mik‰ vaatii viel‰ lis‰yst‰ on:
# * Summaa lopuksi kaikki yhteen, jotta saadaan indeksi
# * Indeksit yms ei-osakkeet eiv‰t n‰yt‰ tippuvan filtterˆinniss‰

#########################################################

#mkcap_avg <- aggregate(df.equity.mcap, by=list(df.equity.mcap$ticker), mean, na.rm=T)

order(mkcap_avg$value, decreasing = TRUE)


mkcap_avg$weight <- lapply(mkcap_avg[,4], function(x) x/sum(mkcap_avg[,4], na.rm=TRUE))

macro <- function(expr, var){
  
  return(substitute(function(var) expr))
  
}

polyn <- macro(function(x) x^2-3*x+4)
